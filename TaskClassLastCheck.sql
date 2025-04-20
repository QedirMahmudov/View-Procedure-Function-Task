CREATE DATABASE Depot

USE DEPot



CREATE TABLE Depots(
Id INT PRIMARY KEY IDENTITY(1,1), 
Name NVARCHAR(50) NOT NULL,
City NVARCHAR(50) DEFAULT 'XXX',
ZipCode DECIMAL(5,0) UNIQUE
)

CREATE TABLE Medicines(
Id INT PRIMARY KEY IDENTITY(1,1), 
Name NVARCHAR(50) NOT NULL,
Manufacturer NVARCHAR(50) NOT NULL,
Price DECIMAL(6,2)
)

CREATE TABLE Pharmacies(
Id INT PRIMARY KEY IDENTITY(1,1), 
Name NVARCHAR(50) NOT NULL,
City NVARCHAR(50) DEFAULT 'XXX',
ZipCode DECIMAL(5,0) UNIQUE
)

CREATE TABLE DepotMedicines(
DepotId INT REFERENCES Depots(Id),
MedicineId INT REFERENCES Medicines(Id),
Quantity INT 
)

CREATE TABLE PharmaciesMedicines(
PharmaciesId INT REFERENCES Pharmacies(Id),
MedicineId INT REFERENCES Medicines(Id),
Quantity INT 
)





DROP TABLE Depot
DROP TABLE Medicines
DROP TABLE Pharmacies


SELECT m.Name,m.Price,m.Manufacturer,p.Name,d.Name FROM Medicines AS m
JOIN Pharmacies AS p
ON p.Id = m.Id
JOIN Depots AS d
ON d.Id = m.Id




--1
CREATE VIEW GetInfo
AS 
SELECT m.Name,m.Price,m.Manufacturer,p.Name AS PharmacieName,d.Name AS DepoName,pm.Quantity FROM Medicines AS m
JOIN PharmaciesMedicines AS pm
ON m.Id = pm.MedicineId
JOIN Pharmacies AS p
ON p.Id = pm.PharmaciesId
JOIN DepotMedicines AS dm
ON dm.MedicineId = m.Id 
JOIN Depots AS d
ON d.Id = dm.DepotId



SELECT * FROM GetInfo
DROP VIEW GetInfo






--2
SELECT * FROM GetInfo 
WHERE Quantity<10



--3
CREATE PROCEDURE usp_AddMedicineCount @medicineId INT
AS 
BEGIN
UPDATE PharmaciesMedicines
SET Quantity = Quantity + 100
WHERE @medicineId = MedicineId AND Quantity<10
END


exec usp_AddMedicineCount 3
SELECT * FROM GetInfo 



--4
CREATE PROCEDURE usp_MedicineToPharmecies(@MedicineId INT,@PharmcyId INT)
AS
INSERT INTO PharmaciesMedicines (MedicineId, PharmaciesId)
    VALUES (@MedicineId, @PharmcyId)

exec usp_MedicineToPharmecies 1,1


--5
CREATE FUNCTION dbo.PharmaciesAvg(@phaId INT)
RETURNS FLOAT
AS 
BEGIN
RETURN (SELECT AVG(ZipCode + Quantity) /2.0
FROM Pharmacies AS p
JOIN PharmaciesMedicines AS pm
ON p.Id = pm.PharmaciesId
WHERE p.Id = @phaId)
END


SELECT  dbo.PharmaciesAvg (1)