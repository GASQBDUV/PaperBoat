// BananaOS: second screen. The lower panel shows one framebuffer (320x240, scaled 3.2x to 1024x768) that the game
// draws itself: the real status bar on top, the world/room map below (see apply-fas3-map.py).
#include <imgui.h>
#include <cstdint>
#include "ship/window/gui/BananaPanels.h"

extern "C" {
void port_runOnRenderThread(void (*fn)(void*), void* arg);
int gfx_create_framebuffer(uint32_t width, uint32_t height, uint32_t native_width, uint32_t native_height,
                           uint8_t resize, bool forceFixedAspect);
void* gfx_get_framebuffer_texture(int fb);
}

static int sStatusFb = -1;
static void CreateStatusFb(void* arg) {
    *(int*)arg = gfx_create_framebuffer(320, 240, 320, 240, 1, false);
}

// Touch in second-screen pixels (320x240 space). Returns 1 while the finger is down.
extern "C" int port_banana_touch(float* x, float* y) {
    const ImGuiIO& io = ImGui::GetIO();
    const BananaPanels::PanelRect r = BananaPanels::Second();
    *x = (io.MousePos.x - r.x) * 320.0f / r.w;
    *y = (io.MousePos.y - r.y) * 240.0f / r.h;
    return io.MouseDown[0] ? 1 : 0;
}

// Called from the game (inventory.c draw_status_ui): true when the second screen is active.
extern "C" int port_banana_dual(void) {
    return BananaPanels::Active();
}
extern "C" int port_banana_status_fb(void) {
    if (sStatusFb < 0) port_runOnRenderThread(CreateStatusFb, &sStatusFb);
    return sStatusFb;
}

namespace SecondScreen {

static void Draw(const BananaPanels::PanelRect& r) {
    if (sStatusFb < 0) { // nothing drawn yet: title screen / intro
        ImGui::SetCursorPos(ImVec2(r.w * 0.5f - 80.0f, r.h * 0.5f - 12.0f));
        ImGui::SetWindowFontScale(1.6f);
        ImGui::TextUnformatted("PaperBoat");
        return;
    }
    ImGui::SetCursorPos(ImVec2(0, 0));
    ImGui::Image(reinterpret_cast<ImTextureID>(gfx_get_framebuffer_texture(sStatusFb)), ImVec2(r.w, r.h),
                 ImVec2(0, 0), ImVec2(1, 1));
}

void Register() {
    BananaPanels::SecondScreenDraw = Draw;
}

} // namespace SecondScreen
