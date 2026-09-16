import java.io.File
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val releasePropertiesFile = rootProject.file("key.properties")
val releaseProperties = Properties()
if (releasePropertiesFile.isFile) {
    FileInputStream(releasePropertiesFile).use(releaseProperties::load)
}

fun releaseValue(environmentName: String, propertyName: String): String? =
    System.getenv(environmentName)?.takeIf(String::isNotBlank)
        ?: releaseProperties.getProperty(propertyName)?.takeIf(String::isNotBlank)

val releaseStorePath = releaseValue("ANDROID_KEYSTORE_FILE", "storeFile")
val releaseStorePassword = releaseValue("ANDROID_STORE_PASSWORD", "storePassword")
val releaseKeyAlias = releaseValue("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = releaseValue("ANDROID_KEY_PASSWORD", "keyPassword")
val releaseSigningReady = listOf(
    releaseStorePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

if (gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) } &&
    !releaseSigningReady
) {
    throw GradleException("Release signing configuration is incomplete")
}

android {
    namespace = "com.idealab.mec.grow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.idealab.mec.grow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningReady) {
                val configuredStore = File(requireNotNull(releaseStorePath))
                storeFile = if (configuredStore.isAbsolute) {
                    configuredStore
                } else {
                    rootProject.file(configuredStore.path)
                }
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
