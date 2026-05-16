-- ============================================================
-- STUDENT FEE MANAGEMENT SYSTEM (SFMS)
-- Milestone 5 — DML Script: Data Population & Validation
-- MySQL 8.0+
-- Author: Muhammad Aimal
-- ============================================================

USE sfms_db;

-- ============================================================
-- SECTION A: LOAD DATA (Option 1 — LOAD DATA INFILE)
-- Uncomment and set correct file paths if using CSV approach.
-- Ensure MySQL secure_file_priv allows the directory.
-- ============================================================

/*
-- Step 1: Load departments first (no FKs)
LOAD DATA INFILE '/path/to/csv/department.csv'
INTO TABLE department
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(dept_id, dept_name, program, created_at);

-- Step 2: Load students (FK → department)
LOAD DATA INFILE '/path/to/csv/student.csv'
INTO TABLE student
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(student_id, roll_no, name, email, phone, dept_id, semester,
 address, admission_date, status, created_at, updated_at);

-- Step 3: Load fee structures (FK → department)
LOAD DATA INFILE '/path/to/csv/fee_structure.csv'
INTO TABLE fee_structure
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(fee_id, dept_id, semester, total_amount, due_date,
 description, academic_year, created_at);

-- Step 4: Load payments (FK → student; trigger auto-inserts receipt)
LOAD DATA INFILE '/path/to/csv/payment.csv'
INTO TABLE payment
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, student_id, amount, payment_date, payment_method,
 reference_no, notes, recorded_by, created_at);

-- NOTE: receipt table is auto-populated by trigger trg_after_payment_insert
-- Do NOT load receipt.csv separately unless trigger is disabled.
*/


-- ============================================================
-- SECTION B: INSERT STATEMENTS (Option 2 — Direct Inserts)
-- Full synthetic dataset for all 5 tables.
-- ============================================================

-- Disable FK checks temporarily for bulk load
SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- ── Departments (8 rows) ─────────────────────────────────────

TRUNCATE TABLE receipt;
TRUNCATE TABLE payment;
TRUNCATE TABLE fee_structure;
TRUNCATE TABLE student;
TRUNCATE TABLE department;

INSERT INTO department (dept_id, dept_name, program) VALUES
(1, 'Computer Science',        'BS Computer Science'),
(2, 'Software Engineering',    'BS Software Engineering'),
(3, 'Information Technology',  'BS Information Technology'),
(4, 'Electrical Engineering',  'BS Electrical Engineering'),
(5, 'Business Administration', 'BBA'),
(6, 'Mathematics',             'BS Mathematics'),
(7, 'Physics',                 'BS Physics'),
(8, 'Artificial Intelligence', 'BS Artificial Intelligence');

-- ── Students (80 rows) ───────────────────────────────────────

