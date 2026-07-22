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
            // Force the 16KB-compatible toolchain (NDK 28) globally
            // This ensures all plugins (like Isar) are built with the correct toolchain
            android.compileSdkVersion("android-36")
            android.buildToolsVersion("36.0.0")
            android.ndkVersion = "28.2.13676358"
            
            android.defaultConfig {
                minSdkVersion(24)
                targetSdkVersion(36)
            }
            
            // Critical for 16KB page size support:
            // Ensures native libraries are stored uncompressed and aligned
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
