@echo off
setlocal enabledelayedexpansion

:: Change to android directory
pushd android

:: Get the first connected device serial number
set "DEVICE="
for /f "skip=1 tokens=1" %%A in ('adb devices') do (
    if not defined DEVICE (
        set "DEVICE=%%A"
    )
)

if not defined DEVICE (
    echo No ADB devices found. Exiting.
    popd
    exit /b 1
)

echo Using device: %DEVICE%

echo [STEP 1] Building APK with Gradle...
call gradlew.bat assembleDebug
if %errorlevel% neq 0 (
    echo Build failed. Exiting.
    popd
    exit /b %errorlevel%
)

echo [STEP 2] Installing APK on device %DEVICE%...
call adb -s %DEVICE% install -r distribution\android\app\outputs\apk\debug\app-debug.apk
if %errorlevel% neq 0 (
    echo APK install failed. Exiting.
    popd
    exit /b %errorlevel%
)

echo [STEP 3] Launching app activity on %DEVICE%...
call adb -s %DEVICE% shell am start -n imgui.example.android/.MainActivity
if %errorlevel% neq 0 (
    echo App launch failed. Exiting.
    popd
    exit /b %errorlevel%
)

echo Done.

:: Return to the original directory
popd
endlocal
