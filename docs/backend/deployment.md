# Deployment Checklist

This scaffold is not a production deployment package.

1. Pin and audit all dependency versions.
2. Replace local tickets and API keys with signed authentication, MFA, roles, and key rotation.
3. Use managed secrets; never store credentials in Git.
4. Add TLS between every service and restrict the operations network.
5. Introduce managed migrations, backups, restore tests, and data-retention rules.
6. Add cache, service discovery, message transport, idempotency, and replay protection.
7. Load-test room capacity, reconnects, timeouts, tournament settlement, and failure recovery.
8. Validate randomness and game configuration through independent review and reproducible simulations.
9. Add privacy workflows, age controls, regional feature flags, probability disclosure, and payment compliance.
10. Define monitoring, alerts, incident response, rollback, and disaster recovery.
