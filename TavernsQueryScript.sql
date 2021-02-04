/*
1. Write a query to return a “report” of all users and their roles
*/
SELECT users.name AS users, roles.name AS role, roles.description AS roleDescription FROM [users]
JOIN [roles] ON users.RoleId = Roles.ID

/*
2. Write a query to return all classes and the count of guests that hold those classes
*/
SELECT class.name AS class, nog.numberOfGuests FROM [Class]
JOIN (SELECT classID, COUNT(guestId) AS numberOfGuests FROM [GuestClass]
GROUP BY classID) AS nog ON nog.classID = Class.ID 

/*
3. Write a query that returns all guests ordered by name (ascending) and their classes and corresponding levels.
 Add a column that labels them beginner (lvl 1-5), intermediate (5-10) and expert (10+) for their classes 
 (Don’t alter the table for this)
*/
SELECT guests.name AS guest, class.name AS Class, level,
CASE
		WHEN level >0  AND level <= 5 THEN 'Beginner'
		WHEN level >5 AND level <= 10 THEN 'Intermediate'
		WHEN level >10 THEN 'Expert'
	END as 'Level Group'
FROM [GuestClass]
JOIN [Class] ON GuestClass.ClassID = Class.ID
JOIN [Guests] ON GuestClass.GuestID = Guests.ID
ORDER BY guest ASC

/*
4. Write a function that takes a level and returns a “grouping” from question 3 (e.g. 1-5, 5-10, 10+, etc)
*/
IF OBJECT_ID (N'guestLevelGroup', N'IF') IS NOT NULL
	DROP FUNCTION guestLevelGroup;
GO
CREATE FUNCTION guestLevelGroup(@level INT)
RETURNS @guestTable TABLE(
	guest VARCHAR(250),
	class VARCHAR(250),
	level INT,
	LG VARCHAR(250) 
)
AS
BEGIN
	INSERT INTO @guestTable (guest, class, level, LG)
	SELECT * FROM (SELECT guests.name AS guest, class.name AS Class, level,
	CASE
		WHEN level <= 5 THEN 'Beginner'
		WHEN level >5 AND level <= 10 THEN 'Intermediate'
		WHEN level >10 THEN 'Expert'
	END AS LG
	FROM [GuestClass]
	JOIN [Class] ON GuestClass.ClassID = Class.ID
	JOIN [Guests] ON GuestClass.GuestID = Guests.ID) AS gt
	WHERE gt.LG = (CASE WHEN @level <= 5 THEN 'Beginner'
						WHEN @level > 10 THEN 'Expert'
						ELSE 'Intermediate'  
				  END)
	RETURN;
END
GO
SELECT * FROM guestLevelGroup(7)
ORDER BY guest ASC
GO
SELECT * FROM guestLevelGroup(15)
ORDER BY guest ASC
GO
SELECT * FROM guestLevelGroup(2)
ORDER BY guest ASC
GO
/*
5. Write a function that returns a report of all open rooms (not used) on a particular day (input) and 
which tavern they belong to 
*/
--new rooms table for this assignment (assuming all these types with 1Qty are in every tavern)
DROP TABLE IF EXISTS [roomType];

CREATE TABLE [roomType] (
ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
roomName VARCHAR(250) NOT NULL,
rate MONEY NOT NULL
);

INSERT INTO [roomType] (roomName, rate)
VALUES ('SingleBed', $70), ('DoubleBed', $90), ('SuiteA', $150), ('SuiteB', $170), ('Villa', $300);

--new roomStays table for this assignment
DROP TABLE IF EXISTS [roomStays];

CREATE TABLE [roomStays] (
--ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
tavernId INT NOT NULL FOREIGN KEY REFERENCES taverns(ID), 
roomTypeId INT NOT NULL FOREIGN KEY REFERENCES roomType(ID),
checkInDate DATE NOT NULL,
checkOutDate DATE NOT NULL,
PRIMARY KEY (tavernId, roomTypeId)
);

