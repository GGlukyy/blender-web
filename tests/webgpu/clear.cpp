// M8 de-risk: wasm64 + emdawnwebgpu: get a device, clear the canvas to #FF00FF.
#include <emscripten/emscripten.h>
#include <emscripten/html5.h>
#include <webgpu/webgpu.h>
#include <cstdio>

static WGPUInstance inst;
static WGPUDevice dev;
static WGPUSurface surf;
static WGPUQueue queue;

static void frame()
{
  WGPUSurfaceTexture st;
  wgpuSurfaceGetCurrentTexture(surf, &st);
  if (!st.texture) return;
  WGPUTextureView view = wgpuTextureCreateView(st.texture, nullptr);
  WGPUCommandEncoder enc = wgpuDeviceCreateCommandEncoder(dev, nullptr);
  WGPURenderPassColorAttachment ca = {};
  ca.view = view;
  ca.loadOp = WGPULoadOp_Clear;
  ca.storeOp = WGPUStoreOp_Store;
  ca.depthSlice = WGPU_DEPTH_SLICE_UNDEFINED;
  ca.clearValue = {1.0, 0.0, 1.0, 1.0};
  WGPURenderPassDescriptor rp = {};
  rp.colorAttachmentCount = 1;
  rp.colorAttachments = &ca;
  WGPURenderPassEncoder pass = wgpuCommandEncoderBeginRenderPass(enc, &rp);
  wgpuRenderPassEncoderEnd(pass);
  WGPUCommandBuffer cb = wgpuCommandEncoderFinish(enc, nullptr);
  wgpuQueueSubmit(queue, 1, &cb);
  static bool once = false;
  if (!once) { once = true; printf("WEBGPU CLEAR SUBMITTED\n"); }
}

static void on_device(WGPURequestDeviceStatus s, WGPUDevice d, WGPUStringView, void *, void *)
{
  if (s != WGPURequestDeviceStatus_Success) { printf("device fail\n"); return; }
  dev = d;
  queue = wgpuDeviceGetQueue(dev);
  WGPUEmscriptenSurfaceSourceCanvasHTMLSelector src = {};
  src.chain.sType = WGPUSType_EmscriptenSurfaceSourceCanvasHTMLSelector;
  src.selector = {"#canvas", WGPU_STRLEN};
  WGPUSurfaceDescriptor sd = {};
  sd.nextInChain = &src.chain;
  surf = wgpuInstanceCreateSurface(inst, &sd);
  WGPUSurfaceConfiguration cfg = {};
  cfg.device = dev;
  cfg.format = WGPUTextureFormat_RGBA8Unorm;
  cfg.usage = WGPUTextureUsage_RenderAttachment;
  cfg.width = 256;
  cfg.height = 256;
  cfg.alphaMode = WGPUCompositeAlphaMode_Opaque;
  cfg.presentMode = WGPUPresentMode_Fifo;
  emscripten_set_canvas_element_size("#canvas", 256, 256);
  wgpuSurfaceConfigure(surf, &cfg);
  emscripten_set_main_loop(frame, 0, 0);
}

static void on_adapter(WGPURequestAdapterStatus s, WGPUAdapter a, WGPUStringView, void *, void *)
{
  if (s != WGPURequestAdapterStatus_Success) { printf("adapter fail\n"); return; }
  WGPURequestDeviceCallbackInfo ci = {};
  ci.mode = WGPUCallbackMode_AllowSpontaneous;
  ci.callback = on_device;
  wgpuAdapterRequestDevice(a, nullptr, ci);
}

int main()
{
  inst = wgpuCreateInstance(nullptr);
  WGPURequestAdapterCallbackInfo ci = {};
  ci.mode = WGPUCallbackMode_AllowSpontaneous;
  ci.callback = on_adapter;
  wgpuInstanceRequestAdapter(inst, nullptr, ci);
  return 0;
}
