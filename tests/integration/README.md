# Integration Tests

Add black-box tests here once the gateway, C++ room service, database, and operations API share a runnable local environment.

Minimum scenarios:

- authentication and expired room tickets;
- room capacity and duplicate joins;
- reconnect and idempotent settlement;
- tournament registration, scoring, ranking, and cancellation;
- database and message-service outages;
- configuration approval, audit, rollback, and concurrent updates;
- log redaction and privacy deletion;
- load and soak tests at the intended concurrent-player target.
