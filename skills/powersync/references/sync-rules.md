# PowerSync Sync Rules Reference

Sync Rules control which data gets synchronized to which devices (dynamic partial replication).

## Overview

Sync Rules are defined in YAML with SQL-like queries on your PowerSync instance. They determine:

- Which tables/columns to sync
- Which rows each user can access
- How data is transformed before syncing

## Basic Structure

```yaml
bucket_definitions:
  # Global data - synced to all users
  global:
    data:
      - SELECT * FROM categories
      - SELECT id, name FROM products WHERE active = true

  # User-specific data
  user_data:
    parameters: SELECT token_parameters.user_id AS user_id
    data:
      - SELECT * FROM todos WHERE owner_id = bucket.user_id
      - SELECT * FROM lists WHERE owner_id = bucket.user_id
```

## Bucket Types

### Global Buckets

Data synced to all authenticated users:

```yaml
bucket_definitions:
  global:
    data:
      - SELECT * FROM categories
      - SELECT * FROM settings
```

### Parameter Buckets

Data filtered per user using JWT token parameters:

```yaml
bucket_definitions:
  user_todos:
    # Extract user_id from JWT
    parameters: SELECT token_parameters.user_id AS user_id
    data:
      # Only sync todos belonging to this user
      - SELECT * FROM todos WHERE owner_id = bucket.user_id
```

### Shared Data Buckets

Data shared between multiple users:

```yaml
bucket_definitions:
  team_data[]:
    # Get all team IDs for this user
    parameters: SELECT team_id FROM team_members WHERE user_id = token_parameters.user_id
    data:
      # Sync all data for user's teams
      - SELECT * FROM projects WHERE team_id = bucket.team_id
      - SELECT * FROM tasks WHERE team_id = bucket.team_id
```

## Data Queries

### Column Selection

```yaml
data:
  # All columns
  - SELECT * FROM todos

  # Specific columns
  - SELECT id, name, created_at FROM todos

  # Renamed columns
  - SELECT id, full_name AS name FROM users

  # Computed columns
  - SELECT id, first_name || ' ' || last_name AS full_name FROM users
```

### Filtering

```yaml
data:
  # Static filter
  - SELECT * FROM products WHERE active = true

  # User-based filter
  - SELECT * FROM todos WHERE owner_id = bucket.user_id

  # Multiple conditions
  - SELECT * FROM todos WHERE owner_id = bucket.user_id AND deleted = false
```

### Supported Operators

| Operator                 | Example                           |
| ------------------------ | --------------------------------- |
| `=`, `!=`                | `status = 'active'`               |
| `<`, `>`, `<=`, `>=`     | `price > 100`                     |
| `AND`, `OR`              | `a = 1 AND b = 2`                 |
| `IN`                     | `status IN ('active', 'pending')` |
| `IS NULL`, `IS NOT NULL` | `deleted_at IS NULL`              |
| `LIKE`                   | `name LIKE '%search%'`            |

### Supported Functions

| Function                   | Description                  |
| -------------------------- | ---------------------------- |
| `ifnull(a, b)`             | Returns b if a is null       |
| `coalesce(a, b, ...)`      | Returns first non-null value |
| `upper(s)`, `lower(s)`     | Case conversion              |
| `substr(s, start, len)`    | Substring                    |
| `length(s)`                | String length                |
| `json_extract(json, path)` | Extract from JSON            |

## Parameter Queries

Extract parameters from JWT for filtering:

```yaml
bucket_definitions:
  user_data:
    parameters: SELECT token_parameters.user_id AS user_id
    data:
      - SELECT * FROM todos WHERE owner_id = bucket.user_id
```

### JWT Token Parameters

Available in `token_parameters`:

- `user_id` - From JWT `sub` claim
- Any custom claims in your JWT

### Client Parameters

Pass parameters from client:

```typescript
// Client-side
db.connect(connector, {
  params: { region: 'us-east' }
});
```

```yaml
# Sync Rules
bucket_definitions:
  regional_data:
    parameters: SELECT client_parameters.region AS region
    data:
      - SELECT * FROM stores WHERE region = bucket.region
```

## Many-to-Many Relationships

```yaml
bucket_definitions:
  # User's projects through membership
  user_projects[]:
    parameters: |
      SELECT project_id
      FROM project_members
      WHERE user_id = token_parameters.user_id
    data:
      - SELECT * FROM projects WHERE id = bucket.project_id
      - SELECT * FROM tasks WHERE project_id = bucket.project_id
```

## Type Mapping

| Source (Postgres) | Sync Rules Type    | SQLite Type |
| ----------------- | ------------------ | ----------- |
| TEXT, VARCHAR     | text               | TEXT        |
| INTEGER, BIGINT   | integer            | INTEGER     |
| REAL, DOUBLE      | real               | REAL        |
| BOOLEAN           | integer (0/1)      | INTEGER     |
| TIMESTAMP         | text (ISO 8601)    | TEXT        |
| JSON, JSONB       | text (JSON string) | TEXT        |
| UUID              | text               | TEXT        |

## Client-Side Schema Matching

Ensure client schema matches Sync Rules output:

```yaml
# Sync Rules
data:
  - SELECT id, name, price FROM products
```

```typescript
// Client schema
const products = new Table({
  name: column.text,
  price: column.real
  // id is auto-created
});
```

## Best Practices

1. **Start simple** - Begin with global data, add user filtering later
1. **Minimize synced data** - Only sync what clients need
1. **Use indexes** - Add indexes on filtered columns in source DB
1. **Test with diagnostics** - Use PowerSync Dashboard to validate
1. **Version carefully** - Schema changes may require client updates

## Common Patterns

### Soft Deletes

```yaml
data:
  - SELECT * FROM todos WHERE deleted_at IS NULL
```

### Tenant Isolation

```yaml
bucket_definitions:
  tenant_data:
    parameters: SELECT token_parameters.tenant_id AS tenant_id
    data:
      - SELECT * FROM orders WHERE tenant_id = bucket.tenant_id
```

### Recent Data Only

```yaml
data:
  - SELECT * FROM logs WHERE created_at > datetime('now', '-30 days')
```

## Debugging

Use the PowerSync Dashboard or CLI to:

- Validate Sync Rules syntax
- Preview which data syncs to specific users
- Check for errors in data queries

```bash
# CLI validation
powersync sync-rules validate
```
