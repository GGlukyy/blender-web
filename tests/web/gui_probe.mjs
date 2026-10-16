// Probe (not a CI stage): runs Blender in GUI mode in headless Chrome, prints console + stack. Usage: cp web/gui.html out/web/ && node tests/web/gui_probe.mjs
import { chromium } from "../screenshot/node_modules/playwright/index.mjs";
import { spawn } from "node:child_process";
const server = spawn("node", ["tools/serve.mjs", "out/webdbg", "8097"], { stdio: "ignore" });
await new Promise(r=>setTimeout(r,1000));
const b = await chromium.launch({channel:"chrome", args:["--no-sandbox","--enable-unsafe-webgpu","--enable-unsafe-swiftshader","--ignore-gpu-blocklist","--enable-gpu","--use-angle=gl-egl","--use-vulkan=swiftshader","--enable-features=Vulkan"]});
const p = await b.newPage();
p.on("console", m=>console.log("[c]", m.text().slice(0,250)));
p.on("pageerror", e=>console.log("[err]", e.stack || String(e)));
await p.goto("http://localhost:8097/gui.html");
await new Promise(r=>setTimeout(r, 40000));
await p.screenshot({path:"out/webdbg/gui.png"});
await b.close(); server.kill();
