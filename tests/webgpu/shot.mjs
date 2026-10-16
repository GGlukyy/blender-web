// Serves <dir>, opens index.html in headless Chrome with WebGPU (SwiftShader), waits for a console line
// matching <ready-regex>, then screenshots the <canvas> into <out.png>.
// Usage: node shot.mjs <dir> <out.png> <ready-regex> [port]
import { chromium } from "../screenshot/node_modules/playwright/index.mjs";
import { spawn } from "node:child_process";
const [, , dir, out, ready, port = "8098"] = process.argv;
const server = spawn("node", ["tools/serve.mjs", dir, port], { stdio: "inherit" });
await new Promise((r) => setTimeout(r, 1000));
let code = 1;
try {
  const browser = await chromium.launch({ headless: process.env.HEADFUL ? false : true,
    channel: "chrome",
    args: ["--no-sandbox", "--enable-unsafe-webgpu", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist","--enable-gpu","--use-angle=gl-egl","--use-vulkan=swiftshader","--enable-features=Vulkan"],
  });
  const page = await browser.newPage();
  let seen = false;
  page.on("console", (m) => { console.log("[console]", m.text().slice(0, 300)); if (new RegExp(ready).test(m.text())) seen = true; });
  page.on("pageerror", (e) => console.log("[pageerror]", String(e).slice(0, 500)));
  await page.goto(`http://localhost:${port}/index.html`);
  for (let i = 0; i < 600 && !seen; i++) await new Promise((r) => setTimeout(r, 500));
  if (seen) {
    await new Promise((r) => setTimeout(r, 1500));
    await page.locator("canvas").first().screenshot({ path: out });
    code = 0;
  }
  await browser.close();
} finally { server.kill(); }
process.exit(code);
