# Effect Modules Reference

Complete categorization of Effect modules for quick lookup.

All paths below are relative to `opensrc/repos/github.com/effect-ts/effect/` (or `https://github.com/effect-ts/effect/tree/main/` on GitHub).

## Core Effect System

| Module       | Path                                  | Description                                      |
| ------------ | ------------------------------------- | ------------------------------------------------ |
| Effect       | `packages/effect/src/Effect.ts`       | Core effect type with 470k+ lines of combinators |
| Layer        | `packages/effect/src/Layer.ts`        | Dependency injection and composition             |
| LayerMap     | `packages/effect/src/LayerMap.ts`     | Dynamic layer management                         |
| Context      | `packages/effect/src/Context.ts`      | Type-safe service context (Context.Tag)          |
| Scope        | `packages/effect/src/Scope.ts`        | Resource management and finalization             |
| Runtime      | `packages/effect/src/Runtime.ts`      | Effect execution and runners                     |
| RuntimeFlags | `packages/effect/src/RuntimeFlags.ts` | Runtime behavior flags                           |
| Exit         | `packages/effect/src/Exit.ts`         | Effect result type (Success/Failure)             |
| Cause        | `packages/effect/src/Cause.ts`        | Error cause tracking (Die, Fail, Interrupt)      |
| Supervisor   | `packages/effect/src/Supervisor.ts`   | Fiber supervision strategies                     |
| Scheduler    | `packages/effect/src/Scheduler.ts`    | Custom effect scheduling                         |

## STM (Software Transactional Memory)

Composable, atomic transactions for shared mutable state.

| Module           | Path                                      | Description                     |
| ---------------- | ----------------------------------------- | ------------------------------- |
| STM              | `packages/effect/src/STM.ts`              | Core STM transactions           |
| TRef             | `packages/effect/src/TRef.ts`             | Transactional refs              |
| TMap             | `packages/effect/src/TMap.ts`             | Transactional maps              |
| TArray           | `packages/effect/src/TArray.ts`           | Transactional arrays            |
| TSet             | `packages/effect/src/TSet.ts`             | Transactional sets              |
| TQueue           | `packages/effect/src/TQueue.ts`           | Transactional queues            |
| TPubSub          | `packages/effect/src/TPubSub.ts`          | Transactional pub/sub           |
| TDeferred        | `packages/effect/src/TDeferred.ts`        | Transactional deferred          |
| TSemaphore       | `packages/effect/src/TSemaphore.ts`       | Transactional semaphores        |
| TPriorityQueue   | `packages/effect/src/TPriorityQueue.ts`   | Transactional priority queues   |
| TReentrantLock   | `packages/effect/src/TReentrantLock.ts`   | Reentrant locks                 |
| TRandom          | `packages/effect/src/TRandom.ts`          | Transactional random            |
| TSubscriptionRef | `packages/effect/src/TSubscriptionRef.ts` | Transactional subscription refs |

## Request Batching & Caching

Automatic batching and deduplication of requests.

| Module          | Path                                     | Description              |
| --------------- | ---------------------------------------- | ------------------------ |
| Request         | `packages/effect/src/Request.ts`         | Request definitions      |
| RequestResolver | `packages/effect/src/RequestResolver.ts` | Batch request resolution |
| RequestBlock    | `packages/effect/src/RequestBlock.ts`    | Request blocking         |
| Cache           | `packages/effect/src/Cache.ts`           | Effectful caching        |
| ScopedCache     | `packages/effect/src/ScopedCache.ts`     | Scoped caching           |

## Data Types

| Module         | Path                                    | Description                             |
| -------------- | --------------------------------------- | --------------------------------------- |
| Option         | `packages/effect/src/Option.ts`         | Optional values (Some/None)             |
| Either         | `packages/effect/src/Either.ts`         | Success/failure (Right/Left)            |
| Data           | `packages/effect/src/Data.ts`           | Immutable data structures with equality |
| Chunk          | `packages/effect/src/Chunk.ts`          | Immutable, efficient arrays             |
| HashMap        | `packages/effect/src/HashMap.ts`        | Immutable hash maps                     |
| HashSet        | `packages/effect/src/HashSet.ts`        | Immutable hash sets                     |
| HashRing       | `packages/effect/src/HashRing.ts`       | Consistent hash ring                    |
| List           | `packages/effect/src/List.ts`           | Immutable linked lists                  |
| SortedMap      | `packages/effect/src/SortedMap.ts`      | Sorted immutable maps                   |
| SortedSet      | `packages/effect/src/SortedSet.ts`      | Sorted immutable sets                   |
| RedBlackTree   | `packages/effect/src/RedBlackTree.ts`   | Red-black tree                          |
| Trie           | `packages/effect/src/Trie.ts`           | Trie data structure                     |
| MutableHashMap | `packages/effect/src/MutableHashMap.ts` | Mutable hash maps                       |
| MutableHashSet | `packages/effect/src/MutableHashSet.ts` | Mutable hash sets                       |
| MutableList    | `packages/effect/src/MutableList.ts`    | Mutable linked lists                    |
| MutableRef     | `packages/effect/src/MutableRef.ts`     | Mutable references                      |

