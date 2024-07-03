/* Database and Distributed Systems (Sec. C)
Library Management System Phase 4 - Trigger Functions 

We have integrated the following trigger functions to handle specific actions within the library management system.

-- 1. Automatically update book status when a checkout occurs.
-- 2. Automatically update book status when a book is returned.
-- 3. Send a reminder when a book's return date is approaching.
-- 4. Extend the due date for checkouts when a renewal occurs.
-- 5. Prevent borrowers with overdue books from checking out new books until their overdue books are returned.
-- 6. Automatically generate a welcome message via email to new borrowers when they are registered.
-- 7. Automatically calculate and apply a fine when a book is returned past its due date. */

-----------------------------------------
-- Update Book Status to 'Checked Out' --


CREATE OR REPLACE FUNCTION update_book_status_out()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Books
    SET current_status = 'checked out'
    WHERE id = NEW.book_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_book_status_out
AFTER INSERT ON Checkouts
FOR EACH ROW
EXECUTE FUNCTION update_book_status_out();


-------------------------------------------------
-- Update Book Status to 'Available' on Return --


CREATE OR REPLACE FUNCTION update_book_status_in()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'returned' THEN
        UPDATE Books
        SET current_status = 'available'
        WHERE id = NEW.book_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_book_status_in
AFTER UPDATE ON Checkouts
FOR EACH ROW
EXECUTE FUNCTION update_book_status_in();


--------------------------------------------------
-- Sending a Reminder Notification when its due --
/*

CREATE OR REPLACE FUNCTION send_reminder_notification()
RETURNS TRIGGER AS $$
DECLARE
    recipient_email TEXT;
    email_subject TEXT;
    email_body TEXT;
BEGIN
    SELECT email INTO recipient_email FROM Borrowers WHERE borrower_id = NEW.borrower_id;

    IF (NEW.expected_end_time - CURRENT_DATE) = 1 THEN
        email_subject := 'Reminder: Book Due Tomorrow';
        email_body := format('Dear borrower,\n\nThis is a reminder that the book (ID: %) is due tomorrow. Please return it by the due date.\n\nSincerely,\nLibrary Staff', NEW.book_id);

        EXECUTE format('SELECT pg_sendmail(%L, %L, %L)', recipient_email, email_subject, email_body);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_send_reminder
BEFORE UPDATE ON Checkouts
FOR EACH ROW
EXECUTE FUNCTION send_reminder_notification();
*/

-----------------------------------
-- Update Due Dates for Renewals --


CREATE OR REPLACE FUNCTION update_due_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'renewed' THEN
        NEW.expected_end_time := NEW.expected_end_time + INTERVAL '14 days'; -- Assuming a 14-day renewal period
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_due_date
BEFORE UPDATE ON Checkouts
FOR EACH ROW
WHEN (OLD.status <> NEW.status AND NEW.status = 'renewed')
EXECUTE FUNCTION update_due_date();


------------------------------------------------------------------
-- Check and Block Overdue Borrowers from Borrowing More Bookss --


CREATE OR REPLACE FUNCTION check_overdue_borrowers()
RETURNS TRIGGER AS $$
DECLARE
    overdue_count INT;
BEGIN
    SELECT COUNT(*) INTO overdue_count
    FROM Checkouts
    WHERE reader_id = NEW.borrower_id AND status = 'checked out' AND expected_end_time < CURRENT_DATE;

    IF overdue_count > 0 THEN
        RAISE EXCEPTION 'This borrower has overdue books and cannot borrow more until they are returned.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_overdue_borrowers
BEFORE INSERT ON Checkouts
FOR EACH ROW
EXECUTE FUNCTION check_overdue_borrowers();


-------------------------------------------------------------------
-- Automatically Create a Welcome Notification for New Borrowers --
/*

CREATE OR REPLACE FUNCTION send_welcome_notification()
RETURNS TRIGGER AS $$
DECLARE
    recipient_email TEXT;
    email_subject TEXT;
    email_body TEXT;
BEGIN
    SELECT email INTO recipient_email FROM Borrowers WHERE borrower_id = NEW.borrower_id;

    email_subject := 'Welcome to Our Library!';
    email_body := 'Dear borrower, Welcome to our library!';

    EXECUTE format('SELECT pg_sendmail(%L, %L, %L)', recipient_email, email_subject, email_body);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_welcome_new_borrower
AFTER INSERT ON Borrowers
FOR EACH ROW
EXECUTE FUNCTION send_welcome_notification();
*/

-------------------------------------------
-- Calculate and Apply Late Return Fines --

DROP TYPE IF EXISTS checkout_status CASCADE;
CREATE TYPE checkout_status AS ENUM ('checked out', 'returned', 'renewed');

CREATE OR REPLACE FUNCTION apply_late_return_fines()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'checked out' AND NEW.status = 'returned' THEN
        IF NEW.return_date > NEW.expected_end_time THEN
            INSERT INTO Fines(borrow_id, member_id, amount, due_date, payment_status)
            VALUES (NEW.id, NEW.borrower_id, (NEW.return_date - NEW.expected_end_time) * 2, NEW.return_date + INTERVAL '30 days', FALSE);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_apply_late_return_fines
AFTER UPDATE ON Checkouts
FOR EACH ROW
EXECUTE FUNCTION apply_late_return_fines();


