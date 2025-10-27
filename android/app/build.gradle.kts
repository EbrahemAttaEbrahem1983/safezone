// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") // الصيغة الصحيحة في Kotlin DSL
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.safe_zone"

    // قيم Flutter المولدة تلقائياً
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // اجعل الجافا على 17 بصياغة Kotlin DSL الصحيحة
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // اجعل Kotlin JVM Target على 17 أيضاً
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.safe_zone"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // توقيع مبدئي للتجربة
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// (اختياري لكنه مفيد) تثبيت JDK 17 عبر الـToolchain
kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}
