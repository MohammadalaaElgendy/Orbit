plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // هيقرأ النسخة من الـ settings تلقائياً زي ما اتفقنا
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mohammad.alaa.orbit"

    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.mohammad.alaa.orbit"

        // لو ضربت معاك flutter.minSdkVersion خليها 21 مباشرة
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}