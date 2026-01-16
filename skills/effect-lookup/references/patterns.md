# Effect Common Patterns

Quick reference for Effect patterns used throughout the codebase.

## Effect.gen (Generator Syntax)

The primary way to write sequential Effect code:

```typescript
import { Effect } from "effect"

const program = Effect.gen(function* () {
  const user = yield* getUser(userId)
  const profile = yield* getProfile(user.id)
  return { user, profile }
})
```

**Source**: `docs/effect/packages/effect/src/Effect.ts` (search for `export const gen`)

## Service Definition (Context.Tag)

Define services with type-safe dependency injection:

```typescript
import { Context, Effect, Layer } from "effect"

// Define the service interface
class UserRepo extends Context.Tag("UserRepo")<
  UserRepo,
  {
    readonly findById: (id: string) => Effect.Effect<User, NotFoundError>
    readonly save: (user: User) => Effect.Effect<void>
  }
>() {}

// Create a live implementation
const UserRepoLive = Layer.succeed(UserRepo, {
  findById: (id) => Effect.succeed({ id, name: "John" }),
  save: (user) => Effect.void,
})
```

**Source**: `docs/effect/packages/effect/src/Context.ts`

## Layer Composition

Compose layers for dependency injection:

```typescript
import { Layer } from "effect"

// Vertical composition (dependency chain)
const AppLayer = UserRepoLive.pipe(
  Layer.provide(DatabaseLive),
  Layer.provide(ConfigLive)
)

// Horizontal composition (merge independent layers)
const ServicesLayer = Layer.mergeAll(
  UserRepoLive,
  LoggerLive,
  CacheLive
)

// Provide to program
const runnable = program.pipe(Effect.provide(AppLayer))
```

**Source**: `docs/effect/packages/effect/src/Layer.ts`

## Error Handling

### Tagged Errors with Data.TaggedError

```typescript
import { Data, Effect } from "effect"

class NotFoundError extends Data.TaggedError("NotFoundError")<{
  readonly id: string
}> {}

class ValidationError extends Data.TaggedError("ValidationError")<{
  readonly message: string
}> {}

// Use in Effect
const getUser = (id: string) =>
  Effect.fail(new NotFoundError({ id }))
```

### Catch Specific Errors

```typescript
program.pipe(
  Effect.catchTag("NotFoundError", (e) =>
    Effect.succeed(defaultUser)
  ),
  Effect.catchTags({
    "NotFoundError": (e) => Effect.succeed(defaultUser),
    "ValidationError": (e) => Effect.fail(new AppError(e.message)),
  })
)
```

**Source**: `docs/effect/packages/effect/src/Data.ts`, `docs/effect/packages/effect/src/Effect.ts`

## Schema Validation

### Define Schemas

```typescript
import { Schema } from "effect"

const User = Schema.Struct({
  id: Schema.String,
  email: Schema.String.pipe(Schema.pattern(/@/)),
  age: Schema.Number.pipe(Schema.int(), Schema.positive()),
  role: Schema.Literal("admin", "user"),
  createdAt: Schema.DateFromString,
})

type User = Schema.Schema.Type<typeof User>
```

### Decode/Encode

```typescript
// Parse with Effect
const parseUser = Schema.decodeUnknown(User)
const result = parseUser(rawData) // Effect<User, ParseError>

// Sync parsing
const user = Schema.decodeUnknownSync(User)(rawData)

// Encode back
const encode = Schema.encodeSync(User)
const json = encode(user)
```

**Source**: `docs/effect/packages/effect/src/Schema.ts`

## HTTP APIs (Platform)

### Define API Specification

```typescript
import { HttpApi, HttpApiEndpoint, HttpApiGroup } from "@effect/platform"

const UsersApi = HttpApiGroup.make("users").pipe(
  HttpApiGroup.add(
    HttpApiEndpoint.get("getById", "/users/:id").pipe(
      HttpApiEndpoint.setSuccess(User),
      HttpApiEndpoint.setError(NotFoundError)
    )
  ),
  HttpApiGroup.add(
    HttpApiEndpoint.post("create", "/users").pipe(
      HttpApiEndpoint.setPayload(CreateUserRequest),
      HttpApiEndpoint.setSuccess(User)
    )
  )
)
```

### Implement API

```typescript
import { HttpApiBuilder } from "@effect/platform"

const UsersApiLive = HttpApiBuilder.group(MyApi, "users", (handlers) =>
  handlers.pipe(
    HttpApiBuilder.handle("getById", ({ path }) =>
      Effect.gen(function* () {
        const repo = yield* UserRepo
        return yield* repo.findById(path.id)
      })
    ),
    HttpApiBuilder.handle("create", ({ payload }) =>
      Effect.gen(function* () {
        const repo = yield* UserRepo
        return yield* repo.save(payload)
      })
    )
  )
)
```

**Source**: `docs/effect/packages/platform/src/HttpApi.ts`, `docs/effect/packages/platform/src/HttpApiBuilder.ts`

## Concurrency Patterns

### Parallel Execution

