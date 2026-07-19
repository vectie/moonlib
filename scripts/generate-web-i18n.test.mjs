import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";
import vm from "node:vm";

const generator = new URL("./generate-web-i18n.mjs", import.meta.url);

test("generated runtime exposes keyed messages and content boundaries", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "moonsuite-i18n-"));
  const locales = path.join(root, "locales");
  const output = path.join(root, "runtime.js");
  fs.mkdirSync(locales);
  fs.writeFileSync(
    path.join(locales, "en-US.json"),
    JSON.stringify({ "test.greeting": "Hello {name}", "test.items": "{count} items" }),
  );
  fs.writeFileSync(
    path.join(locales, "zh-Hans.json"),
    JSON.stringify({ "test.greeting": "你好，{name}", "test.items": "{count} 项" }),
  );

  const generated = spawnSync(process.execPath, [generator.pathname, locales, output], {
    encoding: "utf8",
  });
  assert.equal(generated.status, 0, generated.stderr);
  const source = fs.readFileSync(output, "utf8");
  assert.match(source, /window\.MoonSuiteI18n/);
  assert.match(source, /data-i18n-params/);
  assert.match(source, /data-i18n-scope/);
  assert.match(source, /WINDOW_NAME_PREFIX/);
  assert.match(source, /zhHansTemplates/);
  assert.match(source, /compileTemplate/);
  assert.match(source, /characterData: true/);
  assert.doesNotThrow(() => new Function(source));

  const context = {
    URLSearchParams,
    document: {
      cookie: "",
      readyState: "loading",
      addEventListener() {},
    },
    localStorage: {
      getItem() { return null; },
      setItem() {},
    },
    location: { search: "?locale=zh-Hans", reload() {} },
    navigator: { language: "en-US", languages: ["en-US"] },
    window: { name: "" },
  };
  vm.createContext(context);
  vm.runInContext(`${source}\nglobalThis.translateForTest = translateText;`, context);
  assert.equal(context.translateForTest("3 items"), "3 项");
});
