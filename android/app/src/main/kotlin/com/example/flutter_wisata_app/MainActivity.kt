package com.example.flutter_wisata_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wisata.app/print"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printThermal") {
                val text = call.argument<String>("text")
                if (text != null) {
                    val success = printToThermer(text)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun printToThermer(text: String): Boolean {
        return try {
            // Intent ke Bluetooth Print (Thermer)
            val intent = Intent()
            intent.action = Intent.ACTION_SEND
            intent.putExtra(Intent.EXTRA_TEXT, text)
            intent.type = "text/plain"
            intent.setPackage("ru.a402d.rawbtprinter")
            
            // Cek apakah Thermer terinstall
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                true
            } else {
                // Jika Thermer tidak terinstall, tampilkan chooser
                startActivity(Intent.createChooser(intent, "Pilih Aplikasi Print"))
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
