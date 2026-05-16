-- ============================================================
-- STUDENT FEE MANAGEMENT SYSTEM (SFMS)
-- Milestone 4 — DDL Script (Final Normalized Schema)
-- MySQL 8.0+
-- Author: Muhammad Aimal
-- ============================================================

-- Create and select database
CREATE DATABASE IF NOT EXISTS sfms_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sfms_db;

-- Drop tables in reverse FK order (for clean re-runs)
DROP TABLE IF EXISTS receipt;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS fee_structure;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS department;

-- ============================================================
-- TABLE 1: department
-- Root reference table. All students and fee structures
-- belong to a department.
-- ============================================================
CREATE TABLE department (
    dept_id       INT            AUTO_INCREMENT  PRIMARY KEY,
    dept_name     VARCHAR(100)   NOT NULL,
    program       VARCHAR(100)   NOT NULL,
    created_at    TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_dept_program     UNIQUE (dept_name, program),
    CONSTRAINT chk_dept_name       CHECK (LENGTH(TRIM(dept_name)) >= 2),
    CONSTRAINT chk_program         CHECK (LENGTH(TRIM(program)) >= 2)
) ENGINE=InnoDB
  COMMENT='Stores university departments and their associated programs.';


-- ============================================================
-- TABLE 2: student
-- Stores one record per enrolled student.
-- FK to department. Soft-delete via status ENUM.
-- ============================================================
CREATE TABLE student (
    student_id      INT            AUTO_INCREMENT  PRIMARY KEY,
    roll_no         VARCHAR(20)    NOT NULL         UNIQUE,
    name            VARCHAR(100)   NOT NULL,
    email           VARCHAR(100),
    phone           VARCHAR(20),
    dept_id         INT            NOT NULL,
    semester        INT            NOT NULL,
    address         TEXT,
    admission_date  DATE           NOT NULL,
    status          ENUM('Active','Inactive','Graduated')
                                   NOT NULL         DEFAULT 'Active',
    created_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_student_dept
        FOREIGN KEY (dept_id)
        REFERENCES department(dept_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_semester        CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT chk_roll_no         CHECK (LENGTH(TRIM(roll_no)) >= 3),
    CONSTRAINT chk_email_format    CHECK (email IS NULL OR email LIKE '%@%.%')
) ENGINE=InnoDB
  COMMENT='Stores student profiles. Status column used for soft delete.';


-- ============================================================
-- TABLE 3: fee_structure
-- Defines the fee amount for each (dept, semester, academic_year).
-- UNIQUE constraint on (dept_id, semester, academic_year) prevents
-- duplicate fee definitions for the same period.
-- ============================================================
CREATE TABLE fee_structure (
    fee_id          INT              AUTO_INCREMENT  PRIMARY KEY,
    dept_id         INT              NOT NULL,
    semester        INT              NOT NULL,
    total_amount    DECIMAL(12, 2)   NOT NULL,
    due_date        DATE             NOT NULL,
    description     VARCHAR(255),
    academic_year   VARCHAR(20)      NOT NULL,
    created_at      TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fee_dept
        FOREIGN KEY (dept_id)
        REFERENCES department(dept_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_fee_structure
        UNIQUE (dept_id, semester, academic_year),

    CONSTRAINT chk_fee_semester    CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT chk_total_amount    CHECK (total_amount > 0),
    CONSTRAINT chk_academic_year   CHECK (academic_year REGEXP '^[0-9]{4}-[0-9]{4}$')
) ENGINE=InnoDB
  COMMENT='Fee amounts per department per semester per academic year.';


-- ============================================================
-- TABLE 4: payment
-- One row per payment transaction. Supports installments
-- (multiple payments per student).
-- ============================================================
CREATE TABLE payment (
    payment_id      INT              AUTO_INCREMENT  PRIMARY KEY,
    student_id      INT              NOT NULL,
    amount          DECIMAL(12, 2)   NOT NULL,
    payment_date    DATE             NOT NULL,
    payment_method  ENUM('Cash','Bank Transfer','Online','Cheque')
                                     NOT NULL,
    reference_no    VARCHAR(50),
    notes           TEXT,
    recorded_by     VARCHAR(100)     NOT NULL         DEFAULT 'Admin',
    created_at      TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_payment_amount  CHECK (amount > 0)
) ENGINE=InnoDB
  COMMENT='All payment transactions. Supports partial/installment payments.';


-- ============================================================
-- TABLE 5: receipt
-- Auto-generated (via trigger) for every payment.
-- One receipt per payment — enforced by UNIQUE on payment_id.
-- ============================================================
CREATE TABLE receipt (
    receipt_id      INT            AUTO_INCREMENT  PRIMARY KEY,
    payment_id      INT            NOT NULL         UNIQUE,
    receipt_no      VARCHAR(50)    NOT NULL         UNIQUE,
    generated_date  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    generated_by    VARCHAR(100)   NOT NULL         DEFAULT 'Admin',

    CONSTRAINT fk_receipt_payment
        FOREIGN KEY (payment_id)
        REFERENCES payment(payment_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_receipt_no     CHECK (LENGTH(receipt_no) >= 5)
) ENGINE=InnoDB
  COMMENT='Receipts auto-generated by trigger after each payment insert.';


-- ============================================================
-- INDEXES
-- Purpose: speed up frequent JOIN and WHERE operations
-- ============================================================

-- student: searches by roll_no, name, dept
CREATE INDEX idx_student_roll     ON student(roll_no);
CREATE INDEX idx_student_name     ON student(name);
CREATE INDEX idx_student_dept     ON student(dept_id);
CREATE INDEX idx_student_status   ON student(status);

-- payment: filter by student, date range, method
CREATE INDEX idx_payment_student  ON payment(student_id);
CREATE INDEX idx_payment_date     ON payment(payment_date);
CREATE INDEX idx_payment_method   ON payment(payment_method);

-- fee_structure: join on (dept_id, semester) frequently
CREATE INDEX idx_fee_dept_sem     ON fee_structure(dept_id, semester);
CREATE INDEX idx_fee_year         ON fee_structure(academic_year);

-- receipt: lookup by payment
CREATE INDEX idx_receipt_payment  ON receipt(payment_id);


-- ============================================================
-- VIEWS
-- ============================================================

-- View: Student Dues Summary
CREATE OR REPLACE VIEW v_student_dues AS
SELECT
    s.student_id,
    s.roll_no,
    s.name                                                          AS student_name,
    d.dept_name,
    d.program,
    s.semester,
    fs.total_amount                                                 AS total_fee,
    COALESCE(SUM(p.amount), 0)                                      AS total_paid,
    fs.total_amount - COALESCE(SUM(p.amount), 0)                    AS pending_dues,
    fs.due_date,
    CASE
        WHEN fs.total_amount - COALESCE(SUM(p.amount), 0) <= 0     THEN 'Paid'
        WHEN fs.due_date < CURDATE()                                THEN 'Overdue'
        ELSE 'Pending'
    END                                                             AS payment_status
FROM student s
JOIN  department   d  ON s.dept_id   = d.dept_id
LEFT JOIN fee_structure fs ON s.dept_id = fs.dept_id AND s.semester = fs.semester
LEFT JOIN payment   p  ON s.student_id = p.student_id
WHERE s.status = 'Active'
GROUP BY s.student_id, s.roll_no, s.name, d.dept_name, d.program,
         s.semester, fs.total_amount, fs.due_date;


-- View: Department Summary
-- FIXED: Used subqueries to avoid Cartesian product multiplication
-- when joining students, fee_structures and payments together.
CREATE OR REPLACE VIEW v_department_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    d.program,
    COUNT(DISTINCT s.student_id)                                    AS total_students,
    COUNT(DISTINCT fs.fee_id)                                       AS fee_structures,
    COALESCE((SELECT SUM(fs2.total_amount)
              FROM fee_structure fs2
              WHERE fs2.dept_id = d.dept_id), 0)                    AS total_fees_expected,
    COALESCE(SUM(p.amount), 0)                                      AS total_collected,
    COALESCE((SELECT SUM(fs2.total_amount)
              FROM fee_structure fs2
              WHERE fs2.dept_id = d.dept_id), 0)
        - COALESCE(SUM(p.amount), 0)                                AS total_pending
FROM department d
LEFT JOIN student       s  ON d.dept_id    = s.dept_id  AND s.status = 'Active'
LEFT JOIN fee_structure fs ON d.dept_id    = fs.dept_id
LEFT JOIN payment       p  ON s.student_id = p.student_id
GROUP BY d.dept_id, d.dept_name, d.program;


-- View: Full Payment History
CREATE OR REPLACE VIEW v_payment_history AS
SELECT
    p.payment_id,
    p.payment_date,
    s.roll_no,
    s.name                AS student_name,
    d.dept_name,
    s.semester,
    p.amount,
    p.payment_method,
    p.reference_no,
    p.notes,
    p.recorded_by,
    r.receipt_no,
    r.receipt_id
FROM payment p
JOIN  student    s ON p.student_id = s.student_id
JOIN  department d ON s.dept_id    = d.dept_id
LEFT JOIN receipt r ON p.payment_id  = r.payment_id
ORDER BY p.payment_date DESC;


-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER //

-- Get dues for a single student
-- FIXED: Added all non-aggregated columns to GROUP BY for strict
-- ONLY_FULL_GROUP_BY compliance.
CREATE PROCEDURE IF NOT EXISTS sp_get_student_dues(IN p_student_id INT)
BEGIN
    SELECT
        s.student_id,
        s.roll_no,
        s.name,
        d.dept_name,
        s.semester,
        fs.total_amount,
        COALESCE(SUM(p.amount), 0)                       AS total_paid,
        fs.total_amount - COALESCE(SUM(p.amount), 0)     AS pending_amount
    FROM student s
    JOIN department   d  ON s.dept_id   = d.dept_id
    LEFT JOIN fee_structure fs ON s.dept_id = fs.dept_id AND s.semester = fs.semester
    LEFT JOIN payment   p  ON s.student_id = p.student_id
    WHERE s.student_id = p_student_id
    GROUP BY s.student_id, s.roll_no, s.name, d.dept_name, s.semester, fs.total_amount;
END //

-- Semester-wise collection report
-- FIXED: Used a subquery for fee totals to avoid Cartesian product
-- multiplication caused by joining students and fee_structures.
CREATE PROCEDURE IF NOT EXISTS sp_semester_report(
    IN  p_semester       INT,
    IN  p_academic_year  VARCHAR(20)
)
BEGIN
    SELECT
        d.dept_name,
        COUNT(DISTINCT s.student_id)                     AS total_students,
        COALESCE((SELECT SUM(fs2.total_amount)
                  FROM fee_structure fs2
                  WHERE fs2.dept_id = d.dept_id
                    AND fs2.semester = p_semester
                    AND fs2.academic_year = p_academic_year), 0) AS total_fees,
        COALESCE(SUM(p.amount), 0)                       AS total_collected,
        COALESCE((SELECT SUM(fs2.total_amount)
                  FROM fee_structure fs2
                  WHERE fs2.dept_id = d.dept_id
                    AND fs2.semester = p_semester
                    AND fs2.academic_year = p_academic_year), 0)
            - COALESCE(SUM(p.amount), 0)                  AS total_pending
    FROM department d
    LEFT JOIN student       s  ON d.dept_id    = s.dept_id
                               AND s.semester  = p_semester
                               AND s.status    = 'Active'
    LEFT JOIN payment       p  ON s.student_id = p.student_id
    GROUP BY d.dept_id, d.dept_name;
END //

DELIMITER ;


-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- Auto-generate receipt after payment INSERT
CREATE TRIGGER IF NOT EXISTS trg_after_payment_insert
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE new_receipt_no VARCHAR(50);
    SET new_receipt_no = CONCAT(
        'RCP-',
        DATE_FORMAT(NOW(), '%Y%m%d'),
        '-',
        LPAD(NEW.payment_id, 5, '0')
    );
    INSERT INTO receipt (payment_id, receipt_no, generated_by)
    VALUES (NEW.payment_id, new_receipt_no, COALESCE(NEW.recorded_by, 'Admin'));
END //

-- Validate payment date cannot be in the future (INSERT)
-- Replaces the invalid CHECK constraint that used CURDATE().
CREATE TRIGGER IF NOT EXISTS trg_validate_payment_date_insert
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.payment_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment date cannot be in the future.';
    END IF;
END //

-- Validate payment date cannot be in the future (UPDATE)
CREATE TRIGGER IF NOT EXISTS trg_validate_payment_date_update
BEFORE UPDATE ON payment
FOR EACH ROW
BEGIN
    IF NEW.payment_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Payment date cannot be in the future.';
    END IF;
END //

DELIMITER ;

-- ============================================================
-- END OF DDL SCRIPT
-- ============================================================