INSERT INTO student (student_id, roll_no, name, email, phone, dept_id, semester, address, admission_date, status) VALUES
(1,  'CS-2024-001', 'Ali Khan',           'ali.khan1@university.edu.pk',       '0300-1234567', 1, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(2,  'CS-2024-002', 'Fatima Ahmed',       'fatima.ahmed2@university.edu.pk',   '0301-2345678', 1, 1, 'Karachi, Pakistan',    '2024-09-01', 'Active'),
(3,  'CS-2023-003', 'Usman Ali',          'usman.ali3@university.edu.pk',      '0302-3456789', 1, 3, 'Islamabad, Pakistan',  '2023-09-01', 'Active'),
(4,  'CS-2023-004', 'Ayesha Malik',       'ayesha.malik4@university.edu.pk',   '0303-4567890', 1, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(5,  'CS-2022-005', 'Bilal Hassan',       'bilal.hassan5@university.edu.pk',   '0304-5678901', 1, 5, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(6,  'CS-2022-006', 'Sara Iqbal',         'sara.iqbal6@university.edu.pk',     '0305-6789012', 1, 5, 'Rawalpindi, Pakistan', '2022-09-01', 'Active'),
(7,  'CS-2021-007', 'Hamza Tariq',        'hamza.tariq7@university.edu.pk',    '0306-7890123', 1, 7, 'Multan, Pakistan',     '2021-09-01', 'Active'),
(8,  'CS-2021-008', 'Zainab Raza',        'zainab.raza8@university.edu.pk',    '0307-8901234', 1, 7, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(9,  'CS-2021-009', 'Omar Farooq',        'omar.farooq9@university.edu.pk',    '0308-9012345', 1, 8, 'Karachi, Pakistan',    '2021-09-01', 'Active'),
(10, 'CS-2021-010', 'Nida Shah',          'nida.shah10@university.edu.pk',     '0309-0123456', 1, 8, 'Lahore, Pakistan',     '2021-09-01', 'Graduated'),
(11, 'SE-2024-001', 'Hassan Butt',        'hassan.butt1@university.edu.pk',    '0310-1234567', 2, 1, 'Islamabad, Pakistan',  '2024-09-01', 'Active'),
(12, 'SE-2024-002', 'Maryam Chaudhry',   'maryam.chaudhry2@university.edu.pk','0311-2345678', 2, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(13, 'SE-2023-003', 'Ahmed Mirza',        'ahmed.mirza3@university.edu.pk',    '0312-3456789', 2, 3, 'Karachi, Pakistan',    '2023-09-01', 'Active'),
(14, 'SE-2023-004', 'Sana Siddiqui',      'sana.siddiqui4@university.edu.pk',  '0313-4567890', 2, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(15, 'SE-2022-005', 'Tariq Baig',         'tariq.baig5@university.edu.pk',     '0314-5678901', 2, 5, 'Multan, Pakistan',     '2022-09-01', 'Active'),
(16, 'SE-2022-006', 'Hira Qureshi',       'hira.qureshi6@university.edu.pk',   '0315-6789012', 2, 5, 'Rawalpindi, Pakistan', '2022-09-01', 'Active'),
(17, 'SE-2021-007', 'Asad Niazi',         'asad.niazi7@university.edu.pk',     '0316-7890123', 2, 7, 'Peshawar, Pakistan',   '2021-09-01', 'Active'),
(18, 'SE-2021-008', 'Rabia Abbasi',       'rabia.abbasi8@university.edu.pk',   '0317-8901234', 2, 8, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(19, 'IT-2024-001', 'Faisal Hashmi',      'faisal.hashmi1@university.edu.pk',  '0318-9012345', 3, 1, 'Karachi, Pakistan',    '2024-09-01', 'Active'),
(20, 'IT-2024-002', 'Amna Ansari',        'amna.ansari2@university.edu.pk',    '0319-0123456', 3, 1, 'Islamabad, Pakistan',  '2024-09-01', 'Active'),
(21, 'IT-2023-003', 'Imran Javed',        'imran.javed3@university.edu.pk',    '0320-1234567', 3, 3, 'Lahore, Pakistan',     '2023-09-01', 'Active'),
(22, 'IT-2023-004', 'Sobia Awan',         'sobia.awan4@university.edu.pk',     '0321-2345678', 3, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(23, 'IT-2022-005', 'Kashif Gilani',      'kashif.gilani5@university.edu.pk',  '0322-3456789', 3, 5, 'Multan, Pakistan',     '2022-09-01', 'Active'),
(24, 'IT-2022-006', 'Iqra Rajput',        'iqra.rajput6@university.edu.pk',    '0323-4567890', 3, 5, 'Hyderabad, Pakistan',  '2022-09-01', 'Active'),
(25, 'IT-2021-007', 'Danial Zafar',       'danial.zafar7@university.edu.pk',   '0324-5678901', 3, 7, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(26, 'IT-2021-008', 'Mahnoor Mughal',     'mahnoor.mughal8@university.edu.pk', '0325-6789012', 3, 8, 'Karachi, Pakistan',    '2021-09-01', 'Graduated'),
(27, 'EE-2024-001', 'Zubair Bhatti',      'zubair.bhatti1@university.edu.pk',  '0326-7890123', 4, 1, 'Islamabad, Pakistan',  '2024-09-01', 'Active'),
(28, 'EE-2024-002', 'Kiran Akram',        'kiran.akram2@university.edu.pk',    '0327-8901234', 4, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(29, 'EE-2023-003', 'Shoaib Noor',        'shoaib.noor3@university.edu.pk',    '0328-9012345', 4, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(30, 'EE-2023-004', 'Layla Rafiq',        'layla.rafiq4@university.edu.pk',    '0329-0123456', 4, 3, 'Peshawar, Pakistan',   '2023-09-01', 'Active'),
(31, 'EE-2022-005', 'Rehan Khan',         'rehan.khan5@university.edu.pk',     '0330-1234567', 4, 5, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(32, 'EE-2022-006', 'Sidra Ahmed',        'sidra.ahmed6@university.edu.pk',    '0331-2345678', 4, 5, 'Karachi, Pakistan',    '2022-09-01', 'Active'),
(33, 'EE-2021-007', 'Waqas Ali',          'waqas.ali7@university.edu.pk',      '0332-3456789', 4, 7, 'Multan, Pakistan',     '2021-09-01', 'Active'),
(34, 'EE-2021-008', 'Tooba Malik',        'tooba.malik8@university.edu.pk',    '0333-4567890', 4, 8, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(35, 'BBA-2024-001','Adnan Hassan',       'adnan.hassan1@university.edu.pk',   '0334-5678901', 5, 1, 'Islamabad, Pakistan',  '2024-09-01', 'Active'),
(36, 'BBA-2024-002','Bushra Iqbal',       'bushra.iqbal2@university.edu.pk',   '0335-6789012', 5, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(37, 'BBA-2023-003','Junaid Tariq',       'junaid.tariq3@university.edu.pk',   '0336-7890123', 5, 3, 'Karachi, Pakistan',    '2023-09-01', 'Active'),
(38, 'BBA-2023-004','Aliza Raza',         'aliza.raza4@university.edu.pk',     '0337-8901234', 5, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(39, 'BBA-2022-005','Saad Farooq',        'saad.farooq5@university.edu.pk',    '0338-9012345', 5, 5, 'Rawalpindi, Pakistan', '2022-09-01', 'Active'),
(40, 'BBA-2022-006','Nimra Shah',         'nimra.shah6@university.edu.pk',     '0339-0123456', 5, 5, 'Multan, Pakistan',     '2022-09-01', 'Active'),
(41, 'BBA-2021-007','Rizwan Butt',        'rizwan.butt7@university.edu.pk',    '0340-1234567', 5, 7, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(42, 'BBA-2021-008','Huma Chaudhry',      'huma.chaudhry8@university.edu.pk',  '0341-2345678', 5, 8, 'Karachi, Pakistan',    '2021-09-01', 'Active'),
(43, 'MATH-2024-001','Shahid Mirza',      'shahid.mirza1@university.edu.pk',   '0342-3456789', 6, 1, 'Islamabad, Pakistan',  '2024-09-01', 'Active'),
(44, 'MATH-2024-002','Farah Siddiqui',    'farah.siddiqui2@university.edu.pk', '0343-4567890', 6, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(45, 'MATH-2023-003','Kamran Baig',       'kamran.baig3@university.edu.pk',    '0344-5678901', 6, 3, 'Faisalabad, Pakistan', '2023-09-01', 'Active'),
(46, 'MATH-2023-004','Zara Qureshi',      'zara.qureshi4@university.edu.pk',   '0345-6789012', 6, 3, 'Karachi, Pakistan',    '2023-09-01', 'Active'),
(47, 'MATH-2022-005','Jawad Niazi',       'jawad.niazi5@university.edu.pk',    '0346-7890123', 6, 5, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(48, 'MATH-2022-006','Amber Abbasi',      'amber.abbasi6@university.edu.pk',   '0347-8901234', 6, 5, 'Multan, Pakistan',     '2022-09-01', 'Active'),
(49, 'PHY-2024-001', 'Naeem Hashmi',      'naeem.hashmi1@university.edu.pk',   '0348-9012345', 7, 1, 'Peshawar, Pakistan',   '2024-09-01', 'Active'),
(50, 'PHY-2024-002', 'Rida Ansari',       'rida.ansari2@university.edu.pk',    '0349-0123456', 7, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(51, 'PHY-2023-003', 'Hassan Javed',      'hassan.javed3@university.edu.pk',   '0300-1111001', 7, 3, 'Karachi, Pakistan',    '2023-09-01', 'Active'),
(52, 'PHY-2023-004', 'Maryam Awan',       'maryam.awan4@university.edu.pk',    '0300-1111002', 7, 3, 'Islamabad, Pakistan',  '2023-09-01', 'Active'),
(53, 'PHY-2022-005', 'Ahmed Gilani',      'ahmed.gilani5@university.edu.pk',   '0300-1111003', 7, 5, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(54, 'PHY-2022-006', 'Sana Rajput',       'sana.rajput6@university.edu.pk',    '0300-1111004', 7, 5, 'Faisalabad, Pakistan', '2022-09-01', 'Active'),
(55, 'AI-2024-001',  'Tariq Zafar',       'tariq.zafar1@university.edu.pk',    '0300-1111005', 8, 1, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(56, 'AI-2024-002',  'Hira Mughal',       'hira.mughal2@university.edu.pk',    '0300-1111006', 8, 1, 'Karachi, Pakistan',    '2024-09-01', 'Active'),
(57, 'AI-2023-003',  'Asad Bhatti',       'asad.bhatti3@university.edu.pk',    '0300-1111007', 8, 3, 'Islamabad, Pakistan',  '2023-09-01', 'Active'),
(58, 'AI-2023-004',  'Rabia Akram',       'rabia.akram4@university.edu.pk',    '0300-1111008', 8, 3, 'Lahore, Pakistan',     '2023-09-01', 'Active'),
(59, 'AI-2022-005',  'Faisal Noor',       'faisal.noor5@university.edu.pk',    '0300-1111009', 8, 5, 'Faisalabad, Pakistan', '2022-09-01', 'Active'),
(60, 'AI-2022-006',  'Amna Rafiq',        'amna.rafiq6@university.edu.pk',     '0300-1111010', 8, 5, 'Karachi, Pakistan',    '2022-09-01', 'Active'),
(61, 'CS-2022-011',  'Imran Khan',        'imran.khan11@university.edu.pk',    '0300-1111011', 1, 6, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(62, 'CS-2022-012',  'Sobia Ahmed',       'sobia.ahmed12@university.edu.pk',   '0300-1111012', 1, 6, 'Karachi, Pakistan',    '2022-09-01', 'Active'),
(63, 'SE-2022-009',  'Kashif Ali',        'kashif.ali9@university.edu.pk',     '0300-1111013', 2, 6, 'Islamabad, Pakistan',  '2022-09-01', 'Active'),
(64, 'SE-2022-010',  'Iqra Malik',        'iqra.malik10@university.edu.pk',    '0300-1111014', 2, 6, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(65, 'IT-2022-009',  'Danial Hassan',     'danial.hassan9@university.edu.pk',  '0300-1111015', 3, 6, 'Karachi, Pakistan',    '2022-09-01', 'Active'),
(66, 'EE-2022-009',  'Mahnoor Iqbal',     'mahnoor.iqbal9@university.edu.pk',  '0300-1111016', 4, 6, 'Faisalabad, Pakistan', '2022-09-01', 'Active'),
(67, 'BBA-2022-009', 'Zubair Tariq',      'zubair.tariq9@university.edu.pk',   '0300-1111017', 5, 6, 'Lahore, Pakistan',     '2022-09-01', 'Active'),
(68, 'CS-2021-011',  'Kiran Raza',        'kiran.raza11@university.edu.pk',    '0300-1111018', 1, 8, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(69, 'SE-2021-009',  'Shoaib Farooq',     'shoaib.farooq9@university.edu.pk',  '0300-1111019', 2, 8, 'Karachi, Pakistan',    '2021-09-01', 'Active'),
(70, 'IT-2021-009',  'Layla Shah',        'layla.shah9@university.edu.pk',     '0300-1111020', 3, 8, 'Islamabad, Pakistan',  '2021-09-01', 'Active'),
(71, 'EE-2024-003',  'Rehan Butt',        'rehan.butt3@university.edu.pk',     '0300-1111021', 4, 2, 'Lahore, Pakistan',     '2024-09-01', 'Active'),
(72, 'EE-2024-004',  'Sidra Chaudhry',    'sidra.chaudhry4@university.edu.pk', '0300-1111022', 4, 2, 'Karachi, Pakistan',    '2024-09-01', 'Active'),
(73, 'BBA-2024-003', 'Waqas Mirza',       'waqas.mirza3@university.edu.pk',    '0300-1111023', 5, 2, 'Faisalabad, Pakistan', '2024-09-01', 'Active'),
(74, 'MATH-2021-007','Tooba Siddiqui',    'tooba.siddiqui7@university.edu.pk', '0300-1111024', 6, 7, 'Lahore, Pakistan',     '2021-09-01', 'Active'),
(75, 'PHY-2021-007', 'Adnan Baig',        'adnan.baig7@university.edu.pk',     '0300-1111025', 7, 7, 'Karachi, Pakistan',    '2021-09-01', 'Active'),
(76, 'AI-2021-007',  'Bushra Qureshi',    'bushra.qureshi7@university.edu.pk', '0300-1111026', 8, 7, 'Islamabad, Pakistan',  '2021-09-01', 'Active'),
(77, 'CS-2023-013',  'Junaid Niazi',      'junaid.niazi13@university.edu.pk',  '0300-1111027', 1, 4, 'Lahore, Pakistan',     '2023-09-01', 'Inactive'),
(78, 'SE-2023-011',  'Aliza Abbasi',      'aliza.abbasi11@university.edu.pk',  '0300-1111028', 2, 4, 'Karachi, Pakistan',    '2023-09-01', 'Inactive'),
(79, 'IT-2023-011',  'Saad Hashmi',       'saad.hashmi11@university.edu.pk',   '0300-1111029', 3, 4, 'Islamabad, Pakistan',  '2023-09-01', 'Active'),
(80, 'AI-2023-011',  'Nimra Ansari',      'nimra.ansari11@university.edu.pk',  '0300-1111030', 8, 4, 'Lahore, Pakistan',     '2023-09-01', 'Active');


-- ── Fee Structures (sample — 2 academic years, key semesters) ─────────

INSERT INTO fee_structure (dept_id, semester, total_amount, due_date, description, academic_year) VALUES
-- CS 2024-2025
(1,1,85000.00,'2024-09-15','BS Computer Science Sem 1','2024-2025'),
(1,2,85000.00,'2025-02-15','BS Computer Science Sem 2','2024-2025'),
(1,3,90000.00,'2024-09-15','BS Computer Science Sem 3','2024-2025'),
(1,4,90000.00,'2025-02-15','BS Computer Science Sem 4','2024-2025'),
(1,5,95000.00,'2024-09-15','BS Computer Science Sem 5','2024-2025'),
(1,6,95000.00,'2025-02-15','BS Computer Science Sem 6','2024-2025'),
(1,7,100000.00,'2024-09-15','BS Computer Science Sem 7','2024-2025'),
(1,8,100000.00,'2025-02-15','BS Computer Science Sem 8','2024-2025'),
-- SE 2024-2025
(2,1,80000.00,'2024-09-15','BS Software Engineering Sem 1','2024-2025'),
(2,2,80000.00,'2025-02-15','BS Software Engineering Sem 2','2024-2025'),
(2,3,85000.00,'2024-09-15','BS Software Engineering Sem 3','2024-2025'),
(2,4,85000.00,'2025-02-15','BS Software Engineering Sem 4','2024-2025'),
(2,5,90000.00,'2024-09-15','BS Software Engineering Sem 5','2024-2025'),
(2,6,90000.00,'2025-02-15','BS Software Engineering Sem 6','2024-2025'),
(2,7,95000.00,'2024-09-15','BS Software Engineering Sem 7','2024-2025'),
(2,8,95000.00,'2025-02-15','BS Software Engineering Sem 8','2024-2025'),
-- IT 2024-2025
(3,1,75000.00,'2024-09-15','BS IT Sem 1','2024-2025'),
(3,2,75000.00,'2025-02-15','BS IT Sem 2','2024-2025'),
(3,3,80000.00,'2024-09-15','BS IT Sem 3','2024-2025'),
(3,4,80000.00,'2025-02-15','BS IT Sem 4','2024-2025'),
(3,5,85000.00,'2024-09-15','BS IT Sem 5','2024-2025'),
(3,6,85000.00,'2025-02-15','BS IT Sem 6','2024-2025'),
(3,7,90000.00,'2024-09-15','BS IT Sem 7','2024-2025'),
(3,8,90000.00,'2025-02-15','BS IT Sem 8','2024-2025'),
-- EE 2024-2025
(4,1,70000.00,'2024-09-15','BS EE Sem 1','2024-2025'),
(4,2,70000.00,'2025-02-15','BS EE Sem 2','2024-2025'),
(4,3,75000.00,'2024-09-15','BS EE Sem 3','2024-2025'),
(4,4,75000.00,'2025-02-15','BS EE Sem 4','2024-2025'),
(4,5,80000.00,'2024-09-15','BS EE Sem 5','2024-2025'),
(4,6,80000.00,'2025-02-15','BS EE Sem 6','2024-2025'),
(4,7,85000.00,'2024-09-15','BS EE Sem 7','2024-2025'),
(4,8,85000.00,'2025-02-15','BS EE Sem 8','2024-2025'),
-- BBA 2024-2025
(5,1,60000.00,'2024-09-15','BBA Sem 1','2024-2025'),
(5,2,60000.00,'2025-02-15','BBA Sem 2','2024-2025'),
(5,3,65000.00,'2024-09-15','BBA Sem 3','2024-2025'),
(5,4,65000.00,'2025-02-15','BBA Sem 4','2024-2025'),
(5,5,70000.00,'2024-09-15','BBA Sem 5','2024-2025'),
(5,6,70000.00,'2025-02-15','BBA Sem 6','2024-2025'),
(5,7,75000.00,'2024-09-15','BBA Sem 7','2024-2025'),
(5,8,75000.00,'2025-02-15','BBA Sem 8','2024-2025'),
-- MATH 2024-2025
(6,1,55000.00,'2024-09-15','BS Mathematics Sem 1','2024-2025'),
(6,3,60000.00,'2024-09-15','BS Mathematics Sem 3','2024-2025'),
(6,5,65000.00,'2024-09-15','BS Mathematics Sem 5','2024-2025'),
(6,7,70000.00,'2024-09-15','BS Mathematics Sem 7','2024-2025'),
-- PHY 2024-2025
(7,1,55000.00,'2024-09-15','BS Physics Sem 1','2024-2025'),
(7,3,60000.00,'2024-09-15','BS Physics Sem 3','2024-2025'),
(7,5,65000.00,'2024-09-15','BS Physics Sem 5','2024-2025'),
(7,7,70000.00,'2024-09-15','BS Physics Sem 7','2024-2025'),
-- AI 2024-2025
(8,1,98000.00,'2024-09-15','BS AI Sem 1','2024-2025'),
(8,2,98000.00,'2025-02-15','BS AI Sem 2','2024-2025'),
(8,3,102000.00,'2024-09-15','BS AI Sem 3','2024-2025'),
(8,4,102000.00,'2025-02-15','BS AI Sem 4','2024-2025'),
(8,5,106000.00,'2024-09-15','BS AI Sem 5','2024-2025'),
(8,6,106000.00,'2025-02-15','BS AI Sem 6','2024-2025'),
(8,7,110000.00,'2024-09-15','BS AI Sem 7','2024-2025'),
(8,8,110000.00,'2025-02-15','BS AI Sem 8','2024-2025');


-- ── Payments (100 rows) — receipt auto-created by trigger ────────────

INSERT INTO payment (student_id, amount, payment_date, payment_method, reference_no, notes, recorded_by) VALUES
(1,  85000.00, '2024-09-10', 'Bank Transfer', 'BT-20240910-001', 'Full payment',          'Admin'),
(2,  42500.00, '2024-09-08', 'Cash',           NULL,              'First installment',      'Admin'),
(2,  42500.00, '2024-10-15', 'Cash',           NULL,              'Second installment',     'Admin'),
(3,  90000.00, '2024-09-05', 'Online',         'ON-20240905-003', 'Full payment via portal','Admin'),
(4,  45000.00, '2024-09-12', 'Bank Transfer',  'BT-20240912-004', 'Partial payment',        'Admin'),
(5,  95000.00, '2024-09-03', 'Bank Transfer',  'BT-20240903-005', 'Full payment',           'Admin'),
(6,  50000.00, '2024-09-14', 'Cash',           NULL,              'First installment',      'Admin'),
(7, 100000.00, '2024-09-06', 'Online',         'ON-20240906-007', 'Full payment',           'Admin'),
(8,  60000.00, '2024-09-11', 'Bank Transfer',  'BT-20240911-008', 'Partial payment',        'Admin'),
(9, 100000.00, '2024-09-07', 'Cheque',         'CH-20240907-009', 'Full payment by cheque', 'Admin'),
(11, 80000.00, '2024-09-09', 'Bank Transfer',  'BT-20240909-011', 'Full payment',           'Admin'),
(12, 40000.00, '2024-09-13', 'Cash',           NULL,              'First installment',      'Admin'),
(13, 85000.00, '2024-09-04', 'Online',         'ON-20240904-013', 'Full payment',           'Admin'),
(14, 42500.00, '2024-09-16', 'Bank Transfer',  'BT-20240916-014', 'Partial payment',        'Admin'),
(15, 90000.00, '2024-09-02', 'Bank Transfer',  'BT-20240902-015', 'Full payment',           'Admin'),
(16, 50000.00, '2024-09-17', 'Cash',           NULL,              'First installment',      'Admin'),
(17, 95000.00, '2024-09-01', 'Online',         'ON-20240901-017', 'Full payment',           'Admin'),
(19, 75000.00, '2024-09-10', 'Bank Transfer',  'BT-20240910-019', 'Full payment',           'Admin'),
(20, 37500.00, '2024-09-18', 'Cash',           NULL,              'Partial payment',        'Admin'),
(21, 80000.00, '2024-09-05', 'Online',         'ON-20240905-021', 'Full payment',           'Admin'),
(22, 40000.00, '2024-09-14', 'Bank Transfer',  'BT-20240914-022', 'First installment',      'Admin'),
(23, 85000.00, '2024-09-03', 'Bank Transfer',  'BT-20240903-023', 'Full payment',           'Admin'),
(24, 85000.00, '2024-09-08', 'Online',         'ON-20240908-024', 'Full payment',           'Admin'),
(25, 50000.00, '2024-09-12', 'Cheque',         'CH-20240912-025', 'First installment',      'Admin'),
(27, 70000.00, '2024-09-09', 'Bank Transfer',  'BT-20240909-027', 'Full payment',           'Admin'),
(28, 35000.00, '2024-09-16', 'Cash',           NULL,              'Partial payment',        'Admin'),
(29, 75000.00, '2024-09-06', 'Online',         'ON-20240906-029', 'Full payment',           'Admin'),
(30, 37500.00, '2024-09-13', 'Bank Transfer',  'BT-20240913-030', 'First installment',      'Admin'),
(31, 80000.00, '2024-09-04', 'Bank Transfer',  'BT-20240904-031', 'Full payment',           'Admin'),
(32, 80000.00, '2024-09-07', 'Online',         'ON-20240907-032', 'Full payment',           'Admin'),
(33, 85000.00, '2024-09-11', 'Bank Transfer',  'BT-20240911-033', 'Full payment',           'Admin'),
(34, 85000.00, '2024-09-15', 'Cash',           NULL,              'Full payment',           'Admin'),
(35, 60000.00, '2024-09-10', 'Online',         'ON-20240910-035', 'Full payment',           'Admin'),
(36, 30000.00, '2024-09-18', 'Cash',           NULL,              'First installment',      'Admin'),
(37, 65000.00, '2024-09-05', 'Bank Transfer',  'BT-20240905-037', 'Full payment',           'Admin'),
(38, 32500.00, '2024-09-14', 'Bank Transfer',  'BT-20240914-038', 'Partial payment',        'Admin'),
(39, 70000.00, '2024-09-03', 'Online',         'ON-20240903-039', 'Full payment',           'Admin'),
(40, 70000.00, '2024-09-08', 'Cheque',         'CH-20240908-040', 'Full payment',           'Admin'),
(41, 75000.00, '2024-09-06', 'Bank Transfer',  'BT-20240906-041', 'Full payment',           'Admin'),
(42, 75000.00, '2024-09-12', 'Online',         'ON-20240912-042', 'Full payment',           'Admin'),
(43, 55000.00, '2024-09-09', 'Bank Transfer',  'BT-20240909-043', 'Full payment',           'Admin'),
(44, 27500.00, '2024-09-16', 'Cash',           NULL,              'First installment',      'Admin'),
(45, 60000.00, '2024-09-07', 'Online',         'ON-20240907-045', 'Full payment',           'Admin'),
(46, 60000.00, '2024-09-11', 'Bank Transfer',  'BT-20240911-046', 'Full payment',           'Admin'),
(47, 65000.00, '2024-09-05', 'Bank Transfer',  'BT-20240905-047', 'Full payment',           'Admin'),
(48, 65000.00, '2024-09-13', 'Online',         'ON-20240913-048', 'Full payment',           'Admin'),
(49, 55000.00, '2024-09-10', 'Cash',           NULL,              'Full payment',           'Admin'),
(50, 55000.00, '2024-09-08', 'Bank Transfer',  'BT-20240908-050', 'Full payment',           'Admin'),
(51, 60000.00, '2024-09-06', 'Online',         'ON-20240906-051', 'Full payment',           'Admin'),
(52, 30000.00, '2024-09-14', 'Cash',           NULL,              'First installment',      'Admin'),
(53, 65000.00, '2024-09-04', 'Bank Transfer',  'BT-20240904-053', 'Full payment',           'Admin'),
(54, 65000.00, '2024-09-09', 'Cheque',         'CH-20240909-054', 'Full payment',           'Admin'),
(55, 98000.00, '2024-09-07', 'Bank Transfer',  'BT-20240907-055', 'Full payment',           'Admin'),
(56, 49000.00, '2024-09-12', 'Online',         'ON-20240912-056', 'First installment',      'Admin'),
(57,102000.00, '2024-09-05', 'Bank Transfer',  'BT-20240905-057', 'Full payment',           'Admin'),
(58, 51000.00, '2024-09-11', 'Cash',           NULL,              'Partial payment',        'Admin'),
(59,106000.00, '2024-09-03', 'Online',         'ON-20240903-059', 'Full payment',           'Admin'),
(60,106000.00, '2024-09-08', 'Bank Transfer',  'BT-20240908-060', 'Full payment',           'Admin'),
(61, 95000.00, '2025-02-10', 'Bank Transfer',  'BT-20250210-061', 'Sem 6 full payment',     'Admin'),
(62, 47500.00, '2025-02-14', 'Cash',           NULL,              'Sem 6 partial',          'Admin'),
(63, 90000.00, '2025-02-08', 'Online',         'ON-20250208-063', 'Sem 6 full payment',     'Admin'),
(64, 45000.00, '2025-02-12', 'Bank Transfer',  'BT-20250212-064', 'Sem 6 partial',          'Admin'),
(65, 85000.00, '2025-02-09', 'Bank Transfer',  'BT-20250209-065', 'Sem 6 full payment',     'Admin'),
(66, 80000.00, '2025-02-11', 'Online',         'ON-20250211-066', 'Sem 6 full payment',     'Admin'),
(67, 70000.00, '2025-02-07', 'Bank Transfer',  'BT-20250207-067', 'Sem 6 full payment',     'Admin'),
(68,100000.00, '2025-02-15', 'Cash',           NULL,              'Sem 8 payment',          'Admin'),
(69, 95000.00, '2025-02-13', 'Online',         'ON-20250213-069', 'Sem 8 payment',          'Admin'),
(70, 90000.00, '2025-02-10', 'Bank Transfer',  'BT-20250210-070', 'Sem 8 payment',          'Admin'),
(71, 70000.00, '2025-02-12', 'Bank Transfer',  'BT-20250212-071', 'Sem 2 payment',          'Admin'),
(72, 35000.00, '2025-02-16', 'Cash',           NULL,              'Sem 2 partial',          'Admin'),
(73, 60000.00, '2025-02-11', 'Online',         'ON-20250211-073', 'Sem 2 payment',          'Admin'),
(74, 70000.00, '2024-09-10', 'Bank Transfer',  'BT-20240910-074', 'Sem 7 payment',          'Admin'),
(75, 70000.00, '2024-09-09', 'Online',         'ON-20240909-075', 'Sem 7 payment',          'Admin'),
(76,110000.00, '2024-09-08', 'Bank Transfer',  'BT-20240908-076', 'Sem 7 payment',          'Admin'),
(79, 80000.00, '2025-02-09', 'Bank Transfer',  'BT-20250209-079', 'Sem 4 payment',          'Admin'),
(80,102000.00, '2025-02-14', 'Online',         'ON-20250214-080', 'Sem 4 payment',          'Admin'),
(1,  85000.00, '2025-02-13', 'Bank Transfer',  'BT-20250213-1B',  'Sem 2 full payment',     'Admin'),
(3,  90000.00, '2025-02-10', 'Online',         'ON-20250210-3B',  'Sem 4 full payment',     'Admin'),
(5,  95000.00, '2025-02-07', 'Bank Transfer',  'BT-20250207-5B',  'Sem 6 full payment',     'Admin'),
(7, 100000.00, '2025-02-08', 'Cheque',         'CH-20250208-7B',  'Sem 8 full payment',     'Admin'),
(11, 80000.00, '2025-02-11', 'Bank Transfer',  'BT-20250211-11B', 'Sem 2 full payment',     'Admin'),
(13, 85000.00, '2025-02-09', 'Online',         'ON-20250209-13B', 'Sem 4 full payment',     'Admin'),
(15, 90000.00, '2025-02-06', 'Bank Transfer',  'BT-20250206-15B', 'Sem 6 full payment',     'Admin'),
(17, 95000.00, '2025-02-12', 'Online',         'ON-20250212-17B', 'Sem 8 full payment',     'Admin'),
(19, 75000.00, '2025-02-10', 'Bank Transfer',  'BT-20250210-19B', 'Sem 2 full payment',     'Admin'),
(21, 80000.00, '2025-02-08', 'Online',         'ON-20250208-21B', 'Sem 4 full payment',     'Admin'),
(23, 85000.00, '2025-02-07', 'Bank Transfer',  'BT-20250207-23B', 'Sem 6 full payment',     'Admin'),
(25, 40000.00, '2024-10-15', 'Cash',           NULL,              'Sem 7 second installment','Admin'),
(27, 70000.00, '2025-02-12', 'Bank Transfer',  'BT-20250212-27B', 'Sem 2 full payment',     'Admin'),
(31, 80000.00, '2025-02-09', 'Online',         'ON-20250209-31B', 'Sem 6 full payment',     'Admin'),
(39, 70000.00, '2025-02-11', 'Bank Transfer',  'BT-20250211-39B', 'Sem 6 full payment',     'Admin'),
(55, 49000.00, '2024-10-20', 'Cash',           NULL,              'Second installment',     'Admin'),
(56, 49000.00, '2024-10-22', 'Bank Transfer',  'BT-20241022-56B', 'Second installment',     'Admin'),
(58, 51000.00, '2024-10-18', 'Online',         'ON-20241018-58B', 'Second installment',     'Admin');


COMMIT;
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- SECTION C: UPDATE AND DELETE EXAMPLES
-- ============================================================

-- UPDATE Example 1: Advance a student to next semester
UPDATE student
SET semester = 6, updated_at = CURRENT_TIMESTAMP
WHERE roll_no = 'CS-2022-005';

-- UPDATE Example 2: Mark a student as Graduated
UPDATE student
SET status = 'Graduated', updated_at = CURRENT_TIMESTAMP
WHERE roll_no = 'CS-2021-009';

-- UPDATE Example 3: Correct a phone number
UPDATE student
SET phone = '0312-9876543', updated_at = CURRENT_TIMESTAMP
WHERE student_id = 12;

-- DELETE Example: Remove an orphaned partial payment record
-- (Only safe if no receipt was generated — check first)
-- DELETE FROM payment WHERE payment_id = 999 AND student_id = 4;
-- Using a safer soft-approach: update notes instead
UPDATE payment
SET notes = 'CANCELLED - duplicate entry'
WHERE reference_no = 'BT-20240912-004';


-- ============================================================
-- SECTION D: VALIDATION QUERIES
-- ============================================================

-- ── D1: Row counts per table ──────────────────────────────────
SELECT 'department'    AS table_name, COUNT(*) AS row_count FROM department
UNION ALL
SELECT 'student',       COUNT(*) FROM student
UNION ALL
SELECT 'fee_structure', COUNT(*) FROM fee_structure
UNION ALL
SELECT 'payment',       COUNT(*) FROM payment
UNION ALL
SELECT 'receipt',       COUNT(*) FROM receipt;


-- ── D2: NULL checks on critical columns ──────────────────────

-- Students with NULL name, dept_id, roll_no, or admission_date
SELECT student_id, roll_no, name, dept_id, admission_date
FROM student
WHERE name IS NULL
   OR dept_id IS NULL
   OR roll_no IS NULL
   OR admission_date IS NULL;
-- Expected: 0 rows

-- Payments with NULL amount, student_id, or payment_date
SELECT payment_id, student_id, amount, payment_date
FROM payment
WHERE amount IS NULL
   OR student_id IS NULL
   OR payment_date IS NULL;
-- Expected: 0 rows

-- Receipts with NULL receipt_no or payment_id
SELECT receipt_id, payment_id, receipt_no
FROM receipt
WHERE receipt_no IS NULL
   OR payment_id IS NULL;
-- Expected: 0 rows


-- ── D3: FK Integrity checks ───────────────────────────────────

-- Students referencing non-existent departments
SELECT s.student_id, s.name, s.dept_id
FROM student s
LEFT JOIN department d ON s.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- Expected: 0 rows

-- Payments referencing non-existent students
SELECT p.payment_id, p.student_id
FROM payment p
LEFT JOIN student s ON p.student_id = s.student_id
WHERE s.student_id IS NULL;
-- Expected: 0 rows

-- Receipts referencing non-existent payments
SELECT r.receipt_id, r.payment_id
FROM receipt r
LEFT JOIN payment p ON r.payment_id = p.payment_id
WHERE p.payment_id IS NULL;
-- Expected: 0 rows


-- ── D4: Business logic check — duplicate receipts per payment ─

SELECT payment_id, COUNT(*) AS receipt_count
FROM receipt
GROUP BY payment_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows (trigger ensures one receipt per payment)


-- ── D5: Sample report — student dues summary ──────────────────
SELECT roll_no, student_name, dept_name, semester,
       total_fee, total_paid, pending_dues, payment_status
FROM v_student_dues
ORDER BY payment_status DESC, pending_dues DESC
LIMIT 20;


-- ── D6: Department collection overview ───────────────────────
SELECT dept_name, total_students, total_fees_expected,
       total_collected, total_pending
FROM v_department_summary
ORDER BY total_pending DESC;

-- ============================================================
-- END OF DML SCRIPT
-- ============================================================