## Concurrency Primitives

| Module          | Path                                     | Description                 |
| --------------- | ---------------------------------------- | --------------------------- |
| Fiber           | `packages/effect/src/Fiber.ts`           | Lightweight threads         |
| FiberHandle     | `packages/effect/src/FiberHandle.ts`     | Single fiber management     |
| FiberMap        | `packages/effect/src/FiberMap.ts`        | Keyed fiber management      |
| FiberSet        | `packages/effect/src/FiberSet.ts`        | Fiber collection management |
| FiberRef        | `packages/effect/src/FiberRef.ts`        | Fiber-local state           |
| Ref             | `packages/effect/src/Ref.ts`             | Synchronized mutable refs   |
| SynchronizedRef | `packages/effect/src/SynchronizedRef.ts` | Effectful ref updates       |
| ScopedRef       | `packages/effect/src/ScopedRef.ts`       | Scoped refs                 |
| Queue           | `packages/effect/src/Queue.ts`           | Concurrent queues           |
| Deferred        | `packages/effect/src/Deferred.ts`        | Single-value async promises |
| Semaphore       | `packages/effect/src/Semaphore.ts`       | Concurrency limiting        |
| RateLimiter     | `packages/effect/src/RateLimiter.ts`     | Rate limiting               |
| Latch           | `packages/effect/src/Latch.ts`           | Countdown synchronization   |
| Pool            | `packages/effect/src/Pool.ts`            | Resource pooling            |
| KeyedPool       | `packages/effect/src/KeyedPool.ts`       | Keyed resource pools        |
| PubSub          | `packages/effect/src/PubSub.ts`          | Publish/subscribe           |

## Resource Management

| Module     | Path                                | Description             |
| ---------- | ----------------------------------- | ----------------------- |
| Scope      | `packages/effect/src/Scope.ts`      | Resource scoping        |
| Resource   | `packages/effect/src/Resource.ts`   | Managed resources       |
| RcMap      | `packages/effect/src/RcMap.ts`      | Reference-counted map   |
| RcRef      | `packages/effect/src/RcRef.ts`      | Reference-counted ref   |
| Reloadable | `packages/effect/src/Reloadable.ts` | Hot-reloadable services |

## Sensitive Data

| Module   | Path                              | Description                              |
| -------- | --------------------------------- | ---------------------------------------- |
| Redacted | `packages/effect/src/Redacted.ts` | Redacted sensitive values                |
| Secret   | `packages/effect/src/Secret.ts`   | Secret values (deprecated, use Redacted) |

## Streaming

| Module          | Path                                     | Description             |
| --------------- | ---------------------------------------- | ----------------------- |
| Stream          | `packages/effect/src/Stream.ts`          | Effectful streams       |
| Sink            | `packages/effect/src/Sink.ts`            | Stream consumers        |
| Channel         | `packages/effect/src/Channel.ts`         | Bidirectional streaming |
| SubscriptionRef | `packages/effect/src/SubscriptionRef.ts` | Observable refs         |
| Subscribable    | `packages/effect/src/Subscribable.ts`    | Subscribable interface  |
| Take            | `packages/effect/src/Take.ts`            | Stream chunks           |
| GroupBy         | `packages/effect/src/GroupBy.ts`         | Stream grouping         |
| Readable        | `packages/effect/src/Readable.ts`        | Readable streams        |
| StreamEmit      | `packages/effect/src/StreamEmit.ts`      | Stream emission         |

## Schema & Validation