```typescript
// Run effects in parallel
const results = yield* Effect.all([
  fetchUser(1),
  fetchUser(2),
  fetchUser(3),
], { concurrency: "unbounded" })

// Parallel with limit
const results = yield* Effect.all(effects, { concurrency: 3 })

// Parallel, fail fast
const results = yield* Effect.all(effects, { mode: "either" })
```

### FiberSet for Dynamic Concurrency

```typescript
import { FiberSet } from "effect"

const program = Effect.gen(function* () {
  const set = yield* FiberSet.make<never, void>()

  // Add fibers dynamically
  yield* FiberSet.add(set, myEffect1)
  yield* FiberSet.add(set, myEffect2)

  // Wait for all
  yield* FiberSet.join(set)
})
```

**Source**: `docs/effect/packages/effect/src/FiberSet.ts`

## Resource Management

### Scoped Resources

```typescript
import { Effect, Scope } from "effect"

const acquireConnection = Effect.acquireRelease(
  Effect.sync(() => openConnection()),
  (conn) => Effect.sync(() => conn.close())
)

// Use in scoped context
const program = Effect.scoped(
  Effect.gen(function* () {
    const conn = yield* acquireConnection
    return yield* conn.query("SELECT * FROM users")
  })
)
```

**Source**: `docs/effect/packages/effect/src/Scope.ts`

## Retry & Scheduling

### Retry with Schedule

```typescript
import { Effect, Schedule } from "effect"

// Exponential backoff
const policy = Schedule.exponential("100 millis").pipe(
  Schedule.compose(Schedule.recurs(5))
)

const resilientEffect = myEffect.pipe(
  Effect.retry(policy)
)

// Retry specific errors
const selective = myEffect.pipe(
  Effect.retry({
    schedule: policy,
    while: (error) => error._tag === "NetworkError"
  })
)
```

**Source**: `docs/effect/packages/effect/src/Schedule.ts`

## Configuration

### Type-safe Config

```typescript
import { Config, Effect } from "effect"

const config = Config.all({
  host: Config.string("DB_HOST"),
  port: Config.number("DB_PORT").pipe(Config.withDefault(5432)),
  password: Config.redacted("DB_PASSWORD"),
  ssl: Config.boolean("DB_SSL").pipe(Config.withDefault(false)),
})

const program = Effect.gen(function* () {
  const { host, port, password, ssl } = yield* config
  // ...
})
```

**Source**: `docs/effect/packages/effect/src/Config.ts`

## Testing Patterns

### Test with Effect.provide

```typescript
import { Effect, Layer } from "effect"

// Mock implementation
const UserRepoTest = Layer.succeed(UserRepo, {
  findById: () => Effect.succeed(mockUser),
  save: () => Effect.void,
})

// Test
const result = await Effect.runPromise(
  program.pipe(Effect.provide(UserRepoTest))
)
```

### TestClock for Time-based Tests

```typescript
import { Effect, TestClock } from "effect"

const test = Effect.gen(function* () {
  const fiber = yield* Effect.fork(Effect.sleep("1 hour"))
  yield* TestClock.adjust("1 hour")
  yield* Fiber.join(fiber)
})
```

**Source**: `docs/effect/packages/effect/src/TestClock.ts`

## STM (Software Transactional Memory)

Composable atomic transactions for shared mutable state.

### Basic STM Transaction

```typescript
import { Effect, STM, TRef } from "effect"

const program = Effect.gen(function* () {
  // Create transactional refs
  const balance1 = yield* TRef.make(100)
  const balance2 = yield* TRef.make(0)

  // Atomic transfer
  yield* STM.commit(
    STM.gen(function* () {
      const amount = 50
      const current = yield* TRef.get(balance1)
      if (current < amount) {
        return yield* STM.fail("Insufficient funds")
      }
      yield* TRef.update(balance1, (n) => n - amount)
      yield* TRef.update(balance2, (n) => n + amount)
    })
  )
})
```

### TMap for Transactional Maps

```typescript
import { STM, TMap } from "effect"

const program = STM.gen(function* () {
  const map = yield* TMap.make<string, number>()
  yield* TMap.set(map, "a", 1)
  yield* TMap.set(map, "b", 2)
  const value = yield* TMap.get(map, "a")
  return value // Option<number>
})
```

**Source**: `docs/effect/packages/effect/src/STM.ts`, `docs/effect/packages/effect/src/TRef.ts`

## Request Batching & Caching

Automatic batching and deduplication of data fetching.

### Define Requests

```typescript
import { Request, RequestResolver, Effect } from "effect"

// Define a request type
interface GetUser extends Request.Request<User, NotFoundError> {
  readonly _tag: "GetUser"
  readonly id: string
}

const GetUser = Request.tagged<GetUser>("GetUser")

// Define a batched resolver
const UserResolver = RequestResolver.makeBatched(
  (requests: ReadonlyArray<GetUser>) =>
    Effect.gen(function* () {
      const ids = requests.map((r) => r.id)
      const users = yield* fetchUsersByIds(ids)

      return requests.map((request) => {
        const user = users.find((u) => u.id === request.id)
        return user
          ? Request.succeed(request, user)
          : Request.fail(request, new NotFoundError({ id: request.id }))
      })
    })
)
```

