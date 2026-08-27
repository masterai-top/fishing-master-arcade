import { Router } from "express";
import { z } from "zod";

import { modes } from "../modeCatalog.js";

const draftSchema = z.object({
  modeId: z.string().min(2).max(40),
  enabled: z.boolean(),
  changeReason: z.string().min(10).max(500),
});

export function createModesRouter() {
  const router = Router();

  router.get("/modes", (_req, res) => res.json({ items: modes }));

  router.post("/configuration-drafts", (req, res) => {
    const parsed = draftSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: "invalid_request", details: parsed.error.issues });
    }

    // Persist to an audited approval workflow in a production implementation.
    return res.status(202).json({
      status: "pending_review",
      draft: parsed.data,
      createdAt: new Date().toISOString(),
    });
  });

  return router;
}
