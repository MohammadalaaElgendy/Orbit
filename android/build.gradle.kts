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
    project.evaluationDependsOn(":app")
}

subprojects {
    val setCompileSdk = {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null) {
            // إجبار أي إضافة على استخدام SDK 34 على الأقل لتجنب تعارضات مكتبات androidx
            if (android.compileSdkVersion == "android-33" || android.compileSdkVersion == "android-32") {
                android.compileSdkVersion(34)
            }
        }
    }
    if (project.state.executed) {
        setCompileSdk()
    } else {
        project.afterEvaluate { setCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
