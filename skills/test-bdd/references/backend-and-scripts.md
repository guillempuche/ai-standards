# Backend and Script Patterns

> The code samples show the shape of a test, not a current API reference.
> Take exact calls from the docs of the installed library versions, preferring their newest APIs; libraries rename and deprecate APIs between releases.

The examples use TypeScript (vitest, supertest) and Python (pytest).
Use the same shape with whatever runner the project already has.

## HTTP Handler (Integration)

Send a real request to the app and assert on what a client and the database see.
Don't call the handler function directly or mock the framework.

```typescript
import request from 'supertest'
import { beforeEach, describe, expect, it } from 'vitest'

import { createApp } from '../app'
import { resetDatabase, testDb } from '../test/db'

describe('POST /orders', () => {
    const app = createApp({ db: testDb })

    beforeEach(async () => {
        await resetDatabase()
    })

    it('should create the order and return its id', async () => {
        // GIVEN a signed-in customer with one item in the cart
        const token = await signInAs('customer')

        // WHEN the order is submitted
        const res = await request(app)
            .post('/orders')
            .set('Authorization', `Bearer ${token}`)
            .send({ items: [{ sku: 'MUG-01', quantity: 1 }] })

        // THEN the response should carry the new order id
        expect(res.status).toBe(201)
        expect(res.body).toEqual({ id: expect.any(String) })
        // AND the order should be stored
        const order = await testDb.orders.findById(res.body.id)
        expect(order?.items).toHaveLength(1)
    })

    it('should reject an order with no items', async () => {
        // GIVEN a signed-in customer
        const token = await signInAs('customer')

        // WHEN an empty order is submitted
        const res = await request(app)
            .post('/orders')
            .set('Authorization', `Bearer ${token}`)
            .send({ items: [] })

        // THEN the request should fail validation
        expect(res.status).toBe(400)
        // AND nothing should be stored
        expect(await testDb.orders.count()).toBe(0)
    })
})
```

## Repository with a Real Database (Integration)

Run against a real database of the same engine as production (a container, a local test instance, or an in-process engine when the project uses one).
Reset state between tests — truncate tables, or wrap each test in a transaction that rolls back — so tests don't depend on order.

```python
import pytest

from app.repositories import UserRepository


@pytest.fixture
def repo(db_session):
    return UserRepository(db_session)


class TestFindByEmail:
    def test_should_find_the_user_ignoring_email_case(self, repo):
        # GIVEN a stored user
        repo.add(email="ana@example.com", name="Ana")

        # WHEN looking the user up with a differently cased email
        user = repo.find_by_email("ANA@Example.com")

        # THEN the stored user should be returned
        assert user.name == "Ana"

    def test_should_return_none_when_no_user_matches(self, repo):
        # GIVEN an empty table
        # WHEN looking up any email
        # THEN nothing should be found
        assert repo.find_by_email("nobody@example.com") is None
```

## Outgoing Calls as Outputs

When the behavior *is* a call to another system — an email, a webhook, a payment request — fake that system at its boundary and assert on what it received.
Prefer a fake server or recording fake over mocking an internal module.

```python
def test_should_email_the_receipt_after_payment(client, fake_mailer):
    # GIVEN a pending order
    order = create_order(total=4200)

    # WHEN the payment succeeds
    client.post(f"/orders/{order.id}/pay", json={"card": "tok_test"})

    # THEN the customer should receive one receipt
    # (the sent email is the observable output here)
    assert [m.subject for m in fake_mailer.sent] == ["Your receipt"]
```

## CLI / Script (Integration)

Run the script as a real process, the way a person or CI would.
Give it a temporary working directory, controlled env vars, and input files; assert on exit code, stdout/stderr, and the files it leaves behind.
Start the process with the language's built-in API (Node's `child_process`, Python's `subprocess`) or the helper library the project already uses.
Invoke the script the same way the project does (`node`, `tsx`, the built output, a `bin` entry).

```typescript
import { spawnSync } from 'node:child_process'
import { mkdtemp, readFile, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { describe, expect, it } from 'vitest'

const script = fileURLToPath(new URL('./convert-csv.js', import.meta.url))

const runScript = (args: string[], cwd: string) =>
    spawnSync(process.execPath, [script, ...args], { cwd, encoding: 'utf8' })

describe('convert-csv', () => {
    it('should write a JSON file with one object per row', async () => {
        // GIVEN a CSV file with a header and two rows
        const dir = await mkdtemp(join(tmpdir(), 'convert-'))
        await writeFile(join(dir, 'in.csv'), 'name,age\nAna,30\nBo,25\n')

        // WHEN the script converts it
        const run = runScript(['in.csv', 'out.json'], dir)

        // THEN it should succeed
        expect(run.status).toBe(0)
        // AND the output file should contain both rows
        const out = JSON.parse(await readFile(join(dir, 'out.json'), 'utf8'))
        expect(out).toEqual([
            { name: 'Ana', age: '30' },
            { name: 'Bo', age: '25' },
        ])
    })

    it('should exit with an error when the input file is missing', async () => {
        // GIVEN an empty directory
        const dir = await mkdtemp(join(tmpdir(), 'convert-'))

        // WHEN the script is run on a file that does not exist
        const run = runScript(['missing.csv', 'out.json'], dir)

        // THEN it should fail with a message naming the file
        expect(run.status).not.toBe(0)
        expect(run.stderr).toContain('missing.csv')
    })
})
```

The same test in Python, with pytest's `tmp_path`:

```python
import subprocess
import sys


def test_should_exit_with_an_error_when_the_input_file_is_missing(tmp_path):
    # GIVEN an empty directory
    # WHEN the script is run on a file that does not exist
    run = subprocess.run(
        [sys.executable, SCRIPT, "missing.csv", "out.json"],
        cwd=tmp_path,
        capture_output=True,
        text=True,
    )

    # THEN it should fail with a message naming the file
    assert run.returncode != 0
    assert "missing.csv" in run.stderr
```

For shell scripts, the same shape works with `bats`: run the script, then assert on `$status` and `$output`.

## Jobs and Queue Consumers (Integration)

Deliver the message through the same entry point production uses, then assert on the state it changed and the messages it emitted.
Cover a duplicate delivery whenever the consumer is meant to be idempotent.
