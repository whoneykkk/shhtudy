allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// buildscript 블록 추가 - Google Services를 위한 클래스패스 의존성 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services plugin
        classpath("com.google.gms:google-services:4.4.1")
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
