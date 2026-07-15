import com.android.build.api.variant.FilterConfiguration.FilterType.ABI

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

configurations.all {
    // https://codeberg.org/UnifiedPush/flutter-connector/issues/21
    // https://central.sonatype.com/artifact/com.google.crypto.tink/tink-android
    val tink = "com.google.crypto.tink:tink-android:1.18.0"
    resolutionStrategy {
        force(tink)
        dependencySubstitution {
            substitute(module("com.google.crypto.tink:tink")).using(module(tink))
        }
    }
}

android {
    namespace = "business.braid.polycule"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21

        // https://developer.android.com/studio/write/java8-support.html#library-desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "business.braid.polycule"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
        }
        release {
        }
    }
}

dependencies {
    implementation("org.unifiedpush.android:embedded-fcm-distributor:3.0.0")

    // https://developer.android.com/studio/write/java8-support.html#library-desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}

// F-droid splits APKs by ABI, and requires different versionCode for each ABI.
// For flutter version X.Y.Z, version code is X0Y0ZA, where A is the ABI code.
// See:
// * https://developer.android.com/build/gradle-tips
// * https://developer.android.com/studio/build/configure-apk-splits
// * https://gitlab.com/fdroid/fdroiddata/-/blob/master/metadata/im.nfc.nfsee.yml
val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 4)

androidComponents {
    onVariants { variant ->
        // Assigns a different version code for each output APK
        // other than the universal APK.
        variant.outputs.forEach { output ->
            val name = output.filters.find { it.filterType == ABI }?.identifier
            // Stores the value of abiCodes that is associated with the ABI for this variant.
            val abiVersionCode = abiCodes[name]
            // Because abiCodes.get() returns null for ABIs that are not mapped by ext.abiCodes,
            // the following code does not override the version code for universal APKs.
            // However, because we want universal APKs to have the lowest version code,
            // this outcome is desirable.
            if (abiVersionCode != null) {
                // Assigns the new version code to output.versionCode, which changes the version code
                // for only the output APK, not for the variant itself.
                output.versionCode.set((output.versionCode.get()  ?: 0) * 10 + abiVersionCode)
            }
        }
    }
}
