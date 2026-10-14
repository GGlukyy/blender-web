// Compares a captured PNG with a reference PNG.
//
// Usage: node compare.mjs <actual.png> <reference.png> <diff-out.png> [maxDiffPercent=2]
//
// The default tolerance (2 %) is the contract for M10. Do NOT raise it to make a test pass
// (CLAUDE.md rule 4). Changing it requires an ADR approved by Lukáš.
import { readFileSync, writeFileSync } from "node:fs";
import pixelmatch from "pixelmatch";
import { PNG } from "pngjs";

const [actualPath, refPath, diffPath, maxArg] = process.argv.slice(2);
if (!actualPath || !refPath || !diffPath) {
  console.error("usage: node compare.mjs <actual.png> <reference.png> <diff.png> [maxDiffPercent]");
  process.exit(2);
}
const maxPercent = Number(maxArg ?? 2);

const actual = PNG.sync.read(readFileSync(actualPath));
const ref = PNG.sync.read(readFileSync(refPath));
if (actual.width !== ref.width || actual.height !== ref.height) {
  console.error(`SIZE MISMATCH: actual ${actual.width}x${actual.height}, reference ${ref.width}x${ref.height}`);
  process.exit(1);
}

const diff = new PNG({ width: ref.width, height: ref.height });
const bad = pixelmatch(actual.data, ref.data, diff.data, ref.width, ref.height, { threshold: 0.1 });
writeFileSync(diffPath, PNG.sync.write(diff));

const percent = (100 * bad) / (ref.width * ref.height);
console.log(`DIFF ${percent.toFixed(3)} % (${bad} px), limit ${maxPercent} % → diff image: ${diffPath}`);
if (percent > maxPercent) {
  console.log("COMPARE FAIL");
  process.exit(1);
}
console.log("COMPARE OK");
