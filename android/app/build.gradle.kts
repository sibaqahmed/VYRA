plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (must be after Android & Kotlin)
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.vyra"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.vyra"

        // ✅ REQUIRED for flutter_local_notifications
        minSdk = 24

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // ✅ Java 11 is OK
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ✅ THIS FIXES YOUR ERROR
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // ✅ Safe defaults
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ REQUIRED for flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.0.4"
    )
}
