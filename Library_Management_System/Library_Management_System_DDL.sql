/* Database and Distributed Systems (Sec. C)
Library Management System Phase 4 - DDL Script 

We have the following tables 
-- Book_author
-- Book
-- Publisher
-- Staff
-- Checkout
-- Borrower
-- Reminder_notification
-- Waitlist
-- Hold
-- Library_Cards
-- Fines
-- Ebooks
-- Audiobooks
*/

DROP TABLE IF EXISTS Holds CASCADE;
DROP TABLE IF EXISTS Waitlist CASCADE;
DROP TABLE IF EXISTS Audiobooks CASCADE;
DROP TABLE IF EXISTS Ebooks CASCADE;
DROP TABLE IF EXISTS Fines CASCADE;
DROP TABLE IF EXISTS Checkouts CASCADE;
DROP TABLE IF EXISTS Library_Cards CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Books CASCADE;
DROP TABLE IF EXISTS Borrowers CASCADE;
DROP TABLE IF EXISTS Authors CASCADE;
DROP TABLE IF EXISTS Publishers CASCADE;
DROP TYPE IF EXISTS checkout_status;

CREATE TYPE checkout_status AS ENUM ('checked_out', 'returned', 'renewed');

CREATE TABLE Publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL
);

CREATE TABLE Borrowers (
    borrower_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    history TEXT
);

CREATE TABLE Books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    number_of_pages INT,
    publishing_year INT,
    author_id INT,
    publisher_id INT,
    borrower_id INT,
    current_status VARCHAR,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    year_of_hiring INT,
    position VARCHAR(255)
);

CREATE TABLE Library_Cards (
    card_id SERIAL PRIMARY KEY,
    borrower_id INT NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    active_status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

CREATE TABLE Checkouts (
    checkout_id SERIAL PRIMARY KEY,
    start_time TIMESTAMP,
    expected_end_time TIMESTAMP,
  	book_id INT,
    borrower_id INT,
    status checkout_status NOT NULL,
    FOREIGN KEY (book_id) REFERENCES Books(id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

CREATE TABLE Fines (
    fine_id SERIAL PRIMARY KEY,
    borrower_id INT,
  	checkout_id INT,
    amount_dollars DECIMAL(10, 2),
    due_date DATE,
    payment_status BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (checkout_id) REFERENCES Checkouts(checkout_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

CREATE TABLE Ebooks (
    ebook_id SERIAL PRIMARY KEY,
    book_id INT,
    download_link TEXT,
    FOREIGN KEY (book_id) REFERENCES Books(id)
);

CREATE TABLE Audiobooks (
    audiobook_id SERIAL PRIMARY KEY,
    book_id INT,
    streaming_link TEXT,
    duration_minutes INT,
    FOREIGN KEY (book_id) REFERENCES Books(id)
);

CREATE TABLE Waitlist (
    borrower_id INT,
    book_id INT,
    PRIMARY KEY (borrower_id, book_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id),
    FOREIGN KEY (book_id) REFERENCES Books(id)
);

CREATE TABLE Holds (
    id SERIAL PRIMARY KEY,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    borrower_id INT,
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
);

