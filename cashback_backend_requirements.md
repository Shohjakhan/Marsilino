# Cashback Backend Requirements

> Backend API specification for the cashback wallet and receipt verification system.

---

## 1. Required Endpoints

### `GET /api/v1/wallet`

Returns the current user's cashback wallet balance.

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "user_id": "usr_abc123",
    "balance": 45000.0,
    "currency": "UZS",
    "total_earned": 120000.0,
    "total_transferred": 75000.0,
    "last_updated": "2025-02-21T12:00:00Z"
  }
}
```

---

### `POST /api/v1/wallet/add`

Adds cashback to the user's wallet after a verified receipt scan.

**Headers:**

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**

```json
{
  "receipt_id": "rec_0001-0042",
  "total_paid": 150000.0,
  "cashback_percentage": 5.0,
  "cashback_amount": 7500.0,
  "restaurant_id": "rest_xyz789"
}
```

**Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "transaction_id": "txn_def456",
    "new_balance": 52500.0,
    "cashback_amount": 7500.0,
    "receipt_id": "rec_0001-0042"
  }
}
```

**Error `409 Conflict` (double redemption):**

```json
{
  "success": false,
  "error": "RECEIPT_ALREADY_REDEEMED",
  "message": "This receipt has already been used for cashback."
}
```

---

### `POST /api/v1/wallet/transfer`

Transfers cashback balance to the user's linked bank card.

**Headers:**

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**

```json
{
  "amount": 45000.0,
  "card_last_four": "1234"
}
```

**Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "transaction_id": "txn_ghi789",
    "transferred_amount": 45000.0,
    "new_balance": 0.0,
    "card_last_four": "1234",
    "estimated_arrival": "2025-02-22T00:00:00Z"
  }
}
```

**Error `400 Bad Request` (insufficient balance):**

```json
{
  "success": false,
  "error": "INSUFFICIENT_BALANCE",
  "message": "Not enough balance to transfer."
}
```

---

### `POST /api/v1/receipt/verify`

Verifies a Soliq fiscal receipt via QR code and returns parsed data.

**Headers:**

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**

```json
{
  "qr_code": "https://ofd.soliq.uz/check?t=UZ123456789&r=1&c=20250221120000&s=150000.00"
}
```

**Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "receipt_id": "rec_0001-0042",
    "receipt_number": "0001-0042",
    "total_amount": 150000.0,
    "restaurant_name": "Premium Restaurant",
    "created_at": "2025-02-21T12:00:00Z",
    "tin": "123456789",
    "already_redeemed": false
  }
}
```

**Error `404 Not Found`:**

```json
{
  "success": false,
  "error": "RECEIPT_NOT_FOUND",
  "message": "Receipt not found in Soliq system."
}
```

---

## 2. Required Fields

### Core Fields

| Field                 | Type     | Description                                                   |
| --------------------- | -------- | ------------------------------------------------------------- |
| `user_id`             | `string` | Authenticated user identifier                                 |
| `receipt_id`          | `string` | Unique receipt identifier from Soliq                          |
| `total_paid`          | `number` | Total amount paid on the receipt (UZS)                        |
| `cashback_percentage` | `number` | Cashback rate applied (e.g., `5.0` for 5%)                    |
| `cashback_amount`     | `number` | Calculated cashback: `total_paid × cashback_percentage / 100` |

### Additional Fields

| Field            | Type       | Description                          |
| ---------------- | ---------- | ------------------------------------ |
| `restaurant_id`  | `string`   | Restaurant the receipt belongs to    |
| `transaction_id` | `string`   | Unique ID for every wallet operation |
| `receipt_number` | `string`   | Human-readable receipt number        |
| `created_at`     | `datetime` | Receipt creation timestamp           |

---

## 3. Security

### Prevent Double Redemption

- Store every redeemed `receipt_id` in a `redeemed_receipts` table.
- Before adding cashback, query: `SELECT 1 FROM redeemed_receipts WHERE receipt_id = ?`
- Return `409 RECEIPT_ALREADY_REDEEMED` if found.
- Use a **unique constraint** on `receipt_id` as a database-level safeguard.

```sql
CREATE TABLE redeemed_receipts (
    id            SERIAL PRIMARY KEY,
    receipt_id    VARCHAR(100) UNIQUE NOT NULL,
    user_id       VARCHAR(100) NOT NULL,
    restaurant_id VARCHAR(100) NOT NULL,
    total_paid    DECIMAL(12, 2) NOT NULL,
    cashback_amount DECIMAL(12, 2) NOT NULL,
    redeemed_at   TIMESTAMP DEFAULT NOW()
);
```

### Validate Receipt via Soliq

1. Receive QR code URL from client.
2. Parse URL parameters (`t`, `r`, `c`, `s`) for initial validation.
3. Forward request to Soliq OFD API to verify authenticity.
4. Cross-check `total_amount` from Soliq response against client-submitted value.
5. Reject if discrepancy exceeds tolerance (e.g., ±1 UZS for rounding).

### Store Redeemed Receipts

- Persist full receipt data alongside redemption metadata.
- Track `user_id`, `restaurant_id`, `cashback_amount`, and `redeemed_at`.
- Enable audit queries for dispute resolution and fraud detection.

### Additional Security Measures

- **Rate limiting**: Max 10 receipt verifications per user per hour.
- **JWT validation**: All endpoints require valid `Authorization: Bearer` token.
- **Amount caps**: Maximum single cashback amount (e.g., 500,000 UZS).
- **Time window**: Reject receipts older than 72 hours.

---

## 4. Transaction Logging

Every wallet operation must create an entry in the `wallet_transactions` table:

```sql
CREATE TABLE wallet_transactions (
    id               SERIAL PRIMARY KEY,
    transaction_id   VARCHAR(100) UNIQUE NOT NULL,
    user_id          VARCHAR(100) NOT NULL,
    type             VARCHAR(20) NOT NULL,  -- 'cashback_add' | 'transfer_out'
    amount           DECIMAL(12, 2) NOT NULL,
    balance_before   DECIMAL(12, 2) NOT NULL,
    balance_after    DECIMAL(12, 2) NOT NULL,
    receipt_id       VARCHAR(100),          -- NULL for transfers
    restaurant_id    VARCHAR(100),          -- NULL for transfers
    card_last_four   VARCHAR(4),            -- NULL for cashback adds
    status           VARCHAR(20) DEFAULT 'completed',  -- 'completed' | 'pending' | 'failed'
    created_at       TIMESTAMP DEFAULT NOW(),
    metadata         JSONB                  -- Additional context
);
```

### Log Entry Examples

**Cashback Add:**

```json
{
  "transaction_id": "txn_def456",
  "user_id": "usr_abc123",
  "type": "cashback_add",
  "amount": 7500.0,
  "balance_before": 45000.0,
  "balance_after": 52500.0,
  "receipt_id": "rec_0001-0042",
  "restaurant_id": "rest_xyz789",
  "status": "completed"
}
```

**Transfer Out:**

```json
{
  "transaction_id": "txn_ghi789",
  "user_id": "usr_abc123",
  "type": "transfer_out",
  "amount": 45000.0,
  "balance_before": 52500.0,
  "balance_after": 7500.0,
  "card_last_four": "1234",
  "status": "completed"
}
```
