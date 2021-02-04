USE FantasyTavern;

CREATE TABLE Locations (
	ID int Identity PRIMARY KEY,
	Name varchar(100) NOT NULL,
);

INSERT INTO Locations 
	(Name) 
VALUES
	('West Side'),
	('Red Light District'),
	('Wonderland'),
	('Camelot'),
	('Sector 9'),
	('R''yleah');





CREATE TABLE Roles (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE,
	Description varchar(100) NOT NULL,
);

INSERT INTO Roles 
	(Name, Description) 
VALUES
	('Owner', 'Ye owns the lot of em'),
	('Wench', 'Serve dem drinks'),
	('Barkeep', ' Make dem drinks'),
	('Bard', 'Sing dem songs'),
	('Guard', 'Bash Dem skulls'),
	('Stable Boy', 'Shovel dem turds');



CREATE TABLE Supplies (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE,
	Unit varchar(20) NOT NULL,
);

INSERT INTO Supplies 
	(Name, Unit) 
VALUES
	('Mead', 'ounces'),
	('Ale', 'ounces'),
	('Rum', 'jugs'),
	('Cheetos', 'bags'),
	('Caltrops', 'sacks'),
	('Gunpowder', 'pounds'),
	('Maple Syrup', 'gallons'),
	('Poison', 'liters'),
	('Darts', 'cases'),
	('Soap?', 'bars'),
	('Rope!', 'feet');




CREATE TABLE Status (
	ID int Identity PRIMARY KEY,
	Status varchar(20) NOT NULL UNIQUE,
	);

INSERT INTO Status 
	(Status) 
VALUES
	('Valid'),
	('Invalid'),
	('Dead'),
	('Cursed'),
	('Restricted');





CREATE TABLE Services (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE,
	StatusID int NOT NULL,CONSTRAINT FK_Status FOREIGN KEY (StatusID)
	REFERENCES Status(ID)
	ON DELETE CASCADE
);

INSERT INTO Services 
	(Name, StatusID) 
VALUES
	('Rent a Room', 1),
	('Spin a Tale', 1),
	('Dunk the Drunk', 2),
	('Drown the Clown', 5),
	('Assasination', 3),
	('Weapon Sharpening', 3),
	('Identify', 4);




CREATE TABLE Users (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL,
	RoleId int NOT NULL,CONSTRAINT FK_Role FOREIGN KEY (RoleID)
	REFERENCES Roles(ID)
	ON DELETE CASCADE
);

INSERT INTO Users 
	(Name, RoleId) 
VALUES
	('Buck Rogers', 1),
	('Moe', 1),
	('Swarthy Daniels', 1),
	('Bjorn Bjorgenson', 5),
	('Daisy Duke', 2),
	('Cthulhu', 3),
	('Deckard Cain', 1),
	('Bob Ross', 4),
	('Shawn Dougherty', 6);






CREATE TABLE Taverns (
	ID int Identity PRIMARY KEY,
	Name varchar(100) NOT NULL,
	Floors int NOT NULL,
	LocationID int NOT NULL,CONSTRAINT FK_Loc FOREIGN KEY (LocationID)
	REFERENCES Locations(ID)
	ON DELETE CASCADE,
	OwnerID int NOT NULL,CONSTRAINT FK_Own FOREIGN KEY (OwnerID)
	REFERENCES Users(ID)
	ON DELETE CASCADE	
);

INSERT INTO Taverns 
	(Name, LocationID, Floors, OwnerId) 
VALUES
	('Buck Roger''s', 1, 2, 1),
	('Moe''s', 3, 1, 2),
	('Pain Train', 4, 6, 3),
	('Lover''s Quarrel', 2, 4, 3),
	('Stay Awhile', 5, 4, 7),
	('The Dive', 2, 3, 3),
	('The Deep', 6, 5, 3);





CREATE TABLE BasementRats (
	ID int Identity PRIMARY KEY,
	Name varchar(100) NOT NULL,
	TavernID int NOT NULL,CONSTRAINT FK_TavernRats FOREIGN KEY (TavernID)
	REFERENCES Taverns(ID)
	ON DELETE CASCADE	
);

