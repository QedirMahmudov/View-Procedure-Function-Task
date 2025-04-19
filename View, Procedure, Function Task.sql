CREATE DATABASE ViewProcedureFunctionTask

USE ViewProcedureFunctionTask


CREATE TABLE Genders(
Id INT PRIMARY KEY IDENTITY(1,1),
Gender NVARCHAR(25) DEFAULT 'Other' UNIQUE
)

CREATE TABLE Users(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(25) NOT NULL,
Surname NVARCHAR(25) DEFAULT 'XXX',
Userame NVARCHAR(25) UNIQUE NOT NULL,
Password NVARCHAR(50) NOT NULL,
GenderId INT REFERENCES Genders(Id)
)

CREATE TABLE Artist(
Id INT PRIMARY KEY IDENTITY(1,1),
Name NVARCHAR(25) NOT NULL,
Surname NVARCHAR(25) DEFAULT 'XXX',
Birthday DATE DEFAULT 'YYYY-MM-DD',
GenderId INT REFERENCES Genders(Id)
)
EXEC sp_rename 'dbo.Artist', 'Artists'

CREATE TABLE Categories(
Id INT IDENTITY(1,1) PRIMARY KEY,
CategoryName NVARCHAR(25)
)

CREATE TABLE Musics(
Id INT IDENTITY(1,1) PRIMARY KEY,
Name NVARCHAR(25) NOT NULL,
Duration INT NOT NULL,
CategoryId INT REFERENCES Categories(Id),
ArtistId INT REFERENCES Artist(Id)
)


CREATE TABLE Playlist (
MusicId INT REFERENCES Musics(Id),
UserId INT REFERENCES Users(Id)
)



--1
ALTER VIEW GetMusicInfo
AS 
SELECT m.Id, m.Name,m.Duration,c.CategoryName, a.Name AS ArtistName, a.Surname FROM Musics AS m
JOIN Categories AS c
ON m.CategoryId = c.Id
JOIN Artists AS a
ON m.ArtistId = a.Id

SELECT * FROM GetMusicInfo


--2
CREATE FUNCTION dbo.Capitalize(@word NVARCHAR(50))
RETURNS NVARCHAR(50)
AS
BEGIN
SET @word = UPPER(SUBSTRING(@word,1,1)) + LOWER(SUBSTRING(@word,2,LEN(@word)))
RETURN @word
END




CREATE PROCEDURE usp_CreateMusic(@name NVARCHAR(25),@duration INT,@categoryId INT,@artistId INT)
AS
SET @name = (SELECT dbo.Capitalize(@name))
INSERT INTO Musics VALUES(@name,@duration,@categoryId,@artistId)

EXEC usp_CreateMusic 'Qalmisam',144,1,1



CREATE PROCEDURE usp_CreateUser(@name NVARCHAR(25),@surname NVARCHAR(25),@username NVARCHAR(25),@password NVARCHAR(50),@genderId INT)
AS
SET @name =(SELECT dbo.Capitalize(@name))
SET @surname =  (SELECT dbo.Capitalize(@surname))
INSERT INTO Users VALUES(@name,@surname,@username,@password,@genderId)

EXEC usp_CreateUser 'Samos','Mahmudova','samos123','samos1234',2


CREATE PROCEDURE usp_CreateCategory(@categoryName NVARCHAR(25))
AS 
SET @categoryName = (SELECT dbo.Capitalize(@categoryName))
INSERT INTO Categories VALUES(@categoryName)

EXEC usp_CreateCategory 'rep' 


--3
CREATE FUNCTION dbo.GetUserArtistCount(@id INT)
RETURNS INT
AS
BEGIN

	DECLARE @Count INT

	SELECT @Count = COUNT(DISTINCT m.ArtistId)
	FROM Musics AS m
	JOIN PLAYLIST AS p
	ON m.Id = p.MusicId
	WHERE p.UserId = @id
	RETURN @Count;
END

SELECT dbo.GetUserArtistCount(1) AS Count;
--DISTINCT Tekrari olmayan ifacilari sayir.
--4

CREATE PROCEDURE ups_GetMusicById(@id INT)
AS
SELECT m.Id,m.Name,m.Duration FROM Playlist AS p
JOIN Musics AS m
ON p.MusicId  = m.Id 
WHERE p.UserId = @id

exec ups_GetMusicById 1


--5
SELECT * FROM Musics AS m
ORDER BY  m.Duration DESC 


--6
SELECT a.Name, COUNT(*) AS Count FROM Musics AS m
JOIN Artists AS a
ON m.ArtistId = a.Id
GROUP BY a.Name