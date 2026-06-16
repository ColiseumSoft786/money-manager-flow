import com.flutter.gradle.tasks.FlutterTask
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.gms.google-services")
}

android {
    namespace = "mn.flow.flow"
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "mn.flow.flow"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties().apply {
        if (keystorePropertiesFile.exists()) {
            load(FileInputStream(keystorePropertiesFile))
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = file(keystoreProperties["storeFile"] as? String ?: ".")
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// Icon picker + serialized icons use runtime IconData (lib/data/flow_icon.dart, icons.dart).
// Matches CI (--no-tree-shake-icons) so profile/release APK builds succeed.
tasks.withType<FlutterTask>().configureEach {
    treeShakeIcons = false
}

// Force specific versions to avoid alpha releases
configurations.all {
    resolutionStrategy {
        force("androidx.glance:glance-appwidget:1.1.1")
        force("androidx.glance:glance-material3:1.1.1")
        force("androidx.glance:glance-preview:1.1.1")
    }
}

configurations {
    debugImplementation {
        exclude(group = "io.objectbox", module = "objectbox-android")
    }
}

dependencies {
    implementation("androidx.window:window:1.5.0")
    implementation("androidx.window:window-java:1.5.0")
    
    // Pin Glance to stable 1.1.1 instead of alpha
    implementation("androidx.glance:glance-appwidget:1.1.1")
    implementation("androidx.glance:glance-material3:1.1.1")
    implementation("androidx.glance:glance-preview:1.1.1")
    
    // Pin Compose dependencies to stable versions
    implementation("androidx.compose.foundation:foundation-layout:1.6.8")  // Updated to stable
    
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    debugImplementation("io.objectbox:objectbox-android-objectbrowser:5.1.0")
    debugImplementation("androidx.glance:glance-appwidget-preview:1.1.1")
    implementation(platform("com.google.firebase:firebase-bom:34.14.0"))
}