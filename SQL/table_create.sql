CREATE TABLE Person (
    PersonID varchar(11) PRIMARY KEY,
    FirstName char(64) NOT NULL,
    LastName char(64) NOT NULL,
    DateOfBirthDay date NOT NULL
        CHECK (DateOfBirthDay > '1900-01-01' AND DateOfBirthDay < CURRENT_DATE),
    PhoneNumber char(15),
    Email varchar(128) NOT NULL
        CHECK (Email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE Passenger (
    PassengerID varchar(11) PRIMARY KEY,
    MoneyBalance integer DEFAULT 0,
    IsBanned boolean DEFAULT false,
    Discount integer not null default 0
        check (Discount >= 0 and Discount <= 100),,
    FOREIGN KEY (PassengerID) REFERENCES Person(PersonID)
);

CREATE TABLE Employee (
    EmployeeID varchar(11) PRIMARY KEY,
    Position char(64) NOT NULL,
    HireDate date NOT NULL
        CHECK (HireDate <= CURRENT_DATE),
    FOREIGN KEY (EmployeeID) REFERENCES Person(PersonID)
);

create table Pilot
(
    EmployeeID varchar(11),
    LicenseNumber char(64),
    IssueDate date,
        check (IssueDate < ExpirationDate)
    ExpirationDate date
	    check (ExpirationDate >= current_date),
  	primary key (EmployeeID),
    foreign key (EmployeeID) references Employee(EmployeeID)
);

create table Airplane
(
    AirplaneID serial,
    SeatCount integer not null,
    RegistrationNumber char(64),
    primary key(AirplaneID)
);

create table Airport
(
    AirportID serial,
    AirportName char(128) not null,
    CityName char(128) not null,
    primary key(AirportID)
);

create table Route
(
    RouteID serial,
    DepartureAirport integer not null references Airport(AirportID),
    DestinationAirport integer not null references Airport(AirportID),
    primary key(RouteID)
);

create table Flight
(
    FlightID serial,
    DepartureTime timestamp not null
        check (DepartureTime > current_timestamp),
    ArrivalTime timestamp not null
        check (ArrivalTime > DepartureTime),
    RouteID integer not null references Route(RouteID),
    AirplaneID integer not null references Airplane(AirplaneID),
    IsCancelled boolean default false,
    PilotID varchar(11) references Pilot(EmployeeID),
    CoPilotID varchar(11) references Pilot(EmployeeID),
    primary key(FlightID)
);

create table Ticket
(
    TicketID serial,
    FlightID integer not null references Flight(FlightID),
    SeatID integer not null,
    PersonID varchar(11) references Passenger(PassengerID),
    Price integer not null,
    primary key(TicketID)
);