package com.example.safe_zone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

  private val CHANNEL = "com.example.safe_zone/binding"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "signChallenge" -> {
            try {
              val challenge = call.argument<String>("challenge") ?: ""
              // إنشاء/التأكد من وجود مفتاح Keystore + التوقيع (هنضيف BindingUtil بعد خطوة تالية)
              val pubKey = BindingUtil.ensureKeypair()
              val challengeB64 = android.util.Base64.encodeToString(
                challenge.toByteArray(), android.util.Base64.NO_WRAP
              )
              val signature = BindingUtil.sign(challengeB64)
              result.success(mapOf("signature" to signature, "pubKey" to pubKey))
            } catch (e: Exception) {
              result.error("ERR", e.message, null)
            }
          }
          else -> result.notImplemented()
        }
      }
  }
}
