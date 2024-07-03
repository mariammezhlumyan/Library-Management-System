/* Database and Distributed Systems (Sec. C)
Library Management System Phase 4 - DML Script

We wrote scripts for inserting approximately 200 items across all the tables
To not do all of the inserting manually we wrote algorithms for generating a sequences of examples
All of the tables and relationships work as intended! */


-----------------------
-- Insert Publishers --


INSERT INTO Publishers (publisher_name)
SELECT 'Publisher ' || generate_series
FROM generate_series(1, 10);


--------------------
-- Insert Authors --


INSERT INTO Authors (first_name, last_name)
SELECT 'First' || generate_series, 'Last' || generate_series
FROM generate_series(1, 30);


------------------
-- Insert Books --


INSERT INTO Books (title, genre, number_of_pages, publishing_year, author_id, publisher_id, borrower_id, current_status)
SELECT
    'Book Title ' || generate_series,
    CASE floor(random() * 6)           
        WHEN 0 THEN 'Fiction'
        WHEN 1 THEN 'Non-Fiction'
        WHEN 2 THEN 'Detective'
        WHEN 3 THEN 'Science'
        WHEN 4 THEN 'History'
        WHEN 5 THEN 'Biography'
    END,
    floor(random() * 300 + 100),
    floor(random() * (2023 - 1900) + 1900),
    floor(random() * 30 + 1)::int,
    floor(random() * 10 + 1)::int, 
    floor(random() * 50 + 1)::int,    
    CASE floor(random() * 4)          
        WHEN 0 THEN 'Available'
        WHEN 1 THEN 'Checked Out'
        WHEN 2 THEN 'Reserved'
        WHEN 3 THEN 'Maintenance'
    END
FROM generate_series(1, 100)
ON CONFLICT (id) DO NOTHING;


----------------------
-- Insert Borrowers --

SELECT * FROM Borrowers;
INSERT INTO Borrowers (first_name, last_name, email, phone_number, history)
SELECT 
    'Name' || generate_series, 
    'Surname' || generate_series, 
    'email' || generate_series || '@example.com', 
    '093' || lpad(floor(random()*1000000)::text, 6, '0') AS phone_number,
    'Borrowed Book ' || generate_series || ': ' || 'History description for borrower ' || generate_series AS history
FROM generate_series(1, 50);


--------------------------
-- Insert Library Cards --


INSERT INTO Library_Cards (borrower_id, issue_date, expiry_date, active_status)
SELECT 
    floor(random() * 50 + 1)::int AS borrower_id,
    CURRENT_DATE - (generate_series * 2 || ' days')::interval AS issue_date,
    CURRENT_DATE - (generate_series * 2 || ' days')::interval + interval '1 year' AS expiry_date,
    (CURRENT_DATE - (generate_series * 2 || ' days')::interval + interval '1 year' > CURRENT_DATE)
FROM 
    generate_series(1, 50);


----------------------
-- Insert Checkouts --


INSERT INTO Checkouts (start_time, expected_end_time, book_id, borrower_id, status)
SELECT 
    CURRENT_TIMESTAMP - interval '1 day' AS start_time,
    CURRENT_TIMESTAMP + interval '15 days' AS expected_end_time,
    id,
    borrower_id,
    'checked_out'
FROM 
    Books
WHERE 
    borrower_id IS NOT NULL;


-----------------------
-- Insert Audiobooks --


INSERT INTO Audiobooks (book_id, streaming_link, duration_minutes)
SELECT 
    id,
    'http://streaming.example.com/audiobook/' || id AS streaming_link,
    floor(random() * 600 + 100)::int AS duration
FROM 
    Books
LIMIT 50;


-------------------
-- Insert Ebooks --


INSERT INTO Ebooks (book_id, download_link)
SELECT id, 'http://downloads.example.com/ebook/' || id
FROM Books
LIMIT 50;


------------------
-- Insert Fines --

-- Check for overdue checkouts
SELECT checkout_id, borrower_id, expected_end_time
FROM Checkouts
WHERE expected_end_time < CURRENT_DATE;

-- Set 5 of Checkouts are overdue
UPDATE Checkouts
SET expected_end_time = CURRENT_DATE - interval '10 days'
WHERE checkout_id IN (SELECT checkout_id FROM Checkouts ORDER BY checkout_id LIMIT 5);

-- Putting fines for confirmed overdue books
INSERT INTO Fines (borrower_id, checkout_id, amount_dollars, due_date, payment_status)
SELECT 
    c.borrower_id,
    c.checkout_id,
    5.00 AS amount_dollars,
    c.expected_end_time + interval '30 days' AS due_date,
    FALSE
FROM 
    Checkouts c
WHERE 
    c.expected_end_time < CURRENT_DATE;
	

------------------
-- Insert Staff --


INSERT INTO Staff (fullname, year_of_hiring, position)
VALUES
('John Doe', 2018, 'Librarian'),
('Jane Smith', 2019, 'Assistant Librarian'),
('Jim Beam', 2020, 'Archivist');


---------------------
-- Insert Waitlist --


INSERT INTO Waitlist (borrower_id, book_id)
SELECT b.borrower_id, bk.id
FROM Borrowers b
CROSS JOIN Books bk
ORDER BY random()
LIMIT 10;