| Module      | Path                                 | Description                |
| ----------- | ------------------------------------ | -------------------------- |
| Schema      | `packages/effect/src/Schema.ts`      | Data validation & encoding |
| SchemaAST   | `packages/effect/src/SchemaAST.ts`   | Schema AST representation  |
| ParseResult | `packages/effect/src/ParseResult.ts` | Parsing results            |
| JSONSchema  | `packages/effect/src/JSONSchema.ts`  | JSON Schema generation     |
| Arbitrary   | `packages/effect/src/Arbitrary.ts`   | Property-based testing     |
| Equivalence | `packages/effect/src/Equivalence.ts` | Value equivalence          |
| Order       | `packages/effect/src/Order.ts`       | Value ordering             |
| Predicate   | `packages/effect/src/Predicate.ts`   | Type predicates            |
| Pretty      | `packages/effect/src/Pretty.ts`      | Pretty printing schemas    |
| PrimaryKey  | `packages/effect/src/PrimaryKey.ts`  | Primary key extraction     |

## Time & Scheduling

| Module           | Path                                      | Description            |
| ---------------- | ----------------------------------------- | ---------------------- |
| Schedule         | `packages/effect/src/Schedule.ts`         | Retry/repeat schedules |
| ScheduleDecision | `packages/effect/src/ScheduleDecision.ts` | Schedule decisions     |
| ScheduleInterval | `packages/effect/src/ScheduleInterval.ts` | Schedule intervals     |
| Duration         | `packages/effect/src/Duration.ts`         | Time durations         |
| DateTime         | `packages/effect/src/DateTime.ts`         | Date/time handling     |
| Clock            | `packages/effect/src/Clock.ts`            | Time service           |
| Cron             | `packages/effect/src/Cron.ts`             | Cron expressions       |

## Configuration

| Module         | Path                                    | Description             |
| -------------- | --------------------------------------- | ----------------------- |
| Config         | `packages/effect/src/Config.ts`         | Type-safe configuration |
| ConfigProvider | `packages/effect/src/ConfigProvider.ts` | Configuration sources   |
| ConfigError    | `packages/effect/src/ConfigError.ts`    | Config error types      |

## Logging & Tracing

| Module    | Path                               | Description         |
| --------- | ---------------------------------- | ------------------- |
| Logger    | `packages/effect/src/Logger.ts`    | Structured logging  |
| LogLevel  | `packages/effect/src/LogLevel.ts`  | Log levels          |
| LogSpan   | `packages/effect/src/LogSpan.ts`   | Log spans           |
| Tracer    | `packages/effect/src/Tracer.ts`    | Distributed tracing |
| Metric    | `packages/effect/src/Metric.ts`    | Metrics collection  |
| MetricKey | `packages/effect/src/MetricKey.ts` | Metric identifiers  |

## Testing

| Module         | Path                                    | Description           |
| -------------- | --------------------------------------- | --------------------- |
| TestClock      | `packages/effect/src/TestClock.ts`      | Test time control     |
| TestContext    | `packages/effect/src/TestContext.ts`    | Test services         |
| TestServices   | `packages/effect/src/TestServices.ts`   | Mock services         |
| TestConfig     | `packages/effect/src/TestConfig.ts`     | Test configuration    |
| TestAnnotation | `packages/effect/src/TestAnnotation.ts` | Test annotations      |
| Arbitrary      | `packages/effect/src/Arbitrary.ts`      | FastCheck integration |

## Utilities

| Module     | Path                                | Description                               |
| ---------- | ----------------------------------- | ----------------------------------------- |
| Function   | `packages/effect/src/Function.ts`   | Function utilities (pipe, flow, identity) |
| Match      | `packages/effect/src/Match.ts`      | Pattern matching                          |
| Tuple      | `packages/effect/src/Tuple.ts`      | Tuple utilities                           |
| Struct     | `packages/effect/src/Struct.ts`     | Object utilities                          |
| Record     | `packages/effect/src/Record.ts`     | Record utilities                          |
| String     | `packages/effect/src/String.ts`     | String utilities                          |
| Number     | `packages/effect/src/Number.ts`     | Number utilities                          |
| Boolean    | `packages/effect/src/Boolean.ts`    | Boolean utilities                         |
| BigInt     | `packages/effect/src/BigInt.ts`     | BigInt utilities                          |
| BigDecimal | `packages/effect/src/BigDecimal.ts` | Decimal math                              |
| Array      | `packages/effect/src/Array.ts`      | Array utilities (100k+ lines)             |
| Iterable   | `packages/effect/src/Iterable.ts`   | Iterable utilities                        |
| Random     | `packages/effect/src/Random.ts`     | Random number generation                  |
| RegExp     | `packages/effect/src/RegExp.ts`     | Regular expressions                       |
| Encoding   | `packages/effect/src/Encoding.ts`   | Base64/hex encoding                       |
| Hash       | `packages/effect/src/Hash.ts`       | Hashing utilities                         |
| Equal      | `packages/effect/src/Equal.ts`      | Equality checking                         |
| Brand      | `packages/effect/src/Brand.ts`      | Branded types                             |
| Types      | `packages/effect/src/Types.ts`      | Type utilities                            |
| Unify      | `packages/effect/src/Unify.ts`      | Type unification                          |
| Graph      | `packages/effect/src/Graph.ts`      | Graph algorithms                          |

