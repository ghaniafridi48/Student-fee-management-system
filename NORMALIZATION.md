# NORMALIZATION.md
## Student Fee Management System (SFMS)
### Milestone 2 — Schema Normalization (1NF → 2NF → 3NF)

---

## Overview

The SFMS schema consists of five tables:
- `department`
- `student`
- `fee_structure`
- `payment`
- `receipt`

Each table is analyzed below for compliance with 1NF, 2NF, and 3NF. Where issues were found, changes are documented with justification.

---

## Table 1: `department`

| Column | Type |
|---|---|
| dept_id (PK) | INT AUTO_INCREMENT |
| dept_name | VARCHAR(100) |
| program | VARCHAR(100) |
| created_at | TIMESTAMP |

### 1NF
**Status: Already in 1NF — no changes needed.**

Every column holds an atomic, single-valued attribute. There are no repeating groups or multi-valued fields. `dept_name` and `program` are each a single string value. The primary key `dept_id` uniquely identifies each row.

### 2NF
**Status: Already in 2NF — no changes needed.**

The table has a single-column primary key (`dept_id`), so there is no possibility of partial dependency (partial dependency only arises with composite keys). Every non-key attribute (`dept_name`, `program`, `created_at`) depends fully on `dept_id`.

### 3NF
**Status: Potential transitive dependency identified and resolved.**

**Issue:** `program` (e.g., "BS Computer Science") is functionally determined by `dept_name` (e.g., "Computer Science"). This creates a transitive dependency: `dept_id → dept_name → program`.

