export function loadConfig(env = process.env) {
  return {
    host: env.ADMIN_HOST || "127.0.0.1",
    port: Number(env.ADMIN_PORT || 3000),
    apiKey: env.ADMIN_API_KEY || "replace-in-local-env",
    environment: env.APP_ENV || "development",
  };
}
