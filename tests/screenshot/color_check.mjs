// M8 helper: checks that the center pixel of a PNG has the expected color.
// Usage: node color_check.mjs <image.png> <#RRGGBB> [tolerance=2]
import { readFileSync } from "node:fs";
import { PNG } from "pngjs";

const [path, hex, tolArg] = process.argv.slice(2);
const tol = Number(tolArg ?? 2);
const img = PNG.sync.read(readFileSync(path));
const i = ((img.height >> 1) * img.width + (img.width >> 1)) * 4;
const got = [img.data[i], img.data[i + 1], img.data[i + 2]];
const want = [1, 3, 5].map((k) => parseInt(hex.slice(k, k + 2), 16));
const ok = got.every((v, k) => Math.abs(v - want[k]) <= tol);
console.log(`center pixel rgb(${got.join(",")}) vs ${hex} → ${ok ? "COLOR OK" : "COLOR FAIL"}`);
process.exit(ok ? 0 : 1);
