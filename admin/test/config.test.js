import assert from "node:assert/strict";
import test from "node:test";

import { loadConfig } from "../src/config.js";

test("loads explicit environment values", () => {
  const config = loadConfig({
    ADMIN_HOST: "0.0.0.0",
    ADMIN_PORT: "3100",
    ADMIN_API_KEY: "development-test-key",
    APP_ENV: "test",
  });
  assert.equal(config.host, "0.0.0.0");
  assert.equal(config.port, 3100);
  assert.equal(config.environment, "test");
});
