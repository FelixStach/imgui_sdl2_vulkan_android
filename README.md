# ImGui_SDL2_Vulkan_Android

Welcome to the Minimal Setup designed to use ImGui with SDL2 and Vulkan on **Android**.
This project compiles on Desktop too, but I tested this only on Windows.
The project is heavily inspired by Pvallet's [hello-sdl2-android-ios](https://github.com/pvallet/hello-sdl2-android-ios) and uses it as a base.

How to build
------------

<sub>I only ever compiled the Android App and Desktop Version on Windows, but there is no reason why it wouldn't work on Mac or Linux too, since there is no platform specific code here. Exeute the following commands inside your terminal. (**cmd** / **PowerShell** or **bash**)</sub>

**1. Clone this repository**

```bash
git clone https://github.com/FelixStach/imgui_sdl2_vulkan_android.git
```

**2. Load Git submodules**

**SDL2** and **ImGui** are loaded as submodules. Simply execute
```bash
cd imgui_sdl2_vulkan_android
git submodule update --init --recursive
```
and notice how both libraries are placed inside the **libraries/** folder.

**3. Setup Android Environment**

Android App Development is quite flimsy since all parts of the build-chain need to be compatible with each other.
This can easily become a hassle, but dont't get frustrated. You need the following tools installed: (Version number in brackets are the versions **I** am using, not the only versions that work)

 - Android Studio (Ladybug | 2024.2.1 Patch 2 `October, 2024`)
 - Android SDK Platform (Android Studio -> SDK Manager -> Languages & Frameworks -> Android SDK -> SDK Platforms ->  Android 15.0 ("VanillaIceCream") with API Level 35)
 - SDK Tools (Android Studio -> SDK Manager -> Languages & Frameworks -> Android SDK -> SDK Tools)
   - Android SDK Build-Tools 36
   - NDK (Side by side)
   - Android SDK Command-line Tools (latest)
   - CMake
   - Android SDK Platform-Tools
   - Java (Comes bundled with Android Studio, gets installed here (on Windows): `C:\Program Files\Android\Android Studio\jbr`, calling `javac --version` results in `javac 21.0.7`). It might be a good Idea to redirect the `JAVA_HOME` environment to that Java distribution, so it will be used from outside of Android Studio too.

just try to get all tools with versions compatible to each other. 

**4. Building the Android App**

There are 2 good ways to build the Android App.

- **Build using Android Studio**: Open the **android/** folder inside Android Studio, and compile and launch the App using the **Run 'app** button (green, at the top). If you have a [debugging-enabled](https://developer.android.com/studio/debug/dev-options) Android device connected, it should launch the app right after successfully building it.

- Build using command line (**Gradle Wrapper**): If you prefer to use a different code editor than Android Studio, you can build the App from your command line. Navigate into the android folder and call
  ```bash
  gradlew.bat assembleDebug
  ```
  on Windows or
  ```bash
  ./gradlew assembleDebug
  ```
  on Linux / Mac. This will also launch the build process. On Windows there is a batch file called `buildAndLaunchAndroid.bat`. Make sure that you have a [debugging-enabled](https://developer.android.com/studio/debug/dev-options) Android device connected, do
  ```bash
  adb devices
  ```
  and it will display all your available android devices. It should look something like:

  ```bash
  List of devices attached
  G78U1K0603130BLR        device
  ```
  If you get at least 1 device here, you can execute
  ```bash
  buildAndLaunchAndroid.bat
  ```
  and if everything works, it will will **build** the app, **install it** and **launch** it.

**4a. Build for Desktop**

The provided Cmake Setup should also work for Desktop compilation. Make sure that you have a modern compiler installed. The easiest way to build the Dektop version is to use *VS Code* with the *Cmake Tools* Extension, which will let you compile and launch the Executable from the *VS Code* Interface ('launch the selected target in the terminal window' Button in the bottom bar) 

Vulkan Validation Layers
------------------------

Vulkan Validation Layers are a great way to find out where things break. This project bundles precompiled Android Validation Layers into the package (see **libraries/Vulkan-ValidationLayers/README.md**) and defines the **_DEBUG** macro for debug builds, therefore enabling validation layers. Minimal code manipulation must happen in order for the validation layers to actually be useful.

 1. Find the ImGui main.cpp inside **libraries/imgui/examples/example_sdl2_vulkan/main.cpp** (make sure submodules are loaded) where you will find this section:

```cpp
#ifdef APP_USE_VULKAN_DEBUG_REPORT
static VKAPI_ATTR VkBool32 VKAPI_CALL debug_report(VkDebugReportFlagsEXT flags, VkDebugReportObjectTypeEXT objectType, uint64_t object, size_t location, int32_t messageCode, const char* pLayerPrefix, const char* pMessage, void* pUserData)
{
    (void)flags; (void)object; (void)location; (void)messageCode; (void)pUserData; (void)pLayerPrefix; // Unused arguments
    fprintf(stderr, "[vulkan] Debug report from ObjectType: %i\nMessage: %s\n\n", objectType, pMessage);
    return VK_FALSE;
}
#endif // APP_USE_VULKAN_DEBUG_REPORT
```

fprint(), the default function for printing strings to the terminal, does not actually print the string into the observable Android log, which you can observe using

```bash
adb logcat 
```

In order for these messages to show up, replace the above code with

```cpp
#ifdef APP_USE_VULKAN_DEBUG_REPORT

// Only include Android specific code when compiling for Android
#ifdef ANDROID
#include <android/log.h>  // Required for __android_log_print
#include <unistd.h>  // For sleep function
#endif

static VKAPI_ATTR VkBool32 VKAPI_CALL debug_report(VkDebugReportFlagsEXT flags, VkDebugReportObjectTypeEXT objectType, uint64_t object, size_t location, int32_t messageCode, const char* pLayerPrefix, const char* pMessage, void* pUserData)
{
    (void)flags; (void)object; (void)location; (void)messageCode; (void)pUserData; (void)pLayerPrefix; // Unused arguments

    // Print to stderr for non-Android platforms
    fprintf(stderr, "[vulkan] Debug report from ObjectType: %i\nMessage: %s\n\n", objectType, pMessage);

    // Log to Android logcat ONLY on Android platform
    #ifdef ANDROID
    __android_log_print(ANDROID_LOG_ERROR, "VulkanValidation", "[Vulkan] %s: %s", pLayerPrefix, pMessage);
    // Wait for a brief moment to ensure messages are sent to logcat
    sleep(2);  // Wait for 2 seconds (can be adjusted)
    #endif

    return VK_FALSE;
}
#endif // APP_USE_VULKAN_DEBUG_REPORT 
```

This will make sure that the message show up on Desktop and Android.

Android App tested on
---------------------
- Google Pixel 7 Phone
- Amazon Fire HD 10 (9. Generation)
- Feel free to tell me about more devices that this project runs on.

Known Problems
--------------

- The App crashes on re-entries, more specifically:
  - Google Pixel 7 behaviour: If the user switches to another app and then back to this one, the app crashes.
  - Amazon Fire HD 10 behaviour: If the user enters the *Overview screen*/*Recents screen* and then re-enters this app, it crashes.