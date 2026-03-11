CREATE DATABASE iTunes_DB;
GO

USE iTunes_DB;
GO

CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name NVARCHAR(255)
);

CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title NVARCHAR(255),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name NVARCHAR(120)
);

CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name NVARCHAR(120)
);

CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name NVARCHAR(MAX),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer NVARCHAR(MAX)NULL,
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name NVARCHAR(100),
    first_name NVARCHAR(100),
    title NVARCHAR(100),
    reports_to INT,
    birthdate DATETIME,
    hire_date DATETIME,
    address NVARCHAR(255),
    city NVARCHAR(100),
    state NVARCHAR(100),
    country NVARCHAR(100),
    postal_code NVARCHAR(20),
    phone NVARCHAR(50),
    fax NVARCHAR(50),
    email NVARCHAR(100)
);


CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    company NVARCHAR(255),
    address NVARCHAR(MAX),
    city NVARCHAR(100),
    state NVARCHAR(100),
    country NVARCHAR(100),
    postalcode NVARCHAR(20),
    phone NVARCHAR(50),
    fax NVARCHAR(50),
    email NVARCHAR(100),
    support_rep_id INT,
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
);

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    billing_address NVARCHAR(MAX),
    billing_city NVARCHAR(100),
    billing_state NVARCHAR(100),
    billing_country NVARCHAR(100),
    billing_postal_code NVARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(10,2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

CREATE TABLE playlist (
    play_list_id INT PRIMARY KEY,
    name NVARCHAR(255)
);

CREATE TABLE playlist_track (
    play_list_id INT,
    track_id INT,
    PRIMARY KEY (play_list_id, track_id),
    FOREIGN KEY (play_list_id) REFERENCES playlist(play_list_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

SELECT TOP 10 * FROM artist;

SELECT COUNT(*) FROM track;

SELECT COUNT(*) AS TotalCustomers
FROM customer;

SELECT SUM(Total) AS TotalRevenue
FROM invoice;

SELECT TOP 10
c.first_name,
c.last_name,
SUM(i.Total) AS TotalSpent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY TotalSpent DESC;

SELECT 
g.Name,
COUNT(*) AS Purchases
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.Name
ORDER BY Purchases DESC;

SELECT TOP 10
ar.Name,
SUM(il.unit_price * il.Quantity) AS Revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.Name
ORDER BY Revenue DESC;

SELECT
c.first_name,
c.last_name,
SUM(i.Total) AS Total_Spent,
RANK() OVER (ORDER BY SUM(i.Total) DESC) AS Customer_Rank
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name;

SELECT
t.Name,
COUNT(*) AS Purchase_Count,
RANK() OVER (ORDER BY COUNT(*) DESC) AS Track_Rank
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY t.Name;

WITH ArtistRevenue AS
(
SELECT
ar.Name AS Artist,
SUM(il.unit_price * il.Quantity) AS Revenue
FROM invoice_line il
JOIN track t ON il.track_id= t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.Name
)

SELECT TOP 10 *
FROM ArtistRevenue
ORDER BY Revenue DESC;

WITH CustomerSpending AS
(
SELECT
c.Country,
c.first_name,
c.last_name,
SUM(i.Total) AS Spending,
RANK() OVER (PARTITION BY c.Country ORDER BY SUM(i.Total) DESC) AS Rank
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.Country, c.first_name, c.last_name
)

SELECT *
FROM CustomerSpending
WHERE Rank = 1;