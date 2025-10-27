package com.example.safe_zone

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import android.util.Base64

object BindingUtil {
  private const val ANDROID_KEYSTORE = "AndroidKeyStore"
  private const val ALIAS = "safe_zone_bind"

  fun ensureKeypair(): String {
    val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    if (!ks.containsAlias(ALIAS)) {
      val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, ANDROID_KEYSTORE)
      val spec = KeyGenParameterSpec.Builder(
        ALIAS,
        KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
      )
        .setDigests(KeyProperties.DIGEST_SHA256)
        .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PSS)
        .setUserAuthenticationRequired(false)
        //.setIsStrongBoxBacked(true) // إن كان مدعومًا على الجهاز
        .build()
      kpg.initialize(spec)
      kpg.generateKeyPair()
    }
    val cert = ks.getCertificate(ALIAS)
    val pub = cert.publicKey.encoded
    return Base64.encodeToString(pub, Base64.NO_WRAP)
  }

  fun sign(challengeBase64: String): String {
    val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    val entry = ks.getEntry(ALIAS, null) as KeyStore.PrivateKeyEntry
    val sig = Signature.getInstance("SHA256withRSA/PSS")
    sig.initSign(entry.privateKey)
    val payload = Base64.decode(challengeBase64, Base64.NO_WRAP)
    sig.update(payload)
    val signed = sig.sign()
    return Base64.encodeToString(signed, Base64.NO_WRAP)
  }
}
