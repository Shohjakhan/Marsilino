package com.example.restaurant

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    MapKitFactory.setApiKey("9aca93cd-f1f8-4251-ab21-48a8d1b101d0") // TODO: Replace with your valid Yandex MapKit API key
    super.configureFlutterEngine(flutterEngine)
  }
}
