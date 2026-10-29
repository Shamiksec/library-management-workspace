-- LIBRARY MANAGEMENT SYSTEM | DBMS PROJECT | GROUP G2
-- Requirements: MySQL 8.0+
-- Run this entire script in MySQL Workbench.
-- Sample data is fictional; fine policy is illustrative only.

DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE library_management_system;

CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  author_name VARCHAR(120) NOT NULL,
  nationality VARCHAR(60),
  birth_date DATE
);

CREATE TABLE publishers (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher_name VARCHAR(150) NOT NULL UNIQUE,
  city VARCHAR(80),
  phone VARCHAR(20)
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  isbn VARCHAR(20) UNIQUE,
  title VARCHAR(200) NOT NULL,
  publisher_id INT,
  category_id INT,
  publication_year YEAR,
  edition VARCHAR(40),
  language_name VARCHAR(40) NOT NULL DEFAULT 'English',
  CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id)
    REFERENCES publishers(publisher_id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_books_category FOREIGN KEY (category_id)
    REFERENCES categories(category_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE book_authors (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
    REFERENCES authors(author_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  address VARCHAR(255),
  joined_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  member_status ENUM('ACTIVE','SUSPENDED','CLOSED') NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE book_copies (
  copy_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  accession_no VARCHAR(40) NOT NULL UNIQUE,
  shelf_location VARCHAR(60),
  copy_status ENUM('AVAILABLE','ISSUED','LOST','DAMAGED','WITHDRAWN')
    NOT NULL DEFAULT 'AVAILABLE',
  CONSTRAINT fk_copies_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  copy_id INT NOT NULL,
  member_id INT NOT NULL,
  issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  due_date DATE NOT NULL,
  return_date DATE NULL,
  loan_status ENUM('ISSUED','RETURNED','OVERDUE','LOST') NOT NULL DEFAULT 'ISSUED',
  issued_by VARCHAR(100),
  returned_by VARCHAR(100),
  active_copy_id INT GENERATED ALWAYS AS
    (CASE WHEN return_date IS NULL THEN copy_id ELSE NULL END) STORED,
  CONSTRAINT fk_loans_copy FOREIGN KEY (copy_id)
    REFERENCES book_copies(copy_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_loans_member FOREIGN KEY (member_id)
    REFERENCES members(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_due_date CHECK (due_date >= issue_date),
  UNIQUE KEY uq_one_active_loan_per_copy (active_copy_id),
  INDEX idx_loans_member_status (member_id, loan_status),
  INDEX idx_loans_due_date (due_date)
);

CREATE TABLE reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  member_id INT NOT NULL,
  reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reservation_status ENUM('WAITING','FULFILLED','CANCELLED') NOT NULL DEFAULT 'WAITING',
  notes VARCHAR(255),
  CONSTRAINT fk_res_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_res_member FOREIGN KEY (member_id)
    REFERENCES members(member_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_reservation_queue (book_id, reservation_status, reservation_date)
);

CREATE TABLE fines (
  fine_id INT AUTO_INCREMENT PRIMARY KEY,
  loan_id INT NOT NULL UNIQUE,
  amount DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  reason VARCHAR(200) NOT NULL,
  assessed_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  payment_status ENUM('UNPAID','PAID','WAIVED') NOT NULL DEFAULT 'UNPAID',
  paid_on DATE NULL,
  CONSTRAINT fk_fines_loan FOREIGN KEY (loan_id)
    REFERENCES loans(loan_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_fine_amount CHECK (amount >= 0)
);

-- SAMPLE DATA
INSERT INTO authors (author_name, nationality, birth_date) VALUES
('George Orwell','British','1903-06-25'),
('J. K. Rowling','British','1965-07-31'),
('R. K. Narayan','Indian','1906-10-10'),
('A. P. J. Abdul Kalam','Indian','1931-10-15'),
('Robert C. Martin','American','1952-12-05'),
('Silberschatz, Korth and Sudarshan','American',NULL);

INSERT INTO publishers (publisher_name, city, phone) VALUES
('Penguin Books','London',NULL),('Bloomsbury','London',NULL),
('Indian Thought Publications','Chennai',NULL),('Universities Press','Hyderabad',NULL),
('Pearson','London',NULL),('McGraw Hill','New York',NULL);

INSERT INTO categories (category_name) VALUES
('Fiction'),('Fantasy'),('Indian Literature'),('Biography'),('Programming'),('Database Systems');

INSERT INTO books (isbn,title,publisher_id,category_id,publication_year,edition,language_name) VALUES
('9780451524935','1984',1,1,1949,'Reprint','English'),
('9780747532699','Harry Potter and the Philosopher''s Stone',2,2,1997,'First','English'),
('9788185986173','Malgudi Days',3,3,1943,'Reprint','English'),
('9788173711466','Wings of Fire',4,4,1999,'Reprint','English'),
('9780132350884','Clean Code',5,5,2008,'First','English'),
('9780073523323','Database System Concepts',6,6,2019,'7th','English');

INSERT INTO book_authors (book_id,author_id) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,6);

INSERT INTO members (full_name,email,phone,address,joined_on,member_status) VALUES
('Aarav Sen','aarav.sen@example.com','9000000001','Kolkata, West Bengal','2026-01-10','ACTIVE'),
('Mira Das','mira.das@example.com','9000000002','Barasat, West Bengal','2026-02-05','ACTIVE'),
('Rahul Roy','rahul.roy@example.com','9000000003','Habra, West Bengal','2026-03-12','ACTIVE'),
('Priya Ghosh','priya.ghosh@example.com','9000000004','Kolkata, West Bengal','2026-04-18','SUSPENDED');

INSERT INTO book_copies (book_id,accession_no,shelf_location,copy_status) VALUES
(1,'ACC-1984-001','A1-01','AVAILABLE'),
(1,'ACC-1984-002','A1-01','ISSUED'),
(2,'ACC-HP-001','B2-03','AVAILABLE'),
(3,'ACC-MD-001','C1-02','AVAILABLE'),
(4,'ACC-WOF-001','D1-04','AVAILABLE'),
(5,'ACC-CC-001','E3-01','ISSUED'),
(6,'ACC-DB-001','E3-02','AVAILABLE');

INSERT INTO loans (copy_id,member_id,issue_date,due_date,return_date,loan_status,issued_by,returned_by) VALUES
(2,1,'2026-10-01','2026-10-15',NULL,'ISSUED','Librarian A',NULL),
(6,2,'2026-09-01','2026-09-15','2026-09-20','RETURNED','Librarian A','Librarian B');

INSERT INTO reservations (book_id,member_id,reservation_status,notes) VALUES
(1,3,'WAITING','Notify member when a copy is available');

INSERT INTO fines (loan_id,amount,reason,assessed_on,payment_status) VALUES
(2,25.00,'Late return: 5 days at Rs. 5 per day','2026-09-20','UNPAID');

-- ============================================================
-- REPORT QUERIES: execute one at a time.
-- ============================================================

-- Q1. Complete book catalogue
SELECT b.book_id, b.title, b.isbn, c.category_name, p.publisher_name
FROM books b
LEFT JOIN categories c ON c.category_id = b.category_id
LEFT JOIN publishers p ON p.publisher_id = b.publisher_id
ORDER BY b.title;

-- Q2. Available physical copies by title
SELECT b.title,
       SUM(CASE WHEN bc.copy_status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_copies,
       COUNT(bc.copy_id) AS total_copies
FROM books b
LEFT JOIN book_copies bc ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY b.title;

-- Q3. Active loans with member and title
SELECT l.loan_id, m.full_name, b.title, bc.accession_no, l.issue_date, l.due_date
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id = l.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE l.return_date IS NULL;

-- Q4. Overdue loans as of today
SELECT l.loan_id, m.full_name, b.title, l.due_date,
       DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id = l.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;

-- Q5. Unpaid fines
SELECT f.fine_id, m.full_name, b.title, f.amount, f.reason
FROM fines f
JOIN loans l ON l.loan_id = f.loan_id
JOIN members m ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id = l.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE f.payment_status = 'UNPAID';

-- Q6. Title count by category
SELECT c.category_name, COUNT(b.book_id) AS total_titles
FROM categories c
LEFT JOIN books b ON b.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_titles DESC;

-- Q7. Members who have never borrowed a book
SELECT m.member_id, m.full_name
FROM members m
LEFT JOIN loans l ON l.member_id = m.member_id
WHERE l.loan_id IS NULL;

-- Q8. Search title by keyword
SELECT book_id, title, isbn
FROM books
WHERE title LIKE '%database%';

-- Q9. Reservation waiting queue for a selected book (book_id = 1)
SELECT r.reservation_id, m.full_name, r.reservation_date, r.reservation_status
FROM reservations r
JOIN members m ON m.member_id = r.member_id
WHERE r.book_id = 1 AND r.reservation_status = 'WAITING'
ORDER BY r.reservation_date;

-- Q10. Mark fine ID 1 as paid (run only when payment is actually received)
-- UPDATE fines SET payment_status='PAID', paid_on=CURRENT_DATE WHERE fine_id=1;

-- Q11. Example issue transaction. Change IDs and verify copy/member status first.
-- START TRANSACTION;
-- SELECT copy_status FROM book_copies WHERE copy_id=1 FOR UPDATE;
-- INSERT INTO loans (copy_id,member_id,issue_date,due_date,loan_status,issued_by)
-- VALUES (1,3,CURRENT_DATE,DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY),'ISSUED','Librarian');
-- UPDATE book_copies SET copy_status='ISSUED'
-- WHERE copy_id=1 AND copy_status='AVAILABLE';
-- COMMIT;

-- Q12. Example return update. Replace loan/copy IDs as appropriate.
-- START TRANSACTION;
-- UPDATE loans SET return_date=CURRENT_DATE, loan_status='RETURNED',
--   returned_by='Librarian' WHERE loan_id=1 AND return_date IS NULL;
-- UPDATE book_copies SET copy_status='AVAILABLE' WHERE copy_id=2;
-- COMMIT;