### Use Requests

```typescript
const getUser = (id: string) =>
  Effect.request(GetUser({ id }), UserResolver)

// These will be batched automatically
const program = Effect.gen(function* () {
  const [user1, user2, user3] = yield* Effect.all([
    getUser("1"),
    getUser("2"),
    getUser("3"),
  ])
  return [user1, user2, user3]
})
```

**Source**: `docs/effect/packages/effect/src/Request.ts`, `docs/effect/packages/effect/src/RequestResolver.ts`

## RateLimiter

Control the rate of effect execution.

```typescript
import { Effect, RateLimiter } from "effect"

const program = Effect.gen(function* () {
  // Create a rate limiter: 10 requests per second
  const limiter = yield* RateLimiter.make({
    limit: 10,
    interval: "1 second"
  })

  // Wrap effects with rate limiting
  const limited = RateLimiter.withCost(limiter, 1)(myEffect)

  // Or use as middleware
  yield* myEffect.pipe(limiter)
})
```

**Source**: `docs/effect/packages/effect/src/RateLimiter.ts`

## Reloadable Services

Hot-reload services without restarting.

```typescript
import { Effect, Layer, Reloadable } from "effect"

// Make a service reloadable
const ReloadableConfig = Reloadable.make(
  ConfigService,
  () => loadConfigFromFile()
)

// In your program
const program = Effect.gen(function* () {
  const reloadable = yield* Reloadable.tag(ConfigService)

  // Get current config
  const config = yield* Reloadable.get(reloadable)

  // Reload when needed
  yield* Reloadable.reload(reloadable)
})
```

**Source**: `docs/effect/packages/effect/src/Reloadable.ts`

## FiberHandle/FiberMap/FiberSet

Manage dynamic collections of fibers.

### FiberHandle (Single Fiber)

```typescript
import { Effect, FiberHandle } from "effect"

const program = Effect.gen(function* () {
  const handle = yield* FiberHandle.make<never, void>()

  // Run a fiber, replacing any previous one
  yield* FiberHandle.run(handle, longRunningEffect)

  // Later: interrupt and replace
  yield* FiberHandle.run(handle, newEffect)

  // Clean up
  yield* FiberHandle.clear(handle)
})
```

### FiberMap (Keyed Fibers)

```typescript
import { Effect, FiberMap } from "effect"

const program = Effect.gen(function* () {
  const map = yield* FiberMap.make<string, never, void>()

  // Run fibers by key
  yield* FiberMap.run(map, "task-1", effect1)
  yield* FiberMap.run(map, "task-2", effect2)

  // Running same key replaces previous fiber
  yield* FiberMap.run(map, "task-1", newEffect)
})
```

**Source**: `docs/effect/packages/effect/src/FiberHandle.ts`, `docs/effect/packages/effect/src/FiberMap.ts`

## Redacted (Sensitive Data)

Protect sensitive values from accidental logging.

```typescript
import { Effect, Redacted, Config } from "effect"

const program = Effect.gen(function* () {
  // From config
  const apiKey = yield* Config.redacted("API_KEY")

  // Create manually
  const secret = Redacted.make("my-secret-value")

  // Safe logging (shows <redacted>)
  yield* Effect.log(`Key: ${secret}`) // Key: <redacted>

  // Access actual value when needed
  const value = Redacted.value(secret) // "my-secret-value"
})
```

**Source**: `docs/effect/packages/effect/src/Redacted.ts`

## Match (Pattern Matching)

Exhaustive pattern matching.

```typescript
import { Match } from "effect"

type Shape =
  | { _tag: "Circle"; radius: number }
  | { _tag: "Rectangle"; width: number; height: number }

const area = Match.type<Shape>().pipe(
  Match.tag("Circle", ({ radius }) => Math.PI * radius ** 2),
  Match.tag("Rectangle", ({ width, height }) => width * height),
  Match.exhaustive
)

// Or with discriminated unions
const result = Match.value(myShape).pipe(
  Match.when({ _tag: "Circle" }, ({ radius }) => `Circle: ${radius}`),
  Match.when({ _tag: "Rectangle" }, ({ width, height }) => `Rect: ${width}x${height}`),
  Match.exhaustive
)
```

**Source**: `docs/effect/packages/effect/src/Match.ts`

## Lookup Commands

```bash
# Find a specific pattern in Effect source
grep -rn "yield\* Effect" docs/effect/packages/effect/src/

# Find all exports from a module
grep "^export" docs/effect/packages/effect/src/Effect.ts | head -50

# Find type definition
grep -A 5 "interface Effect<" docs/effect/packages/effect/src/Effect.ts

# Find usage in tests
grep -rn "Effect.gen" docs/effect/packages/effect/test/

# Find STM patterns
grep -rn "STM.gen" docs/effect/packages/effect/test/

# Find Request batching examples
grep -rn "RequestResolver.makeBatched" docs/effect/packages/effect/
```
