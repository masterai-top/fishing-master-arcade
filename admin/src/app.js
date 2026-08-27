import express from "express";
import helmet from "helmet";

import { requireApiKey } from "./auth.js";
import { loadConfig } from "./config.js";
import { healthRouter } from "./routes/health.js";
import { createModesRouter } from "./routes/modes.js";

export function createApp(env = process.env) {
  const config = loadConfig(env);
  const app = express();
  app.disable("x-powered-by");
  app.use(helmet());
  app.use(express.json({ limit: "64kb" }));
  app.use(healthRouter);
  app.use("/v1/admin", requireApiKey(config.apiKey), createModesRouter());
  return app;
}