INSERT INTO BasementRats 
	(Name, TavernID) 
VALUES
	('Doc', 1),
	('Grumpy', 2),
	('Happy', 3),
	('Sleepy', 4),
	('Dopey', 5),
	('Bashful', 5),
	('Sneezy', 7);






CREATE TABLE Inventory (
	Count int NOT NULL,
	Date datetime NOT NULL,
	TavernID int,CONSTRAINT FK_TavernInv FOREIGN KEY (TavernID)
	REFERENCES Taverns(ID)
	ON DELETE CASCADE,
	SupplyID int,CONSTRAINT FK_SupplyInv FOREIGN KEY (SupplyID)
	REFERENCES Supplies(ID)
	ON DELETE CASCADE,
	PRIMARY KEY (TavernID, SupplyID)	
);

INSERT INTO Inventory 
	(TavernID, SupplyID, Count, Date) 
VALUES
	(1, 1, 23, GETDATE()),
	(1, 5, 69, GETDATE()),
	(1, 4, 17, GETDATE()),
	(2, 2, 13, GETDATE()),
	(2, 7, 5, GETDATE()),
	(3, 11, 123, GETDATE()),
	(3, 9, 236, GETDATE()),
	(3, 5, 6, GETDATE()),
	(4, 7, 31, GETDATE()),
	(5, 3, 44, GETDATE()),
	(6, 8, 67, GETDATE()),
	(7, 2, 88, GETDATE()),
	(7, 9, 92, GETDATE()),
	(7, 10, 2, GETDATE());






CREATE TABLE Receiving (
	ID int Identity PRIMARY KEY,
	Quantity int NOT NULL,
	Cost smallmoney NOT NULL,
	TavernID int NOT NULL, CONSTRAINT FK_TavernRec FOREIGN KEY (TavernID)
	REFERENCES Taverns(ID)
	ON DELETE CASCADE,
	SupplyID int NOT NULL,CONSTRAINT FK_SupplyRec FOREIGN KEY (SupplyID)
	REFERENCES Supplies(ID)
	ON DELETE CASCADE	
);

INSERT INTO Receiving 
	(TavernID, SupplyID, Quantity, Cost) 
VALUES
	(1, 4, 14, $4.38),
	(2, 2, 3, $41.13),
	(3, 7, 75, $6.28),
	(4, 8, 43, $0.18),
	(5, 11, 2, $214.56),
	(6, 5, 77, $4.70),
	(7, 8, 92, $1.38),
	(4, 8, 62, $231.98),
	(2, 2, 4, $6.99),
	(6, 10, 12, $16.08),
	(1, 9, 6453, $21.33),
	(7, 4, 2, $12.76),
	(1, 7, 204, $22.17),
	(2, 3, 12, $33.43);


CREATE TABLE GuestStatus (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE
);

INSERT INTO GuestStatus 
	(Name)
VALUES
	('Hangry'),
	('Enraged'),
	('Drunk'),
	('Enchanted'),
	('Sleepy');

CREATE TABLE Class (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE
);


INSERT INTO Class 
	(Name)
VALUES
	('Barberbidon'),
	('Sorcherawr'),
	('Drunk'),
	('Pyromancer'),
	('Renger');


CREATE TABLE Guests (
	ID int Identity PRIMARY KEY,
	Name varchar(50) NOT NULL UNIQUE,
	Birthday date DEFAULT(GETDATE()) NOT NULL,
	Cakeday date DEFAULT(GETDATE()) NOT NULL,
	StatusID int NOT NULL, CONSTRAINT FK_Guests_Status FOREIGN KEY (StatusID)
	REFERENCES GuestStatus(ID)
	ON DELETE CASCADE,
	
);

INSERT INTO Guests 
	(Name,StatusID) 
VALUES
	('Minsc', 1),
	('Boo', 1),
	('Steve Harvey',3),
	('Judas Priest',2),
	('Bane',1),
	('Radigast',5),
	('Count Dookie',2);



