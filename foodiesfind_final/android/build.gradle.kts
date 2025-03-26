buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin version
        classpath("com.android.tools.build:gradle:7.4.2")

        // Google Services plugin for Firebase
        classpath("com.google.gms:google-services:4.3.15")
    }
}

subprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optionally, a clean task
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