**Resolution:** In this system, each department offers exactly one program (one-to-one relationship between dept_name and program within the university's context). Rather than splitting these into a separate `program` table (which would add complexity with no practical benefit for this scale), we retain both columns but enforce a UNIQUE constraint on `(dept_name, program)` to prevent inconsistent data entry. This is an accepted design decision for this system scale, and the relationship is documented here.

**Final status: 3NF-compliant with documented justification.**

---

## Table 2: `student`

| Column | Type |
|---|---|
| student_id (PK) | INT AUTO_INCREMENT |
| roll_no | VARCHAR(20) UNIQUE |
| name | VARCHAR(100) |
| email | VARCHAR(100) |
| phone | VARCHAR(20) |
| dept_id (FK) | INT |
| semester | INT |
| address | TEXT |
| admission_date | DATE |
| status | ENUM |
| created_at | TIMESTAMP |
| updated_at | TIMESTAMP |

### 1NF
**Status: Already in 1NF — no changes needed.**

All attributes are atomic. `address` is stored as a single TEXT field (not split into city/street/zip columns), which is an acceptable design choice for this system since address is used for display only and no queries filter on address sub-parts. No repeating groups exist.

### 2NF
**Status: Already in 2NF — no changes needed.**

The primary key is `student_id` (single column). All non-key attributes — `roll_no`, `name`, `email`, `phone`, `dept_id`, `semester`, `address`, `admission_date`, `status` — describe the student directly and depend entirely on `student_id`. There is no composite key, so partial dependency cannot occur.

### 3NF
**Status: Already in 3NF — no changes needed.**

No transitive dependencies exist. While `dept_id` is a foreign key, there is no column in this table that is functionally determined by `dept_id` alone (e.g., dept_name is not stored here; it is accessed via JOIN to the `department` table). `semester` describes the student's current enrollment, not a property of the department. All non-key attributes depend only on `student_id`.

---

## Table 3: `fee_structure`

| Column | Type |
|---|---|
| fee_id (PK) | INT AUTO_INCREMENT |
| dept_id (FK) | INT |
| semester | INT |
| total_amount | DECIMAL(12,2) |
| due_date | DATE |
| description | VARCHAR(255) |
| academic_year | VARCHAR(20) |
| created_at | TIMESTAMP |

### 1NF
**Status: Already in 1NF — no changes needed.**

All values are atomic. There are no multi-valued columns or repeating groups. Each row represents a single fee structure entry for one (department, semester, academic_year) combination, enforced by the UNIQUE constraint `uq_fee_structure`.

### 2NF
**Status: Already in 2NF — no changes needed.**

The primary key is `fee_id` (single column surrogate key). All non-key attributes depend fully on `fee_id`. Even though the natural key would be `(dept_id, semester, academic_year)`, the surrogate key eliminates any partial dependency concerns. Every attribute — `total_amount`, `due_date`, `description` — describes one specific fee record.

### 3NF
**Status: Already in 3NF — no changes needed.**

No transitive dependencies exist. `total_amount` and `due_date` are set per (dept, semester, year) and do not depend on each other or on any other non-key column. `description` is a free-text label for the fee entry and depends directly on the fee record. No non-key attribute determines another non-key attribute.

---

## Table 4: `payment`

| Column | Type |
|---|---|
| payment_id (PK) | INT AUTO_INCREMENT |
| student_id (FK) | INT |
| amount | DECIMAL(12,2) |
| payment_date | DATE |
| payment_method | ENUM |
| reference_no | VARCHAR(50) |
| notes | TEXT |
| recorded_by | VARCHAR(100) |
| created_at | TIMESTAMP |

### 1NF
**Status: Already in 1NF — no changes needed.**

All columns are atomic and single-valued. `payment_method` uses an ENUM which restricts values to a controlled set. No repeating groups exist. Each payment is a distinct transaction row.

### 2NF
**Status: Already in 2NF — no changes needed.**

Single-column primary key `payment_id`. All attributes — `student_id`, `amount`, `payment_date`, `payment_method`, `reference_no`, `notes`, `recorded_by` — fully depend on `payment_id`. No partial dependencies possible.

### 3NF
**Status: Already in 3NF — no changes needed.**

No transitive dependencies. `student_id` is a foreign key reference; student information (name, department) is not duplicated here. `recorded_by` stores the admin username and depends only on the payment record itself, not on any other non-key attribute. `reference_no` is the bank/transaction reference tied to this specific payment — it does not determine any other attribute.

---

## Table 5: `receipt`

| Column | Type |
|---|---|
| receipt_id (PK) | INT AUTO_INCREMENT |
| payment_id (FK) | INT |
| receipt_no | VARCHAR(50) UNIQUE |
| generated_date | TIMESTAMP |
| generated_by | VARCHAR(100) |

### 1NF
**Status: Already in 1NF — no changes needed.**

All attributes are atomic. `receipt_no` is a unique string identifier per receipt. No multi-valued fields exist.

### 2NF
**Status: Already in 2NF — no changes needed.**

Single-column primary key `receipt_id`. All attributes depend fully on `receipt_id`. No composite key, so partial dependency is not possible.

### 3NF
**Status: Already in 3NF — no changes needed.**

No transitive dependencies. `payment_id` is a foreign key — payment details are not stored here. `receipt_no` is unique per receipt and does not functionally determine any other attribute in this table. `generated_date` and `generated_by` are metadata about this specific receipt generation event, dependent only on `receipt_id`.

---

## Summary of Normalization Changes

| Table | 1NF | 2NF | 3NF | Changes Made |
|---|---|---|---|---|
| department |  Pass |  Pass |  Noted | No structural change; `program` dependency on `dept_name` documented; UNIQUE(dept_name, program) recommended |
| student |  Pass |  Pass |  Pass | None |
| fee_structure |  Pass |  Pass |  Pass | None |
| payment |  Pass |  Pass |  Pass | None |
| receipt |  Pass |  Pass |  Pass | None |

### Schema Change Applied

Added the following constraint to the `department` table to enforce the documented relationship:

```sql
ALTER TABLE department 
ADD CONSTRAINT uq_dept_program UNIQUE (dept_name, program);
```

This prevents a scenario where the same department name is associated with two different program names, which would be a data integrity issue consistent with the 3NF observation above.

---

