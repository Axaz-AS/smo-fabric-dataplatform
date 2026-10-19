# LOP Migration Import — Data Product Handoff

Status: **VALIDATED & ENRICHED** — Updated following the full NOBS export and bronze arrival of `exp_ordre` and `exp_verge` (2026-10-06).

## Purpose

Consumer-shaped mart models in `wh_gold.mart` for the **LOP migration import**.
LOP fetches these entities from the datalake as **JSON** (JSON export handled outside dbt).

| Model | Grain | Current rows | Export coverage |
|-------|-------|--------------|-----------------|
| `dim_ops_lop_employee` | 1 row per internal Sophies Minde employee | 358 | 355 rich profiles from `exp_medarbeider`, 3 legacy fallback |
| `dim_ops_lop_health_personnel` | 1 row per external healthcare practitioner | 3,628 | Full population across specialists, hospital doctors, GPs, PTs |
| `fct_ops_lop_order` | 1 row per clinical order (scoped to conformed patients) | 96,053 | Full legacy population enriched with `exp_ordre` master records |
| `fct_ops_lop_appointment` | 1 row per appointment record per source | 119,414 | 119,403 occurred visit events + 11 booked sample |

All models and tests pass: `dbt build --select path:models/mart/ops_lop` → PASS=29, ERROR=0.

## Scope

- **In scope:** Employees, Health personnel, Orders, Appointments.
- **Out of scope (deliberate):**
  - **Patients** are imported to LOP through **Boomi**, which reads `wh_silver.core.core_ops__patient` (and related entities like `core_ops__patient_guardian` and `core_ops__patient_contact`) directly and does its own mapping. No patient data product in Fabric.
  - **Invoicing** (invoice date/number, amounts, copay) — not migrated to LOP.
  - **RBAC / permissions** (component management, unlock flags, birth-number visibility, calendar layout, EHR case types, etc.) — handled inside LOP via RBAC, not migrated.
- The mapping source of truth is the workbook **`Data mapping to LOP.xlsx`** at the repo root (sheets `employee`, `patient`, `healthcare personel`).

## Full Export Verification & Findings (2026-10-06)

### 1. Employee (`exp_medarbeider` & `dim_ops_lop_employee`)

- [x] **Coverage gap closed:** Rich profile now covers **355 of 358 employees** (email, username, job_title, storage_location, full_name). Only 3 fall back to `statkliniker`.
- [ ] **`resource_type` vs subject area:** Values remain employment/function (`Ingeniør`, `Tekniker`, `Administrasjon`, etc.). Confirm whether LOP team requires clinical subject area from an alternative classification.
- [ ] **Phone number:** Handled via Entra ID user migration (absent in NOBS export).
- [x] `storage_location` is populated for 269 employees.

### 2. Health personnel (`exp_helsepersonell` & `dim_ops_lop_health_personnel`)

- [x] **Full export landed:** Expanded from 12 sample rows to **3,628 practitioners**.
- [x] Profession and category diversity verified: includes `Lege (Rekvirent)` (3,188), `Fastlege` (7), `Fysioterapeut` (15), `Ergoterapeut` (1), `Fotterapeut` (1).
- [ ] Practitioner categories carry numeric sort prefixes (e.g. `1 Spesialist i ortopedisk kirurgi`, `8 Sykehuslege`). Clean before LOP ingestion if required.

### 3. Patient & Guardian (`core_ops__patient` & `core_ops__patient_guardian`)

- [x] **Demographic coverage expanded:** 97,912 records in `exp_pasient` and `exp_personalia`. Total conformed patient population: 98,719.
- [x] **Guardian gap resolved (`exp_verge`):** Newly delivered table `exp_verge` (3,738 records) provides guardian first/last name, telephone number and email for patients. Conformed in `core_ops__patient_guardian` (3,625 active links to `core_ops__patient`).
- [x] **Ghost stubs filtered:** 9 completely blank record stubs in `exp_pasient` (lacking patient number, names and personalia) are filtered out in `int_ops__patient_unified`. All remaining patients have a valid patient number.

### 4. Orders (`exp_ordre`, `core_ops__order`, `fct_ops_lop_order`)

- [x] **Master export arrived (`exp_ordre`):** Newly arrived `exp_ordre` integrated into `int_ops__order_unified`, `core_ops__order`, and `fct_ops_lop_order`.
- [x] **Enrichment fields added:** `fk_assistive_device`, `fk_nav_decision`, `trial_date` (prøvedato), `completed_date` (ferdigdato), `delivery_method`, `order_notes`, `trial_notes`, `delivery_notes`.
- [x] 100% of valid `exp_ordre` rows match orders in `int_ops__order_unified`.

### 5. Appointments (`statevent`, `core_ops__appointment`, `fct_ops_lop_appointment`)

- [x] **Employee FK resolved:** Previously documented as NULL across all rows due to an alphanumeric key being cast to `BIGINT`. Recast to `VARCHAR(64)`: **361,408 (99.97%)** of occurred visit events now successfully match `core_ops__employee`.
- [x] **Duration parsed:** Previously evaluated to NULL because duration was stored as `'HH:MM:SS'`. Now properly typed and parsed as `duration_minutes` (`DATEDIFF(minute, '00:00:00', TRY_CAST(duration AS TIME))`).

### 6. NAV Decisions & Assistive Devices (`core_ops__nav_decision`, `core_ops__assistive_device`)

- [x] **Unified Join:** Disproved earlier weak-data assumption that `statvedtak` and `exp_vedtak` had no common key and required a UNION ALL. Validated that `statvedtak.fk_vedtak_id` is 1-to-1 with `exp_vedtak.pk_exp_vedtak_id` (202,568 matches). Unified into a single record per decision (201,935 conformed decisions).
- [x] **FK Linkage:** `core_ops__assistive_device.fk_nav_decision` links 108,876 assistive devices directly to `core_ops__nav_decision.pk_nav_decision_id`.

## How to verify / run

```bash
cd fabric/workspaces/smo-engineering/02-transformation/dbt_transformations.DataBuildToolJob/Code/dbt

.venv/bin/dbt build --select path:models/mart/ops_lop   # build + tests
.venv/bin/dbt compile                                   # parse check
```

Requires an active session: `az login --tenant "a332dfcc-98a9-4a5a-9ed7-48690cc22bb2"`.

Note on `dbt show`: the fabric adapter appends its own `order by … fetch first N` clause, so avoid `ORDER BY` in `--inline` queries and wrap `UNION` queries in a subselect.

## Files

```
models/mart/ops_lop/
  dim_ops_lop_employee.sql / .yml
  dim_ops_lop_health_personnel.sql / .yml
  fct_ops_lop_order.sql / .yml
  fct_ops_lop_appointment.sql / .yml
```

Consumers: LOP (JSON export from the datalake). Patient data: Boomi → `core_ops__patient`.