# Backend Architecture

```text
Cocos client
    |
    v
Python gateway (HTTP, authentication boundary, room catalog)
    |
    +--> C++ room server (real-time state and fishing engine)
    +--> tournament and ranking services
    +--> MySQL, cache, message bus and service discovery

Node.js operations API
    |
    +--> reviewed configuration drafts
    +--> room and mode visibility
    +--> immutable audit records
```

## Ownership boundaries

The Python gateway validates external requests and issues short-lived room tickets. The C++ service owns authoritative room and shot state. The Node.js service exposes administration endpoints behind separate authentication and should never be reachable from the public game network.

Production implementations need a shared protocol definition, durable service discovery, ticket verification, replay protection, rate limiting, distributed tracing, time synchronization, and explicit failure recovery.

## Fairness boundary

Game probability configuration must be versioned, simulated, approved, and audited. Configuration should apply to a documented game version or room class, not secretly target individual players. Administrative changes require a reason, reviewer, activation window, and rollback plan.
