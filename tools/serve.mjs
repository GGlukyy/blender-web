// Tiny static file server with the headers a threaded wasm app needs.
// Without COOP/COEP the browser disables SharedArrayBuffer → no threads → Blender won't start.
//
// Usage: node tools/serve.mjs [dir=web] [port=8080]
import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { extname, join, normalize, resolve } from "node:path";

const root = resolve(process.argv[2] ?? "web");
const port = Number(process.argv[3] ?? 8080);

const types = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".json": "application/json",
  ".data": "application/octet-stream",
  ".blend": "application/octet-stream",
  ".png": "image/png",
  ".css": "text/css",
};

createServer(async (req, res) => {
  const headers = {
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "require-corp",
    "Cross-Origin-Resource-Policy": "same-origin",
    "Cache-Control": "no-store",
  };
  try {
    const urlPath = decodeURIComponent(new URL(req.url, "http://x").pathname);
    let file = normalize(join(root, urlPath));
    if (!file.startsWith(root)) throw new Error("outside root");
    if ((await stat(file)).isDirectory()) file = join(file, "index.html");
    const body = await readFile(file);
    res.writeHead(200, { ...headers, "Content-Type": types[extname(file)] ?? "application/octet-stream" });
    res.end(body);
  } catch {
    res.writeHead(404, headers);
    res.end("not found");
  }
}).listen(port, () => {
  console.log(`serving ${root} on http://localhost:${port} (COOP/COEP on)`);
});
