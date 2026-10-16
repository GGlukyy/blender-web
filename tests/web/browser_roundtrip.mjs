// Opens out/web/index.html in headless Chrome (served with COOP/COEP), waits for Blender to finish,
// writes the produced .blend to the path in argv[2]. Prints log lines.
import { chromium } from "../screenshot/node_modules/playwright/index.mjs";
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";

const [, , dir, outBlend, port = "8099"] = process.argv;
const server = spawn("node", ["tools/serve.mjs", dir, port], { stdio: "inherit" });
await new Promise((r) => setTimeout(r, 1000));
let code = 1;
try {
  const browser = await chromium.launch({
    executablePath: process.env.CHROME ?? "/usr/bin/google-chrome",
    args: ["--no-sandbox", "--enable-features=WebAssemblyMemory64,SharedArrayBuffer", "--js-flags=--experimental-wasm-memory64"],
  });
  const page = await browser.newPage();
  page.on("console", (m) => console.log("[console]", m.text().slice(0, 300)));
  page.on("pageerror", (e) => console.log("[pageerror]", String(e).slice(0, 500)));
  await page.goto(`http://localhost:${port}/index.html`);
  await page.waitForFunction(() => window.__done === true, null, { timeout: 600000 });
  const res = await page.evaluate(() => window.__result ?? null);
  const lines = await page.evaluate(() => window.__lines.join("\n"));
  console.log(lines.split("\n").filter((l) => /WEB|Read blend|ABORT|Error/.test(l)).join("\n"));
  if (res) { writeFileSync(outBlend, Buffer.from(res)); console.log("saved", outBlend, res.length, "bytes"); code = 0; }
  await browser.close();
} finally { server.kill(); }
process.exit(code);