INSERT INTO [roomStays] (tavernId, roomTypeId, checkInDate, checkOutDate)
VALUES (1, 5, '01/03/2021','01/07/2021'),
(1, 3, '01/04/2021','01/08/2021'),
(2, 2, '01/05/2021','01/09/2021'),
(2, 1, '01/06/2021','01/10/2021'),
(3, 4, '01/07/2021','01/09/2021'),
(3, 5, '01/04/2021','01/05/2021'),
(3, 3, '01/05/2021','01/06/2021'),
(4, 1, '01/06/2021','01/07/2021'),
(4, 2, '01/07/2021','01/10/2021'),
(4, 3, '01/01/2021','01/11/2021'),
(5, 5, '01/04/2021','01/06/2021'),
(6, 5, '01/03/2021','01/05/2021'),
(7, 5, '01/03/2021','01/07/2021');

--Function to return all open (available) rooms on a particular day
--Cross Join all roomTypes and Taverns so all roomTypes are in every tavern
IF OBJECT_ID (N'OpenRooms', N'IF') IS NOT NULL
	DROP FUNCTION openRooms;
GO
CREATE FUNCTION openRooms(@day DATE)
RETURNS TABLE
AS
RETURN
(
	SELECT tavernName, roomName, rate  FROM (SELECT taverns.ID AS tavernId, taverns.Name AS tavernName, roomType.ID AS roomTypeId, roomType.roomName AS roomName, 
	(roomType.rate * taverns.ID) AS rate
	FROM [Taverns] CROSS JOIN [roomType]) AS [rooms]
	LEFT JOIN [roomStays] ON rooms.tavernId = roomStays.tavernId AND rooms.roomTypeId = roomStays.roomTypeId	
	WHERE (@day NOT BETWEEN roomStays.checkInDate AND roomStays.checkOutDate) OR (checkOutDate IS NULL)
);
GO
SELECT * FROM openRooms('01/07/2021')
ORDER BY tavernName ASC
GO
SELECT * FROM openRooms('01/01/2021')
ORDER BY tavernName ASC
GO
SELECT * FROM openRooms('01/30/2021')
ORDER BY tavernName ASC
GO

/*
6. Modify the same function from 5 to instead return a report of prices in a range (min and max prices) - 
Return Rooms and their taverns based on price inputs
*/
/*********** CALLING FUNCTION IN 5 ***************/
IF OBJECT_ID (N'OpenRoomsByPrice', N'IF') IS NOT NULL
	DROP FUNCTION openRoomsByPrice;
GO
CREATE FUNCTION openRoomsByPrice(@day DATE, @minPrice MONEY, @maxPrice MONEY)
RETURNS TABLE
AS
RETURN
(
	SELECT * FROM openRooms(@day)
	WHERE rate BETWEEN @minPrice AND @maxPrice
);
GO
SELECT * FROM openRoomsByPrice('01/07/2021', $70, $700)
ORDER BY rate ASC
GO
SELECT * FROM openRoomsByPrice('01/01/2021', $200, $1500)
ORDER BY rate ASC
GO
SELECT * FROM openRoomsByPrice('01/30/2021', $500, $2000)
ORDER BY rate ASC
GO

/*
7. Write a command that uses the result from 6 to Create a Room in another tavern that undercuts (is less than) 
the cheapest room by a penny - thereby making the new room the cheapest one
*/

DROP TABLE IF EXISTS [newRooms];
SELECT * INTO [newRooms] FROM (SELECT * FROM openRoomsByPrice('01/07/2021', $170, $900)) AS temp
GO
DECLARE @minRate MONEY, @minTavernName VARCHAR(250), @randomTavernName VARCHAR(250), @roomName VARCHAR(250)
SELECT TOP 1 @minRate = rate, @minTavernName = tavernName, @roomName = roomName from [newRooms] order by rate asc
SELECT TOP 1 @randomTavernName = tavernName FROM [newRooms] WHERE tavernName <> @minTavernName ORDER BY NEWID()
INSERT INTO [newRooms] (tavernName, roomName, rate)
VALUES (@randomTavernName, @roomName, @minrate-$0.01);
GO
SELECT * FROM [newRooms] ORDER BY rate ASC
GO