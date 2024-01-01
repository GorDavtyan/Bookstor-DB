create database BookstoreDB;

use BookstoreDB;

CREATE TABLE Books
(
    BookID          INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Title           VARCHAR(255),
    Author          VARCHAR(255),
    Genre           VARCHAR(50),
    Price           DECIMAL(10, 2)  NOT NULL,
    QuantityInStock INT
);

-- Insert some sample data into the Books table
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book1', 'Author1', 'Genre1', 100.5, 50);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book2', 'Author2', 'Genre2', 150.5, 45);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book3', 'Author3', 'Genre3', 200.5, 40);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book4', 'Author4', 'Genre4', 250.5, 35);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book5', 'Author5', 'Genre5', 300.5, 60);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book6', 'Author6', 'Genre6', 350.5, 40);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book7', 'Author7', 'Genre7', 400.5, 40);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book8', 'Author8', 'Genre8', 450.5, 40);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book9', 'Author9', 'Genre9', 500.5, 40);
INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock) VALUES ('Book10', 'Author10', 'Genre10', 550.5, 40);


-- Create a table named Customers to store information about customers
CREATE TABLE Customers (
                           CustomerID INT PRIMARY KEY KEY NOT NULL AUTO_INCREMENT,
                           Name VARCHAR(100) NOT NULL,
                           Email VARCHAR(255) NOT NULL,
                           Phone VARCHAR(15)
);


-- Insert some sample data into the Customers table
INSERT INTO Customers(Name, Email, Phone) VALUES ('Customers1', 'email1@gmail.com', '+37494111111');
INSERT INTO Customers(Name, Email, Phone) VALUES ('Customers2', 'email2@gmail.com', '+37494222222');
INSERT INTO Customers(Name, Email, Phone) VALUES ('Customers3', 'email3@gmail.com', '+37494333333');
INSERT INTO Customers(Name, Email, Phone) VALUES ('Customers4', 'email4@gmail.com', '+37494444444');
INSERT INTO Customers(Name, Email, Phone) VALUES ('Customers5', 'email5@gmail.com', '+37494555555');


-- Create a table named Sales to track book sales
CREATE TABLE Sales (
                       SaleID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
                       BookID INT,
                       CustomerID INT,
                       DateOfSale DATE,
                       QuantitySold INT,
                       TotalPrice DECIMAL(10, 2),
                       FOREIGN KEY (BookID) REFERENCES Books(BookID),
                       FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


# Change the delimiter to handle the trigger syntax
-- Change the delimiter to handle the trigger syntax
DELIMITER //

-- Create a trigger named UpdateQuantityInStock to handle book sales
CREATE TRIGGER UpdateQuantityInStock
    BEFORE INSERT ON Sales
    FOR EACH ROW
BEGIN
    -- Declare variables to store the book's current quantity in stock
    DECLARE currentQuantity INT;

    -- Retrieve the current quantity in stock for the book being sold
    SELECT QuantityInStock INTO currentQuantity
    FROM Books
    WHERE BookID = NEW.BookID;

    IF NEW.QuantitySold <= currentQuantity THEN
        -- Calculate the total price for the sale
        SET NEW.TotalPrice = NEW.QuantitySold * (SELECT Price FROM Books WHERE BookID = NEW.BookID);

        -- Update the QuantityInStock in the Books table
    UPDATE Books SET QuantityInStock = currentQuantity - NEW.QuantitySold WHERE BookID = NEW.BookID;

    ELSE
        -- Raise an error if the quantity sold exceeds the available quantity
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity in stock is insufficient for the sale';
END IF;
END;
//

-- Reset the delimiter back to semicolon
DELIMITER ;

-- Insert some sample data into the Sales table
INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold) VALUES (1, 1, '2023-01-01', 2);
INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold) VALUES (5, 2, '2023-02-02', 3);
INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold) VALUES (2, 3, '2023-03-03', 1);
INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold) VALUES (4, 5, '2023-04-04', 4);
INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold) VALUES (3, 4, '2023-05-05', 5);

-- Query to retrieve information about book sales, including book title, customer name, and date of sale
SELECT Books.Title, Customers.Name AS CustomerName, Sales.DateOfSale
FROM Sales
         JOIN Books ON Sales.BookID = Books.BookID
         JOIN Customers ON Sales.CustomerID = Customers.CustomerID;

-- Query to calculate total revenue per book genre using book prices (not total prices from sales)
SELECT Books.Genre, SUM(IFNULL(Sales.TotalPrice, 0)) AS TotalRevenue
FROM Sales
         JOIN Books ON Sales.BookID = Books.BookID
GROUP BY Books.Genre;


