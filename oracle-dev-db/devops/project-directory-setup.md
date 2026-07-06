# Project Directory Setup

## Overview

Use this guide when the user asks to **set up the database directory**, **initialize the project**, or **scaffold the Oracle folder structure** in an application repository that does not have one yet.

Copy the starter tree from `templates/project-database/` and fill in `oracle-schema-prefix.md` at the repo root.

---

## Agent Workflow

### Step 1: Gather project settings

If `oracle-schema-prefix.md` does not exist at the repo root, **ask the user** for:

| Setting | Example |
|---------|---------|
| Application / project name | Acme Order Management |
| Object prefix | `acme_` |
| Schema owner | `ACME_APP` |
| Application runtime user | `ACME_USER` |
| Install / migration user | `ACME_DDL` |

Optional: status lookup tables and codes (document in the prefix file).

Copy `templates/oracle-schema-prefix.md` to the **repo root** as `oracle-schema-prefix.md` and fill in the answers.

If the file already exists, read it and use the documented prefix and users.

### Step 2: Determine project folder name

1. Use the **existing repository or workspace folder name** when it is meaningful (not empty or generic like `workspace`, `project`, `repo`).
2. If the folder name is empty or generic, use the **Application name** from `oracle-schema-prefix.md` (normalized: lowercase, hyphens for spaces).
3. If still unknown, **ask the user**.

The database layout lives **inside** this project folder at `database/` and `apex/`.

### Step 3: Create the directory tree

Copy the full structure from `templates/project-database/` into the application repo:

- Create every folder listed below (even if empty).
- Copy each folder `README.md` stub.
- Copy `database/install/install.sql`, `install-dev.sql`, and `rollback.sql`.
- Copy `database/README.md` and `apex/README.md`.
- Do **not** create or modify root-level `f###.sql` files.

### Step 4: Register new scripts in install files

When adding objects later:

1. Add a forward `@@` line to `database/install/install.sql` in dependency order.
2. Add the matching reverse drop to `database/install/rollback.sql`.
3. Use paths relative to `database/install/` (e.g. `@@../tables/orders.sql`).

---

## Application Repository Layout

```text
{project-name}/
├── oracle-schema-prefix.md
├── apex/
│   └── README.md
└── database/
    ├── README.md
    ├── install/
    │   ├── install.sql
    │   ├── install-dev.sql
    │   └── rollback.sql
    ├── tables/
    ├── indexes/
    ├── constraints/
    ├── sequences/
    ├── views/
    ├── mviews/
    ├── types/
    ├── packages/
    │   ├── spec/                    ← .pks files
    │   └── body/                    ← .pkb files
    ├── procedures/
    ├── functions/
    ├── triggers/
    ├── seeds/
    ├── grants/
    ├── synonyms/
    └── data/
```

Each object folder contains a one-line `README.md` describing its purpose (from the template).

---

## Install Order (Forward)

`database/install/install.sql` must call scripts in this order:

```text
tables → sequences → indexes → constraints → views → mviews
→ types → packages/spec → packages/body → procedures → functions
→ triggers → seeds → grants → synonyms
```

**Not in default install:** `data/` (run manually).

### Package spec and body

| Folder | Extension | Install order |
|--------|-----------|---------------|
| `packages/spec/` | `.pks` | Before matching body |
| `packages/body/` | `.pkb` | After matching spec |

File naming: `{prefix}{package_name}.pks` / `.pkb` — e.g. `acme_orders_pkg.pks`, `acme_orders_pkg.pkb`.

Install all specs before any bodies, or interleave spec then body per package in `install.sql`.

---

## Rollback Order (Reverse)

`database/install/rollback.sql` drops objects in **reverse** dependency order:

```text
synonyms → grants → triggers → functions → procedures
→ packages/body → packages/spec → types → mviews → views
→ constraints → indexes → sequences → tables
```

**Seeds:** Do not drop seed data by default on rollback (data preservation). Document optional truncate/delete blocks if the project requires them.

**Packages:** Drop package **body** before package **spec**.

---

## Constraint Placement

| When | Where |
|------|--------|
| `CREATE TABLE` with PK, FK, UQ, CK | `tables/{table}.sql` |
| Later `ALTER TABLE … ADD CONSTRAINT` | `constraints/{table}_{purpose}.sql` |

---

## Seed File Naming

Files in `seeds/` must start with **`seed_`**:

- `seed_order_statuses.sql`
- `seed_record_statuses.sql`

Use idempotent `MERGE` per `idempotent-ddl-scripts.md`.

---

## Path References in Install Scripts

Scripts live in `database/install/`. Reference sibling folders with `../`:

```sql
@@../tables/order_statuses.sql
@@../packages/spec/acme_orders_pkg.pks
@@../packages/body/acme_orders_pkg.pkb
@@../seeds/seed_order_statuses.sql
```

---

## Exclusions

Agents must **never** modify unless the user explicitly requests it:

- Contents of `apex/` (Oracle APEX export)
- Root-level `f###.sql` (APEX application exports)

Always **create** an empty `apex/` folder for future exports.

---

## Related Files

- `design/project-prefix.md` — prefix discovery after setup
- `design/schema-standards.md` — object naming and DDL rules
- `devops/idempotent-ddl-scripts.md` — table exists-check, MERGE, CREATE OR REPLACE
- `templates/project-database/` — copy source for scaffolding
