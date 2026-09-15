# AGENTS.md — SMO Fabric dbt Transformations

Guidance for AI agents and developers working in this dbt project. Read this before creating, renaming, or refactoring any model. The dbt project lives in `Code/dbt/`, inside the Fabric Data Build Tool item `dbt_transformations.DataBuildToolJob`.

## Project Context

dbt transformation project for **Sophies Minde Ortopedi (SMO)** on **Microsoft Fabric**:

- **Runs on:** a Fabric Data Build Tool job (`dbt_transformations.DataBuildToolJob`). The default connection is Fabric Data Warehouse **`wh_silver`**; mart models materialize in Fabric Data Warehouse **`wh_gold`** (via `+database: wh_gold` in `dbt_project.yml`).
- **Reads:** Delta tables in Lakehouse **`lh_bronze`** (cross-database three-part naming) plus dbt-built models.
- **Layers:** **bronze → int (`base_*`) → int → core → mart**, one-way. The folder decides the schema — see [Schema Layout](#folder-decides-the-schema).

## Architecture

Each layer exists to answer one question:

> **bronze** answers *"what did the source deliver?"*
> **base** answers *"what did the source say?"* — same facts, clean, typed, predictable names
> **int** answers *"what fits together?"*
> **core** answers *"what does the business entity mean?"*
> **mart** answers *"what does this consumer need?"*

| Layer | Folder | Purpose | Materialization | Lives in |
|-------|--------|---------|-----------------|----------|
| **bronze** | — | *Land.* Delta tables in `lh_bronze` exactly as delivered by notebooks, dataflows and ADF | — (not dbt) | `lh_bronze` Lakehouse |
| **source defs** | `models/sources/` | *Declare.* Standalone source ymls (`src_{source}.yml`) listing the bronze tables only — no models, no per-table column docs | — (yml only) | — |
| **base** | `models/int/{domain}/base_{source}__{entity}.sql` | *Extract & standardize.* One view per bronze source table: queries `source()` directly, handles all T-SQL bracket escaping, exact Delta casing, type casts, snake_case renaming and soft-delete filters (`WHERE is_deleted = 0 OR is_deleted IS NULL`) | `view` | `wh_silver.int` |
| **int** | `models/int/{domain}/int_{domain}__{entity}.sql` | *Intermediate.* Joins across base views within a domain, deduplication, intermediate calculations. Not yet a business contract | `view` | `wh_silver.int` |
| **core** | `models/core/{domain}/` | *Conformed business entity / normalized source of truth.* Highly normalized, conformed, reusable across consumers. **Enforces `pk_{entity}` / `fk_{entity}` keys** | `table` | `wh_silver.core` |
| **mart** | `models/mart/{domain}_{consumer}/` | *Serve.* Denormalized star-schema tables shaped for one consumer | `table` | `wh_gold.mart` |

Physical hierarchy: `wh_silver.int.base_*` → `wh_silver.int.int_*` → `wh_silver.core.core_*` → `wh_gold.mart.agg_*` / `fct_*` / `dim_*`.

The bronze layer is never modelled in dbt — it is declared only in `models/sources/src_{source}.yml` (table names only) and queried by the `base_*` views.

**Default to a `base_{source}__{entity}` view for every bronze table.** It keeps the source-shaped work — bracket escaping, casing, renaming, casting — out of everything downstream, so `int` and `core` are free to be about business meaning.

### Consumers

| Code | Consumer |
|--------|--------|
| `pbi` | Power BI semantic models and reports |
| `boomi` | Boomi integrations (API-facing tables) |
| `rpt` | Reporting |

### Dependency direction is one-way

```
bronze  →  base_*  →  int_*  →  core_*  →  mart (dim_/fct_/agg_)  →  Power BI / Boomi / reporting
```

A model only ever `ref()`s a layer to its left. A `base_*` view only calls `source()`. A core model is never made correct from a mart.

## Folder Structure

```
Code/dbt/
  dbt_project.yml
  macros/
    generate_schema_name.sql        ← folder decides schema (int, core, mart)
    escape_identifier.sql           ← escape_column() T-SQL bracket helper
  models/
    sources/
      src_{source}.yml              ← standalone source definition, tables only
    int/
      {domain}/
        base_{source}__{entity}.sql ← one view per bronze table (escaping, casts, filters)
        int_{domain}__{entity}.sql  ← joins/calculations across base views
    core/
      {domain}/
        core_{domain}_{entity}.sql
        core_{domain}_{entity}.yml  ← only where it carries real docs/tests
    mart/
      {domain}_{consumer}/
        {prefix}_{domain}_{consumer}_{entity}.sql
        {prefix}_{domain}_{consumer}_{entity}.yml  ← only where it carries real docs/tests
```

Every layer is exactly one folder deep — one folder per dataset.

## Fabric SQL Engine & Lakehouse Quirks

Fabric Warehouses speak T-SQL over Delta tables. These project-specific pitfalls apply to every model that touches `lh_bronze`.

### Three-part naming and `quoting`

Lakehouse tables are addressed with three-part names — `database.schema.table`, e.g. `lh_bronze.gapvision.V111_Score`. Declare every Lakehouse source in `models/sources/` with quoting disabled so the rendered three-part name stays bare and stable regardless of adapter default quoting:

```yaml
version: 2

sources:
  - name: gapvision
    description: "GapVision survey data in bronze Lakehouse"
    database: lh_bronze
    schema: gapvision
    quoting:
      database: false
      schema: false
      identifier: false
    tables:
      - name: V111_Score
      - name: V111_Utsendelse
```

Source ymls list **tables only** — no per-table column YAMLs. Column definitions live in the `base_*` view that queries the table.

### Binary, case-sensitive collation

Fabric Warehouse endpoints use the binary collation `Latin1_General_100_BIN2_UTF8`. **Source references must match Delta casing exactly**: `V111_Score`, `ResponseID`, `Måling`, `__kplt__ID`. Writing `v111_score` or `måling` will fail to resolve. This applies only to references into `lh_bronze` — everything dbt builds itself is lowercase `snake_case`.

### Bracket escaping

T-SQL requires square brackets around a column when it:

- contains Norwegian letters `æ`, `ø`, `å` / `Æ`, `Ø`, `Å` — e.g. `[Måling]`, `[Spørsmål]`
- starts with an underscore — e.g. `[__kplt__ID]`, `[_kflt_AvdelingID]`
- contains spaces or hyphens — e.g. `[response id]`, `[user-name]`
- is a T-SQL reserved keyword — `[group]`, `[order]`, `[date]`, `[text]`

Inside brackets the only character that needs escaping is `]`, doubled to `]]`. Prefer the helper macro from `macros/escape_identifier.sql`, which handles both rules:

```sql
SELECT {{ escape_column('Måling') }} AS measurement
```

### DATETIME2 Precision in Fabric DW

Fabric Data Warehouse CTAS (`CREATE TABLE ... AS SELECT`) requires an explicit precision between 0 and 6 for `DATETIME2` columns (e.g. `DATETIME2(6)`). Bare `DATETIME2` defaults to precision 7 in T-SQL, which causes runtime error 24597: `An integer precision value between 0 and 6 must be specified`. Always cast timestamps as `TRY_CAST(... AS DATETIME2(6))`.

### Quarantining

**All bracket escaping, Delta casing, renaming and type casting belongs in the `base_*` views in `models/int/{domain}/` — and only there.** Once a column leaves a `base_*` view it is lowercase `snake_case`, correctly typed, and bracket-free. `int_*`, `core_*` and mart models never write `[...]`, never reference Norwegian-cased Delta columns, and never compensate for Delta quirks.

## Schema & Database Layout

The folder decides the schema. `macros/generate_schema_name.sql` returns the `+schema` when set (and `dbt_project.yml` sets it per top-level folder); otherwise, for models at least one folder deep, it falls back to the first path segment of the model's path; otherwise `target.schema`:

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- elif node.resource_type == 'model' and node.path.split('/') | length > 1 -%}
        {{ node.path.split('/')[0] | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
```

Schemas are bare folder names — no `smo_wh_` prefix:

```
wh_silver (Fabric Data Warehouse)
  ├─ int      ← models/int/  (base_* views + int_* views)
  └─ core     ← models/core/ (conformed tables)
wh_gold (Fabric Data Warehouse)
  └─ mart     ← models/mart/ (+database: wh_gold in dbt_project.yml)
lh_bronze (Lakehouse)
  └─ {source} ← raw Delta tables, read-only for dbt
```

Schemas are the access boundary: only the dbt job writes to `int`, `core` and `mart`; consumers are granted read on `wh_gold.mart` (and `core` where needed) — never on `lh_bronze`.

## Naming Conventions

### Tables

| Layer | Prefix | Pattern | Example |
|-------|--------|---------|---------|
| base | `base_` | `base_{source}__{entity}` | `base_nobs__statistikk` |
| int | `int_` | `int_{domain}__{entity}` | `int_gapvision__score_enriched` |
| core | `core_` | `core_{domain}_{entity}` | `core_gapvision_score` |
| mart — Dimension | `dim_` | `dim_{domain}_{consumer}_{entity}` | `dim_gapvision_pbi_company` |
| mart — Fact | `fct_` | `fct_{domain}_{consumer}_{entity}` | `fct_gapvision_pbi_score` |
| mart — Aggregate | `agg_` | `agg_{domain}_{consumer}_{entity}_{grain}` | `agg_gapvision_pbi_score_monthly` |

Every mart table carries **both** the domain and the consumer short code, so the name is globally unique on its own: the same entity served to two consumers gives `fct_gapvision_pbi_score` and `fct_gapvision_boomi_score`, not two identically named tables told apart only by warehouse.

Rules:

- All lowercase `snake_case`
- Double underscore `__` separates source/domain from entity in `base_` and `int_` models
- Singular entity names — `core_gapvision_score`, not `core_gapvision_scores`
- Source-system identity is explicit in `base_` names; from `core_` onward the name describes the **business entity**, not where it came from
- Names describe business meaning, not implementation history. Never `_final`, `_new`, `_v2`, `_clean`, `_processed`, `_latest`, `_tmp`
- Prefer one conformed core entity over per-consumer copies. If two consumers genuinely need different grains or definitions, those are two different entities and should be named as such
- Model names are unique across the whole project (dbt enforces this); the layer prefix plus domain — and, in mart, consumer — short code is what keeps them unique

### Grain

Every model has exactly one documented grain — the meaning of one row.

```
fct_gapvision_pbi_score          1 row = 1 submitted answer
agg_gapvision_pbi_score_monthly  1 row = 1 company, measurement and question per calendar month
dim_gapvision_pbi_company        1 row = 1 company
```

Where a model carries a yml, declare the grain there (`config.meta.grain`). The grain is what makes a model testable — a `unique` test on the key columns follows directly from it.

### Keys

**`core` enforces the key convention.** Every core model declares a primary key, and references to other core entities use foreign keys:

| Kind | Pattern | Example |
|------|---------|---------|
| Primary key | `pk_{entity}` | `pk_response_id` |
| Foreign key | `fk_{entity}` | `fk_company` |
| Foreign key with a role | `fk_{entity}_{role}` | `fk_employee_manager`, `fk_user_approver` |

```
core_gapvision_response
    pk_response_id
    fk_company
    company_name
```

Add a role whenever it adds useful meaning — either because the model holds more than one FK to the same entity (`fk_user_owner` / `fk_user_approver`), or because the role *is* the point of the relationship (`fk_employee_manager`).

Which model an `fk_` points at is relationship metadata: declare it with a dbt `relationships` test in the yml.

**The other layers are looser:**

- **`base`** stays source-shaped after rename/cast, but where the natural key is obvious, name it `pk_`/`fk_` right away (`[ResponseID] AS pk_response_id`) so joins in `int` line up cleanly.
- **`int`** carries keys through but does not invent new ones.
- **`mart`** inherits the core keys by default, but the consumer wins. Document what you chose in the model yml.

### Dates and timestamps

- `_at` for timestamps: `created_at`, `updated_at`, `deleted_at`, `sendout_at`, `answered_at`
- `_date` for calendar dates: `answer_date`, `invoice_date`, `birth_date`
- Avoid ambiguous names: `created`, `updated`, `date`, `timestamp`
- Store timestamps in UTC; if a local-time column is genuinely needed, name it explicitly (`created_at_local`)

### Booleans

Prefix with `is_` or `has_` so the SQL reads naturally: `is_active`, `is_deleted`, `is_current`, `is_billable`, `has_discount`. Not `active`, `deleted`, `billable`.

### Units

Put the unit in the name whenever it isn't obvious from context:

```
duration_sec
wait_time_hours
amount_nok
distance_km
weight_kg
```

For monetary values where the currency varies by row, use a neutral `amount` plus a `currency_code` column rather than hard-coding a currency into the name. Never encode the data type in a name (`user_name_string`, `is_active_bool`, `created_at_timestamp`).

### yml Files

- Source definitions are **standalone**: one `models/sources/src_{source}.yml` per source system, listing the bronze **tables only** — no per-table column YAMLs
- **No mirror ymls.** A model yml must carry real value (documentation, tests, ownership metadata). Never create a yml that just repeats the file name or empty stubs
- `base_*` and `int_*` views need no yml by default — the SQL defines the columns
- `core_*` and mart models keep a co-located `{model_name}.yml` where it documents description, `meta.grain`, columns and tests:

```yaml
version: 2

models:
  - name: core_gapvision_score
    description: "Conformed core business entity representing respondent survey scores."
    config:
      meta:
        grain: one row per respondent answer
    columns:
      - name: response_id
        description: "Reference to the survey response."
        tests: [not_null]
```

## Fabric Git Integration Rules

The dbt project lives in `Code/dbt/` — the Git item folder of the Fabric Data Build Tool item. Fabric Git integration is stricter than plain Git; these will fail deployment:

- **No 0-byte files.** Never commit empty `.gitkeep` placeholders — Fabric rejects them. A folder only needs a file when it actually contains one.
- **No extensionless files.** Every file must have a file extension.
- **Never commit `profiles.yml`, `target/`, or `logs/`** into the Git item folder. The profile is managed by Fabric through `dbt-content.json`; credentials never enter Git. Keep `.gitignore` covering `target/` and `logs/` *before* they first appear locally.
- `dbt-content.json` (one level above `Code/`) holds the profile and job configuration: profile schema `smo_wh`, connection `wh_silver`, and the job command (`dbt build`, 8 threads). Edit it deliberately — it is the job definition.

## Running dbt

In production the Fabric Data Build Tool job runs `dbt build` against `wh_silver`/`wh_gold`. Locally, configure a `fabric`-adapter profile named `default` (per `profile: 'default'` in `dbt_project.yml`) in `~/.dbt/profiles.yml` — never inside `Code/dbt/`:

```bash
cd fabric/workspaces/smo-engineering/02-transformation/dbt_transformations.DataBuildToolJob/Code/dbt

dbt compile                                    # verify models parse and compile
dbt build                                      # same as the Fabric job
dbt run --select base_nobs__statistikk         # a single model
dbt build --select +core_gapvision_score       # a model and everything upstream
dbt run --select source:gapvision              # everything reading one source system
dbt test                                       # all tests
```

## Agent Checklist

Before committing changes in this project:

- [ ] New Lakehouse tables are declared in a standalone `models/sources/src_{source}.yml` (tables only) with `quoting` fully disabled and `database: lh_bronze`
- [ ] Every bronze table consumed in dbt has a `models/int/{domain}/base_{source}__{entity}.sql` view that owns all bracket escaping, exact Delta casing, casting, snake_case renaming and soft-delete filtering
- [ ] Every reference into `lh_bronze` matches Delta casing exactly (binary collation)
- [ ] No `[...]` escaping outside `base_*` views
- [ ] Names follow the layer patterns; `core` models have `pk_`/`fk_` keys with `unique`, `not_null` and `relationships` tests where applicable
- [ ] yml files carry real value (docs/tests) — no mirrors, no empty files
- [ ] Dependency direction respected — `ref()` only points left (`base → int → core → mart`)
- [ ] No 0-byte files, no extensionless files, no `profiles.yml` / `target/` / `logs/` under `Code/dbt/`
