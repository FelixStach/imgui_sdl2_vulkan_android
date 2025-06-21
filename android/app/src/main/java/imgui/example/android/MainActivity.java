package imgui.example.android;

import android.widget.Toast;
import org.libsdl.app.SDLActivity;

public class MainActivity extends SDLActivity {

    @Override
    protected String[] getLibraries() {
        return new String[]{
            "imgui_sdl2_vulkan_android"
        };
    }
}