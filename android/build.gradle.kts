// Project-level build file
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android")
        if (android is com.android.build.gradle.BaseExtension) {
            // Force the 16KB-compatible toolchain (NDK 28) and Android 16 (API 36) globally.
            // This ensures all plugins (including isar_db) are built with the correct toolchain.
            android.compileSdkVersion(36)
            android.ndkVersion = "28.2.13676358"
            
            android.defaultConfig {
                minSdkVersion(24)
                targetSdkVersion(36)
                
                // Expert Fix: Inject 16KB alignment flags into all native compilations.
                // This is the primary requirement for 16KB page size support in shared libraries.
                externalNativeBuild.cmake.cppFlags("-Wl,-z,max-page-size=16384")
                externalNativeBuild.cmake.arguments("-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384")
                externalNativeBuild.ndkBuild.arguments("APP_LDFLAGS+=-Wl,-z,max-page-size=16384")
            }
            
            // Critical for 16KB page size support:
            // Ensures native libraries are stored uncompressed and aligned in the APK/Bundle.
            android.packagingOptions.jniLibs.useLegacyPackaging = false
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
