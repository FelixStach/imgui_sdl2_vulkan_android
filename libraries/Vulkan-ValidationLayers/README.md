# Vulkan Validation Layers on Android

If you want to use Vulkan Validation layers on Android, there are 2 ways to do it:

- Use the devices validation layers: Its a bit more complicated and several consitions must be met, or
- ship the validation layer libraries yourself, which is what we do.

The files in this folder are precompiled android validation layers, sourced from
https://github.com/KhronosGroup/Vulkan-ValidationLayers/releases/tag/vulkan-sdk-1.4.313.0

The Cmake setup will copy the files to where they need to go.