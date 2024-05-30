-- Create Schema ----
CREATE SCHEMA`coworking` ;

-- Create Building table ----
CREATE TABLE Building(
Id int NOT NULL,
BuildingNumber int NOT NULL,
StreetName varchar(255) NOT NULL,
StreetSuffix varchar(255) NOT NULL,
Neighbourhood varchar(255),
ZipCode int NOT NULL,
Latitude float NOT NULL,
Longitude float NOT NULL,
Status char(255) NOT NULL,
PRIMARY KEY(Id)
);

-- Create Building_floor table ----
CREATE TABLE Building_floor(
BuildingId int NOT NULL,
FloorNumber int NOT NULL,
Area int,
shared_floor tinyint(3) NOT NULL,
PRIMARY KEY(BuildingId, FloorNumber),
FOREIGN KEY(BuildingId) REFERENCES Building(Id)
);

-- Create Spaces table ----
CREATE TABLE Spaces(
Id int NOT NULL AUTO_INCREMENT,
SpaceType varchar(255) NOT NULL,
MaxCapacity int NOT NULL,
SpaceDescription varchar(255),
SpaceName varchar(255) NOT NULL,
PerSeatCost numeric(5, 2) NOT NULL,
Availability varchar(255) NOT NULL,
BuildingId int NOT NULL,
FloorNumber int NOT NULL,
PRIMARY KEY(Id),
FOREIGN KEY(BuildingId, FloorNumber) REFERENCES Building_floor(BuildingId, FloorNumber)
);

-- Create Users table ----
CREATE TABLE Users(
Id int NOT NULL AUTO_INCREMENT,
FirstName varchar(255) NOT NULL,
LastName varchar(255),
ContactNumber varchar(255) NOT NULL UNIQUE,
PRIMARY KEY(Id)
);

-- Create CorporatePoc table --
CREATE TABLE CorporatePoc(
UsersId int NOT NULL,
CorporateEmail varchar(255) NOT NULL,
CorporateEmail varchar(255) NOT NULL,
SSN varchar(255) NOT NULL UNIQUE,
PRIMARY KEY(UsersId),
FOREIGN KEY(UsersId) REFERENCES Users(Id)
);


-- Create Freelancer table --
CREATE TABLE Freelancer(
UsersId int NOT NULL,
Email varchar(255) NOT NULL UNIQUE,
IdentificationType varchar(255) NOT NULL,
IdentificationNum varchar(35) NOT NULL,
HouseNumber int NOT NULL,
StreetName varchar(255) NOT NULL,
StreetSuffix varchar(255) NOT NULL,
City varchar(255) NOT NULL,
State varchar(255) NOT NULL,
ZipCode int NOT NULL,
PRIMARY KEY(UsersId),
FOREIGN KEY(UsersId) REFERENCES Users(Id)
);

-- Create Corporate table--
CREATE TABLE Corporate(
Id int NOT NULL AUTO_INCREMENT,
CorporateName varchar(255) NOT NULL,
EIN varchar(35) NOT NULL UNIQUE,
UnitNum int NOT NULL,
BuildingName varchar(255) NOT NULL,
StreetName varchar(255) NOT NULL,
StreetSuffix varchar(255) NOT NULL,
City varchar(255) NOT NULL,
State varchar(255) NOT NULL,
ZipCode int NOT NULL,
Website varchar(255) NOT NULL,
CorporatePocUsersId int NOT NULL UNIQUE,
FOREIGN KEY(CorporatePocUsersId) REFERENCES CorporatePoc(UsersId),
PRIMARY KEY(Id)
);

-- Create Employees table--
CREATE TABLE Employees(
Id int NOT NULL AUTO_INCREMENT,
FirstName varchar(255) NOT NULL,
LastName varchar(255),
Email varchar(255),
CorporateId int NOT NULL,
PRIMARY KEY(Id),
FOREIGN KEY(CorporateId) REFERENCES Corporate(Id)
);


-- Create SpaceBooking table --
CREATE TABLE SpaceBooking(
Id int NOT NULL AUTO_INCREMENT,
NumSeatsBooked int NOT NULL,
BookingTime timestamp NOT NULL,
StartDate date NOT NULL,
EndDate date NOT NULL,
SpaceId int NOT NULL,
UsersId int NOT NULL,
PRIMARY KEY(Id),
FOREIGN KEY(UsersId) REFERENCES Users(Id),
FOREIGN KEY(SpaceId) REFERENCES Spaces(Id));


-- Create Service table --
CREATE TABLE Service(
Id int NOT NULL AUTO_INCREMENT,
Type varchar(255) NOT NULL,
ServiceCost numeric(3, 2) NOT NULL,
PRIMARY KEY(Id)
);

-- Create Service Booking --
CREATE TABLE ServiceBooking(
QuantityRequested int NOT NULL,
Purchased_at date NOT NULL,
SpaceBookingId int NOT NULL,
ServiceId int NOT NULL,
PRIMARY KEY(SpaceBookingId, ServiceId),
FOREIGN KEY(SpaceBookingId) REFERENCES SpaceBooking(Id),
FOREIGN KEY(ServiceId) REFERENCES Service(Id)
);

-- Create Invoice table --
CREATE TABLE Invoice(
Number int NOT NULL AUTO_INCREMENT,
BillingDate date NOT NULL,
SpaceCost numeric(10, 2) NOT NULL,
ServiceCost numeric(10, 2) NOT NULL,
TotalBillingCost numeric(10, 2) NOT NULL,
SpaceBookingId int NOT NULL UNIQUE,
PRIMARY KEY(Number),
FOREIGN KEY(SpaceBookingId) REFERENCES SpaceBooking(Id)
);

