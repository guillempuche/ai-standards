# PowerSync Sync Rules Reference

Sync Rules control which data gets synchronized to which devices (dynamic partial replication).

## Official Documentation

For comprehensive Sync Rules documentation, see the official PowerSync docs:

- **Main documentation**: <https://docs.powersync.com/usage/sync-rules.md>
- **Key sections**:
  - [Overview](https://docs.powersync.com/usage/sync-rules.md) - Introduction and concepts
  - [Global Data](https://docs.powersync.com/usage/sync-rules/example-global-data.md) - Data synced to all users
  - [Organize Data Into Buckets](https://docs.powersync.com/usage/sync-rules/organize-data-into-buckets.md) - Bucket structure
  - [Parameter Queries](https://docs.powersync.com/usage/sync-rules/parameter-queries.md) - User-specific filtering
  - [Data Queries](https://docs.powersync.com/usage/sync-rules/data-queries.md) - Selecting and transforming data
  - [Types](https://docs.powersync.com/usage/sync-rules/types.md) - Type mapping (Postgres → SQLite)
  - [Operators and Functions](https://docs.powersync.com/usage/sync-rules/operators-and-functions.md) - Supported SQL operations
  - [Many-to-Many Relationships](https://docs.powersync.com/usage/sync-rules/guide-many-to-many-and-join-tables.md) - Join table patterns
  - [Advanced Topics](https://docs.powersync.com/usage/sync-rules/advanced-topics.md) - Client parameters, edge cases

## Sync Streams (Future)

PowerSync is developing **Sync Streams** as the next evolution of Sync Rules:

- On-demand syncing with client-specified parameters
- Configurable TTL for temporary caching behavior
- Simplified syntax and React hooks integration

See [Sync Streams docs](https://docs.powersync.com/usage/sync-streams.md) for early alpha details.

## Source Code Reference

The sync rules implementation is open source at [powersync-ja/powersync-service](https://github.com/powersync-ja/powersync-service).

### Repository structure

| Path                                                                                                                              | Description                            |
| --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| [`packages/sync-rules/`](https://github.com/powersync-ja/powersync-service/tree/main/packages/sync-rules)                         | Core sync rules library                |
| [`packages/sync-rules/src/`](https://github.com/powersync-ja/powersync-service/tree/main/packages/sync-rules/src)                 | Implementation source code             |
| [`packages/sync-rules/test/`](https://github.com/powersync-ja/powersync-service/tree/main/packages/sync-rules/test)               | Test cases and examples                |
| [`packages/sync-rules/src/streams/`](https://github.com/powersync-ja/powersync-service/tree/main/packages/sync-rules/src/streams) | Sync Streams implementation (alpha)    |
| [`docs/`](https://github.com/powersync-ja/powersync-service/tree/main/docs)                                                       | Technical implementation documentation |

### Key source files

| File                                                                                                                                           | Purpose                                                  |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| [`SqlSyncRules.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/SqlSyncRules.ts)                       | Main sync rules parser and orchestrator                  |
| [`SqlDataQuery.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/SqlDataQuery.ts)                       | Data query compilation: `(row) => Array<{bucket, data}>` |
| [`SqlParameterQuery.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/SqlParameterQuery.ts)             | Parameter queries with table lookups                     |
| [`StaticSqlParameterQuery.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/StaticSqlParameterQuery.ts) | Token-only parameter queries (no table joins)            |
| [`sql_filters.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/sql_filters.ts)                         | WHERE clause and `ParameterMatchClause` compilation      |
| [`sql_functions.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/sql_functions.ts)                     | SQL function implementations (30+ functions)             |
| [`types.ts`](https://github.com/powersync-ja/powersync-service/blob/main/packages/sync-rules/src/types.ts)                                     | Core type definitions                                    |

### Technical docs in repo

| Doc                                                                                                                     | Topic                                |
| ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| [`parameters-lookups.md`](https://github.com/powersync-ja/powersync-service/blob/main/docs/parameters-lookups.md)       | Parameter query index implementation |
| [`bucket-properties.md`](https://github.com/powersync-ja/powersync-service/blob/main/docs/bucket-properties.md)         | Bucket storage design                |
| [`compacting-operations.md`](https://github.com/powersync-ja/powersync-service/blob/main/docs/compacting-operations.md) | Data compaction strategy             |
| [`sync-protocol.md`](https://github.com/powersync-ja/powersync-service/blob/main/docs/sync-protocol.md)                 | Wire protocol details                |

### Design constraints

1. **Data queries**: Given a data row, compute which buckets it belongs to
1. **Parameter queries**: Given an authenticated user, return their bucket list

SQL queries are not executed against a database—they define transformations applied during replication preprocessing. The queries build "indexes" for efficient lookup during sync.
