export function requireApiKey(expectedKey) {
  return function apiKeyMiddleware(req, res, next) {
    const suppliedKey = req.header("x-admin-api-key");
    if (!expectedKey || expectedKey === "replace-in-local-env" || suppliedKey !== expectedKey) {
      return res.status(401).json({ error: "unauthorized" });
    }
    return next();
  };
}