______________________________________________________________________

## Platform Package (`@effect/platform`)

Cross-platform abstractions for HTTP, FileSystem, processes, etc.

### HTTP Client

| Module             | Path                                          | Description        |
| ------------------ | --------------------------------------------- | ------------------ |
| HttpClient         | `packages/platform/src/HttpClient.ts`         | HTTP client        |
| HttpClientRequest  | `packages/platform/src/HttpClientRequest.ts`  | Request building   |
| HttpClientResponse | `packages/platform/src/HttpClientResponse.ts` | Response handling  |
| HttpClientError    | `packages/platform/src/HttpClientError.ts`    | Client errors      |
| FetchHttpClient    | `packages/platform/src/FetchHttpClient.ts`    | Fetch-based client |

### HTTP Server

| Module             | Path                                          | Description         |
| ------------------ | --------------------------------------------- | ------------------- |
| HttpServer         | `packages/platform/src/HttpServer.ts`         | HTTP server         |
| HttpServerRequest  | `packages/platform/src/HttpServerRequest.ts`  | Server requests     |
| HttpServerResponse | `packages/platform/src/HttpServerResponse.ts` | Server responses    |
| HttpServerError    | `packages/platform/src/HttpServerError.ts`    | Server errors       |
| HttpRouter         | `packages/platform/src/HttpRouter.ts`         | Request routing     |
| HttpMiddleware     | `packages/platform/src/HttpMiddleware.ts`     | Middleware          |
| HttpApp            | `packages/platform/src/HttpApp.ts`            | Application builder |

### HTTP API (Declarative)

| Module            | Path                                         | Description             |
| ----------------- | -------------------------------------------- | ----------------------- |
| HttpApi           | `packages/platform/src/HttpApi.ts`           | API definitions         |
| HttpApiBuilder    | `packages/platform/src/HttpApiBuilder.ts`    | API implementation      |
| HttpApiClient     | `packages/platform/src/HttpApiClient.ts`     | Typed API client        |
| HttpApiEndpoint   | `packages/platform/src/HttpApiEndpoint.ts`   | Endpoint definitions    |
| HttpApiGroup      | `packages/platform/src/HttpApiGroup.ts`      | Endpoint grouping       |
| HttpApiMiddleware | `packages/platform/src/HttpApiMiddleware.ts` | API middleware          |
| HttpApiSchema     | `packages/platform/src/HttpApiSchema.ts`     | API schemas             |
| HttpApiSecurity   | `packages/platform/src/HttpApiSecurity.ts`   | Security schemes        |
| HttpApiError      | `packages/platform/src/HttpApiError.ts`      | API errors              |
| HttpApiScalar     | `packages/platform/src/HttpApiScalar.ts`     | Scalar UI integration   |
| HttpApiSwagger    | `packages/platform/src/HttpApiSwagger.ts`    | Swagger UI              |
| OpenApi           | `packages/platform/src/OpenApi.ts`           | OpenAPI spec generation |

### HTTP Utilities

| Module           | Path                                        | Description             |
| ---------------- | ------------------------------------------- | ----------------------- |
| HttpBody         | `packages/platform/src/HttpBody.ts`         | Request/response bodies |
| Headers          | `packages/platform/src/Headers.ts`          | HTTP headers            |
| Cookies          | `packages/platform/src/Cookies.ts`          | Cookie handling         |
| Etag             | `packages/platform/src/Etag.ts`             | ETag handling           |
| Multipart        | `packages/platform/src/Multipart.ts`        | Multipart form data     |
| UrlParams        | `packages/platform/src/UrlParams.ts`        | URL parameters          |
| HttpMethod       | `packages/platform/src/HttpMethod.ts`       | HTTP methods            |
| HttpTraceContext | `packages/platform/src/HttpTraceContext.ts` | Trace context           |

