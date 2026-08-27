# Database

`schema.sql` defines a minimal MySQL 8 development schema. `seed-development.sql` contains only fictional catalog data.

Production requirements include managed migrations, encrypted connections, least-privilege accounts, tested backups, retention policies, monitoring, idempotency enforcement, and privacy deletion workflows. Never commit database dumps or player records.

The credit ledger is append-oriented. Corrections should be represented as new entries with a reason and audit record instead of rewriting financial history.