CREATE TABLE GuestClass (
	ClassID int, CONSTRAINT FK_GuestClass_Class FOREIGN KEY (ClassID)
	REFERENCES Class(ID)
	ON DELETE CASCADE,
	GuestID int, CONSTRAINT FK_Guests_Guests FOREIGN KEY (GuestID)
	REFERENCES Guests(ID)
	ON DELETE CASCADE,
	Level int NOT NULL,
	PRIMARY KEY (ClassId, GuestId)
);

INSERT INTO GuestClass
	(ClassID, GuestID, Level) 
VALUES
	(1, 1, 5),
	(1, 3, 55),
	(2, 2, 11),
	(3, 7, 23),
	(4, 6, 34),
	(5, 5, 45),
	(4, 2, 7),
	(5, 2, 21),
	(1, 7, 15);


CREATE TABLE ServicesSales (
	ID int Identity PRIMARY KEY,
	Price smallmoney NOT NULL,
	DatePurchased date NOT NULL,
	QuantityPurchased int NOT NULL,
	TavernID int NOT NULL,CONSTRAINT FK_Tavern_Sales FOREIGN KEY (TavernID)
	REFERENCES Taverns(ID)
	ON DELETE CASCADE,
	ServiceID int NOT NULL,CONSTRAINT FK_Services_Sales FOREIGN KEY (ServiceID)
	REFERENCES Services(ID)
	ON DELETE CASCADE,
	GuestId int NOT NULL,CONSTRAINT FK_ServSales_Guest FOREIGN KEY (GuestId)
	REFERENCES Guests(Id)
	ON DELETE CASCADE
);


INSERT INTO ServicesSales 
	(TavernID, ServiceID, GuestId, Price, QuantityPurchased, DatePurchased) 
VALUES
	(1, 7, 3, $2.34, 2, GETDATE()),
	(7, 7, 2, $1564, 1, GETDATE()),
	(4, 4, 2, $45.98, 4, GETDATE()),
	(5, 2, 1, $2.12, 3, GETDATE()),
	(2, 1, 5, $432.76, 14, GETDATE()),
	(2, 5, 3, $0.01, 114, GETDATE()),
	(2, 6, 2, $64.64, 5, GETDATE()),
	(6, 6, 5, $16, 1, GETDATE()),
	(4, 2, 1, $1.38, 1307, GETDATE()),
	(3, 1, 2, $3.50, 1987, GETDATE()),
	(1, 7, 4, $3.50, 2018, GETDATE());


CREATE TABLE SuppliesSales (
	ID int Identity PRIMARY KEY,
	Price smallmoney NOT NULL,
	DatePurchased date NOT NULL,
	QuantityPurchased int NOT NULL,
	TavernID int NOT NULL,CONSTRAINT FK_SupSales_Tavern FOREIGN KEY (TavernID)
	REFERENCES Taverns(ID)
	ON DELETE CASCADE,
	SupplyID int NOT NULL,CONSTRAINT FK_SupSales_Supplies FOREIGN KEY (SupplyID)
	REFERENCES Supplies(ID)
	ON DELETE CASCADE,
	GuestId int NOT NULL,CONSTRAINT FK_SupSales_Guest FOREIGN KEY (GuestId)
	REFERENCES Guests(Id)
	ON DELETE CASCADE,
);


INSERT INTO SuppliesSales 
	(TavernID, SupplyID, GuestId, Price, QuantityPurchased, DatePurchased) 
VALUES
	(1, 7, 3, $2.34, 2, GETDATE()),
	(7, 7, 2, $1564, 1, GETDATE()),
	(4, 4, 2, $45.98, 4, GETDATE()),
	(5, 2, 1, $2.12, 3, GETDATE()),
	(2, 1, 5, $432.76, 14, GETDATE()),
	(2, 5, 3, $0.01, 114, GETDATE()),
	(2, 6, 2, $64.64, 5, GETDATE()),
	(6, 6, 5, $16, 1, GETDATE()),
	(4, 2, 1, $1.38, 1307, GETDATE()),
	(3, 1, 2, $3.50, 1987, GETDATE()),
	(1, 7, 4, $3.50, 2018, GETDATE());