### File System & Path

| Module     | Path                                  | Description     |
| ---------- | ------------------------------------- | --------------- |
| FileSystem | `packages/platform/src/FileSystem.ts` | File operations |
| Path       | `packages/platform/src/Path.ts`       | Path utilities  |

### Process & Terminal

| Module          | Path                                       | Description       |
| --------------- | ------------------------------------------ | ----------------- |
| Command         | `packages/platform/src/Command.ts`         | Process execution |
| CommandExecutor | `packages/platform/src/CommandExecutor.ts` | Command running   |
| Terminal        | `packages/platform/src/Terminal.ts`        | Terminal I/O      |

### Data Formats

| Module   | Path                                | Description            |
| -------- | ----------------------------------- | ---------------------- |
| Ndjson   | `packages/platform/src/Ndjson.ts`   | Newline-delimited JSON |
| MsgPack  | `packages/platform/src/MsgPack.ts`  | MessagePack encoding   |
| Template | `packages/platform/src/Template.ts` | Template rendering     |

### Networking

| Module       | Path                                    | Description           |
| ------------ | --------------------------------------- | --------------------- |
| Socket       | `packages/platform/src/Socket.ts`       | WebSocket/TCP sockets |
| SocketServer | `packages/platform/src/SocketServer.ts` | Socket server         |

### Workers & Storage

| Module        | Path                                     | Description       |
| ------------- | ---------------------------------------- | ----------------- |
| Worker        | `packages/platform/src/Worker.ts`        | Worker threads    |
| WorkerRunner  | `packages/platform/src/WorkerRunner.ts`  | Worker execution  |
| KeyValueStore | `packages/platform/src/KeyValueStore.ts` | Key-value storage |

### Platform Implementations

| Package                      | Path                             | Description            |
| ---------------------------- | -------------------------------- | ---------------------- |
| @effect/platform-node        | `packages/platform-node/`        | Node.js implementation |
| @effect/platform-node-shared | `packages/platform-node-shared/` | Shared Node.js code    |
| @effect/platform-browser     | `packages/platform-browser/`     | Browser implementation |
| @effect/platform-bun         | `packages/platform-bun/`         | Bun implementation     |

______________________________________________________________________

## CLI Package (`@effect/cli`)

Build type-safe command-line applications.

| Module          | Path                                  | Description             |
| --------------- | ------------------------------------- | ----------------------- |
| Command         | `packages/cli/src/Command.ts`         | Command definitions     |
| Args            | `packages/cli/src/Args.ts`            | Positional arguments    |
| Options         | `packages/cli/src/Options.ts`         | Command options/flags   |
| Prompt          | `packages/cli/src/Prompt.ts`          | Interactive prompts     |
| CliApp          | `packages/cli/src/CliApp.ts`          | Application builder     |
| CliConfig       | `packages/cli/src/CliConfig.ts`       | CLI configuration       |
| ConfigFile      | `packages/cli/src/ConfigFile.ts`      | Config file loading     |
| HelpDoc         | `packages/cli/src/HelpDoc.ts`         | Help documentation      |
| AutoCorrect     | `packages/cli/src/AutoCorrect.ts`     | Command auto-correction |
| ValidationError | `packages/cli/src/ValidationError.ts` | Validation errors       |

______________________________________________________________________

## RPC Package (`@effect/rpc`)

Type-safe remote procedure calls.

| Module           | Path                                   | Description           |
| ---------------- | -------------------------------------- | --------------------- |
| Rpc              | `packages/rpc/src/Rpc.ts`              | Core RPC definitions  |
| RpcClient        | `packages/rpc/src/RpcClient.ts`        | RPC client            |
| RpcServer        | `packages/rpc/src/RpcServer.ts`        | RPC server            |
| RpcGroup         | `packages/rpc/src/RpcGroup.ts`         | RPC endpoint grouping |
| RpcSchema        | `packages/rpc/src/RpcSchema.ts`        | RPC schemas           |
| RpcMiddleware    | `packages/rpc/src/RpcMiddleware.ts`    | RPC middleware        |
| RpcSerialization | `packages/rpc/src/RpcSerialization.ts` | Serialization         |
| RpcWorker        | `packages/rpc/src/RpcWorker.ts`        | Worker-based RPC      |
| RpcTest          | `packages/rpc/src/RpcTest.ts`          | RPC testing utilities |

______________________________________________________________________

## SQL Packages

