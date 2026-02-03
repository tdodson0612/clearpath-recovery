import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.TheScanMan.clearpathrecovery"
    compileSdk = 36  // UPDATED to SDK 36
    ndkVersion = "27.0.12077973"
    
    // Fix for AGP 8+ (required)
    buildFeatures {
        buildConfig = true
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
        applicationId = "com.TheScanMan.clearpathrecovery"
        minSdk = 24
        targetSdk = 36  // UPDATED to SDK 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // CRITICAL: Enable MultiDex for large app
        multiDexEnabled = true
        
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            storeFile = keystoreProperties["storeFile"]?.let { file(it.toString()) }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Disable minify for now to avoid ProGuard issues
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            applicationIdSuffix = ".debug"
        }
    }
    
    // Prevent duplicate files error
    packagingOptions {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/*.kotlin_module"
            )
        }
    }
}

// Flutter integration (do not remove)
flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for Java 8+ APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // CRITICAL: MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}
