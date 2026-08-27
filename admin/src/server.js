import { createApp } from "./app.js";
import { loadConfig } from "./config.js";

const config = loadConfig();
const app = createApp();

app.listen(config.port, config.host, () => {
  console.log(`OceanRaid operations API listening on http://${config.host}:${config.port}`);
});
