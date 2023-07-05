package com.example.presence_alpha

import android.content.Context
import android.location.Location
import android.location.LocationManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.example.presence_alpha/mock_location"
                )
                .setMethodCallHandler { call, result ->
                    when {
                        call.method.equals("isMockLocationEnabled") -> {
                            isMockLocationEnabled(call, result)
                        }
                    }
                }
    }

    fun isMockLocationEnabled(call: MethodCall, result: MethodChannel.Result) {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        try {
            val locationProviders = locationManager.getProviders(true)
            for (provider in locationProviders) {
                val location = locationManager.getLastKnownLocation(provider)
                if (location != null && isMockLocation(location)) {
                    return result.success("true")
                }
            }
        } catch (e: SecurityException) {
            // Handle security exception
        }

        return result.success("false")
    }

    private fun isMockLocation(location: Location): Boolean {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2
        ) {
            location.isFromMockProvider
        } else {
            false
        }
    }
}
