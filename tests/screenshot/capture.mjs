// Opens the web build in headless Chromium with WebGPU enabled and screenshots the canvas.
//
// Usage: node capture.mjs <url> <out.png> [timeoutMs=120000]
//
// Contract with the web shell (web/index.html, created in M7):
//   - the page sets  window.__BLENDER_READY__ = true  when the first frame is drawn
//   - the page sets  window.__BLENDER_ERROR__ = "<msg>" on a fatal error
//   - the Blender canvas has id="canvas"
//
// CI runners have no GPU: Chromium falls back to a software WebGPU adapter (SwiftShader).
// It is slow but correct enough for pixel tests. The flags below may need adjusting with
// new Chromium versions — if WebGPU is unavailable, log navigator.gpu and the adapter info.
import { chromium } from "playwright";

const [url, outPath, timeoutArg] = process.argv.slice(2);
if (!url || !outPath) {
  console.error("usage: node capture.mjs <url> <out.png> [timeoutMs]");
  process.exit(2);
}
const timeout = Number(timeoutArg ?? 120000);

const browser = await chromium.launch({
  args: [
    "--enable-unsafe-webgpu",
    "--enable-features=Vulkan",
    "--use-vulkan=swiftshader",
    "--use-webgpu-adapter=swiftshader",
    "--disable-vulkan-surface",
    "--ignore-gpu-blocklist",
  ],
});
const page = await browser.newPage({ viewport: { width: 512, height: 512 } });
page.on("console", (m) => console.log(`[page:${m.type()}] ${m.text()}`));
page.on("pageerror", (e) => console.log(`[page:error] ${e.message}`));

let code = 0;
try {
  await page.goto(url, { waitUntil: "load" });
  const info = await page.evaluate(async () => {
    if (!navigator.gpu) return "navigator.gpu MISSING";
    const a = await navigator.gpu.requestAdapter();
    return a ? `adapter OK` : "requestAdapter returned null";
  });
  console.log(`WebGPU: ${info}`);

  await page.waitForFunction(
    () => window.__BLENDER_READY__ === true || typeof window.__BLENDER_ERROR__ === "string",
    null,
    { timeout },
  );
  const err = await page.evaluate(() => window.__BLENDER_ERROR__);
  if (err) throw new Error(`page reported error: ${err}`);

  await page.locator("#canvas").screenshot({ path: outPath });
  console.log(`CAPTURED ${outPath}`);
} catch (e) {
  console.error(`CAPTURE FAILED: ${e.message}`);
  await page.screenshot({ path: outPath.replace(/\.png$/, "-page-on-fail.png") }).catch(() => {});
  code = 1;
} finally {
  await browser.close();
}
process.exit(code);
