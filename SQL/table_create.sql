CREATE TABLE Person (
    PersonID varchar(11),
    FirstName char(64) NOT NULL,
    LastName char(64) NOT NULL,
    DateOfBirthDay date NOT NULL
        CHECK (DateOfBirthDay > '1900-01-01' AND DateOfBirthDay < CURRENT_DATE),
    PhoneNumber char(15),
    Email varchar(128) NOT NULL
        CHECK (Email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    primary key(PersonID)
);

CREATE TABLE Passenger (
    PassengerID varchar(11),
    MoneyBalance integer not null DEFAULT 0,
    IsBanned boolean not null DEFAULT false,
    Discount integer not null default 0
        check (Discount >= 0 and Discount <= 100),
    primary key(PassengerID),
    foreign key (PassengerID) references Person(PersonID)
);

CREATE TABLE Employee (
    EmployeeID varchar(11),
    Position char(64) NOT NULL,
    HireDate date NOT NULL
        CHECK (HireDate <= CURRENT_DATE),
    primary key (EmployeeID),
    foreign key (EmployeeID) references Person(PersonID)
);

create table Pilot
(
    EmployeeID varchar(11),
    LicenseNumber char(64) not null,
    IssueDate date not null 
        check (IssueDate < ExpirationDate),
    ExpirationDate date not null 
 	    check (ExpirationDate >= current_date),
  	primary key (EmployeeID),
    foreign key (EmployeeID) references Employee(EmployeeID)
);

create table Airplane
(
    AirplaneID serial,
    SeatCount integer not null,
    RegistrationNumber char(64) not null,
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
    DepartureAirport integer not null,
    DestinationAirport integer not null,
    primary key(RouteID),
    foreign key(DepartureAirport) references Airport(AirportID),
    foreign key(DestinationAirport) references Airport(AirportID)
);

create table Flight
(
    FlightID serial,
    DepartureTime timestamp not null
        check (DepartureTime > current_timestamp),
    ArrivalTime timestamp not null
        check (ArrivalTime > DepartureTime),
    RouteID integer not null,
    AirplaneID integer not null,
    IsCancelled boolean default false not null,
    PilotID varchar(11) not null,
    CoPilotID varchar(11) not null,
    primary key(FlightID),
    foreign key(AirplaneID) references Airplane(AirplaneID),
    foreign key(RouteID) references Route(RouteID),
    foreign key(PilotID) references Pilot(EmployeeID),
    foreign key(CoPilotID) references Pilot(EmployeeID)
);

create table Ticket
(
    TicketID serial,
    FlightID integer not null,
    SeatID integer not null,
    PersonID varchar(11),
    Price integer not null,
    primary key(TicketID),
    foreign key(FlightID) references Flight(FlightID),
    foreign key(PersonID) references Passenger(PassengerID)
);