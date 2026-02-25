# Backend API Requirements

This document outlines the API requirements for the frontend developers to communicate to the backend team.

---

## 1. Multi-Language Support (Localization)

To support multiple languages (e.g., English, Russian, Uzbek), the database needs to store translatable fields (like restaurant names, descriptions, dish names) in multiple languages, or the backend should return the appropriate translation based on the user's requested language.

### Expected Implementation

The frontend will send an `Accept-Language` header with every API request.

**Headers from Frontend:**

```http
Accept-Language: ru  // (Can be 'en', 'ru', or 'uz')
Authorization: Bearer <access_token>
```

**Backend Responsibility:**

- The backend reads the `Accept-Language` header.
- For text fields like `description`, `name`, or `category`, the backend returns the string corresponding to the requested language.
- If the requested language translation is missing, fallback to a default language (e.g., Russian or Uzbek).

**Example Response (if `Accept-Language: en`):**

```json
{
  "id": 1,
  "name": "Central Plov",
  "description": "The best plov in the city."
}
```

**Example Response (if `Accept-Language: uz`):**

```json
{
  "id": 1,
  "name": "Markaziy Osh",
  "description": "Shahardagi eng zo'r osh."
}
```

---

## 2. Dynamic Tags System

The application uses tags (e.g., "Halal", "Fast Food", "Romantic") to categorize and filter restaurants.

### Endpoint: `GET /api/v1/tags`

Returns a list of all available tags so the frontend can display them in the filter carousel. The names should be localized based on the `Accept-Language` header.

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "tag_1",
      "name": "Halal",
      "icon_url": "https://example.com/icons/halal.png"
    },
    {
      "id": "tag_2",
      "name": "Fast Food",
      "icon_url": "https://example.com/icons/fastfood.png"
    }
  ]
}
```

### Endpoint: `GET /api/v1/restaurants?tags=tag_1,tag_2`

The existing restaurant listing endpoint must accept a `tags` query parameter (comma-separated list of tag IDs).

**Backend Responsibility:**

- Filter the restaurants in the database to only return those that contain ALL (or ANY, depending on your business logic) of the requested tags.
- Each restaurant object in the response should also include its assigned tags.

---

## 3. QR Code & Cashback System

This is the secure flow for verifying a Soliq receipt QR code and crediting the user's wallet.

### Endpoint: `POST /api/v1/receipt/verify`

The frontend sends the raw URL scanned from the QR code. The backend acts as a secure proxy to verify the receipt with the government's Soliq servers.

**Request:**

```json
{
  "qr_code_url": "https://ofd.soliq.uz/check?t=UZ123456789&r=1&c=20250221120000&s=150000.00",
  "restaurant_id": "rest_123"
}
```

**Backend Responsibility:**

1. Parse the URL and ping the Soliq OFD API to verify the receipt is real.
2. Check the `redeemed_receipts` database table to ensure this specific receipt ID hasn't been scanned by anyone before (Prevent Double Redemption).
3. Verify the TIN (tax ID) on the receipt matches the `restaurant_id`'s registered TIN in your database.
4. If valid, calculate the cashback amount: `(total_amount_from_soliq * restaurant_cashback_percentage) / 100`.
5. Add the amount to the user's wallet balance.
6. Record the transaction in the database.

**Success Response `200 OK`:**

```json
{
  "success": true,
  "data": {
    "receipt_id": "rec_0001-0042",
    "total_paid": 150000.0,
    "cashback_earned": 15000.0,
    "new_wallet_balance": 45000.0,
    "restaurant_name": "Premium Restaurant"
  }
}
```

**Error Responses:**

- `400 Bad Request`: "Invalid QR code format."
- `409 Conflict`: "This receipt has already been redeemed."
- `422 Unprocessable Entity`: "This receipt does not belong to this restaurant."
- `404 Not Found`: "Receipt not found in the state tax database."
