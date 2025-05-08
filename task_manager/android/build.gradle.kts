buildscript {
    repositories {
        google()  // Make sure this is present
        mavenCentral()  // Make sure this is present
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.0.4") // No semicolon here
        classpath("com.google.gms:google-services:4.3.3") // No semicolon here
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}