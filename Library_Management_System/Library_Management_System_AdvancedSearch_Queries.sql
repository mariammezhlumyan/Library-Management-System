/* Database and Distributed Systems (Sec. C)
Library Management System Phase 4 - Advanced Search Queries

We implemented queries to filter our books by their categories, 
borrower profiles and actions related to their accounts */

-------------------------------------------------------------
-- List all books

SELECT *
FROM books

-- Find a book by title

SELECT * 
FROM books 
WHERE title = 'Book Title 13';
   
-- Get books by publisher

SELECT Books.title, Books.genre, Books.number_of_pages, Books.publishing_year, Publishers.publisher_name
FROM Books
JOIN Publishers ON Books.publisher_id = Publishers.publisher_id
WHERE Publishers.publisher_name = 'Publisher 1';

-- Get books with number of pages limitation

SELECT * 
FROM Books 
WHERE number_of_pages = 300;

-- Get audiobooks with duration limitation

SELECT * 
FROM Audiobooks 
WHERE duration_minutes < 360;

-- Get books checked out by the user (borrower email)

SELECT Borrowers.borrower_id, Books.title, Books.genre, Books.publishing_year, Checkouts.start_time, Checkouts.expected_end_time, Checkouts.status
FROM Books
JOIN Checkouts ON Books.id = Checkouts.book_id
JOIN Borrowers ON Checkouts.borrower_id = Borrowers.borrower_id
WHERE Borrowers.email = 'email5@example.com';


-- List all readers with active overdues

SELECT DISTINCT Borrowers.borrower_id, Borrowers.first_name, Borrowers.last_name, Borrowers.email
FROM Borrowers
JOIN Checkouts ON Borrowers.borrower_id = Checkouts.borrower_id
WHERE Checkouts.expected_end_time < CURRENT_TIMESTAMP
AND Checkouts.status != 'returned';

-- Categorize books by genre

SELECT genre, COUNT(*) AS number_of_books
FROM Books
GROUP BY genre
ORDER BY number_of_books DESC;


-- Get users whose library card is about to expire

SELECT Borrowers.borrower_id, Borrowers.first_name, Borrowers.last_name, Borrowers.email, Library_Cards.card_id, Library_Cards.expiry_date
FROM Borrowers
JOIN Library_Cards 
    ON Borrowers.borrower_id = Library_Cards.borrower_id
WHERE Library_Cards.expiry_date 
    BETWEEN CURRENT_DATE 
    AND CURRENT_DATE + INTERVAL '30 days'
    AND Library_Cards.active_status = TRUE;

-- Get books with available audiobooks/ebooks

SELECT Books.id, Books.title, Audiobooks.streaming_link, Audiobooks.duration_minutes
FROM Books
JOIN Audiobooks ON Books.id = Audiobooks.book_id;

SELECT Books.id, Books.title, Ebooks.download_link
FROM Books
JOIN Ebooks ON Books.id = Ebooks.book_id;

-- Get history of books read by user

SELECT Books.title, Books.genre, Checkouts.start_time, Checkouts.expected_end_time, Checkouts.status
FROM Books
JOIN Checkouts ON Books.id = Checkouts.book_id
JOIN Borrowers ON Checkouts.borrower_id = Borrowers.borrower_id
WHERE Borrowers.email = 'email3@example.com';

-- Get all waitlisted books

SELECT Books.title, Books.genre, Books.publishing_year, Borrowers.borrower_id, Borrowers.first_name, Borrowers.last_name, Borrowers.email
FROM Books
JOIN Waitlist ON Books.id = Waitlist.book_id
JOIN Borrowers ON Waitlist.borrower_id = Borrowers.borrower_id;