| Package                         | Path                                | Description                |
| ------------------------------- | ----------------------------------- | -------------------------- |
| @effect/sql                     | `packages/sql/`                     | Core SQL abstractions      |
| @effect/sql-pg                  | `packages/sql-pg/`                  | PostgreSQL (postgres.js)   |
| @effect/sql-kysely              | `packages/sql-kysely/`              | Kysely integration         |
| @effect/sql-drizzle             | `packages/sql-drizzle/`             | Drizzle integration        |
| @effect/sql-mysql2              | `packages/sql-mysql2/`              | MySQL                      |
| @effect/sql-mssql               | `packages/sql-mssql/`               | SQL Server                 |
| @effect/sql-clickhouse          | `packages/sql-clickhouse/`          | ClickHouse                 |
| @effect/sql-libsql              | `packages/sql-libsql/`              | LibSQL/Turso               |
| @effect/sql-sqlite-node         | `packages/sql-sqlite-node/`         | SQLite (better-sqlite3)    |
| @effect/sql-sqlite-bun          | `packages/sql-sqlite-bun/`          | SQLite (bun:sqlite)        |
| @effect/sql-sqlite-wasm         | `packages/sql-sqlite-wasm/`         | SQLite WASM                |
| @effect/sql-sqlite-do           | `packages/sql-sqlite-do/`           | Cloudflare Durable Objects |
| @effect/sql-sqlite-react-native | `packages/sql-sqlite-react-native/` | React Native SQLite        |
| @effect/sql-d1                  | `packages/sql-d1/`                  | Cloudflare D1              |

______________________________________________________________________

## AI Packages

| Package                   | Path                          | Description            |
| ------------------------- | ----------------------------- | ---------------------- |
| @effect/ai                | `packages/ai/ai/`             | Core AI abstractions   |
| @effect/ai-openai         | `packages/ai/openai/`         | OpenAI integration     |
| @effect/ai-anthropic      | `packages/ai/anthropic/`      | Anthropic integration  |
| @effect/ai-google         | `packages/ai/google/`         | Google AI integration  |
| @effect/ai-amazon-bedrock | `packages/ai/amazon-bedrock/` | AWS Bedrock            |
| @effect/ai-openrouter     | `packages/ai/openrouter/`     | OpenRouter integration |

______________________________________________________________________

## Experimental Package (`@effect/experimental`)

Features under development - APIs may change.

| Module          | Path                                           | Description            |
| --------------- | ---------------------------------------------- | ---------------------- |
| Machine         | `packages/experimental/src/Machine.ts`         | State machines         |
| DevTools        | `packages/experimental/src/DevTools.ts`        | Developer tools        |
| Persistence     | `packages/experimental/src/Persistence.ts`     | Data persistence       |
| PersistedCache  | `packages/experimental/src/PersistedCache.ts`  | Persistent caching     |
| PersistedQueue  | `packages/experimental/src/PersistedQueue.ts`  | Persistent queues      |
| EventLog        | `packages/experimental/src/EventLog.ts`        | Event sourcing         |
| EventGroup      | `packages/experimental/src/EventGroup.ts`      | Event grouping         |
| EventJournal    | `packages/experimental/src/EventJournal.ts`    | Event journaling       |
| Reactivity      | `packages/experimental/src/Reactivity.ts`      | Reactive primitives    |
| Sse             | `packages/experimental/src/Sse.ts`             | Server-sent events     |
| VariantSchema   | `packages/experimental/src/VariantSchema.ts`   | Variant schemas        |
| RequestResolver | `packages/experimental/src/RequestResolver.ts` | Enhanced resolvers     |
| RateLimiter     | `packages/experimental/src/RateLimiter.ts`     | Enhanced rate limiting |

______________________________________________________________________

## Other Packages

| Package               | Path                      | Description               |
| --------------------- | ------------------------- | ------------------------- |
| @effect/cluster       | `packages/cluster/`       | Distributed computing     |
| @effect/opentelemetry | `packages/opentelemetry/` | OpenTelemetry integration |
| @effect/printer       | `packages/printer/`       | Pretty printing           |
| @effect/printer-ansi  | `packages/printer-ansi/`  | ANSI terminal printing    |
| @effect/typeclass     | `packages/typeclass/`     | Functional type classes   |
| @effect/vitest        | `packages/vitest/`        | Vitest testing utilities  |
| @effect/workflow      | `packages/workflow/`      | Durable workflows         |
