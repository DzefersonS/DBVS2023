CREATE OR REPLACE TABLE Person (
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

CREATE OR REPLACE TABLE Passenger (
    PersonID varchar(11),
    MoneyBalance integer not null DEFAULT 0,
    IsBanned boolean not null DEFAULT false,
    Discount integer not null default 0
        check (Discount >= 0 and Discount <= 100),
    primary key(PersonID),
    foreign key (PersonID) references Person(PersonID) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Employee (
    PersonID varchar(11),
    Position char(64) NOT NULL,
    HireDate date NOT NULL
        CHECK (HireDate <= CURRENT_DATE),
    primary key (PersonID),
    foreign key (PersonID) references Person(PersonID) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Pilot (
    PersonID varchar(11),
    LicenseNumber char(64) not null,
    IssueDate date not null 
        check (IssueDate < ExpirationDate),
    ExpirationDate date not null 
 	    check (ExpirationDate >= current_date),
  	primary key (PersonID),
    foreign key (PersonID) references Employee(PersonID) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Airplane (
    AirplaneID serial,
    SeatCount integer not null
        check (SeatCount > 0),
    TicketPrice integer not null
        check (TicketPrice > 0),
    RegistrationNumber char(64) not null,
    primary key(AirplaneID)
);

CREATE OR REPLACE TABLE Airport (
    AirportID serial,
    AirportName char(128) not null,
    CityName char(128) not null,
    primary key(AirportID)
);

CREATE OR REPLACE TABLE Route (
    RouteID serial,
    DepartureAirport integer not null,
    DestinationAirport integer not null,
    primary key(RouteID),
    foreign key(DepartureAirport) references Airport(AirportID) ON DELETE CASCADE,
    foreign key(DestinationAirport) references Airport(AirportID) ON DELETE CASCADE
);

CREATE OR REPLACE TABLE Flight (
    FlightID serial,
    DepartureTime timestamp not null
        check (DepartureTime > current_timestamp),
    ArrivalTime timestamp not null
        check (ArrivalTime > DepartureTime),
    RouteID integer not null,
    AirplaneID integer not null,
    IsCancelled boolean default false not null,
    PilotID varchar(11) not null,
    CoPilotID varchar(11),
    primary key(FlightID),
    foreign key(AirplaneID) references Airplane(AirplaneID) ON DELETE CASCADE,
    foreign key(RouteID) references Route(RouteID) ON DELETE CASCADE,
    foreign key(PilotID) references Pilot(PersonID) ON DELETE SET NULL,
    foreign key(CoPilotID) references Pilot(PersonID) ON DELETE SET NULL
);

CREATE OR REPLACE TABLE Ticket (
    TicketID serial,
    FlightID integer not null,
    SeatID integer not null,
    PersonID varchar(11),
    Price integer not null,
    primary key(TicketID),
    foreign key(FlightID) references Flight(FlightID) ON DELETE CASCADE,
    foreign key(PersonID) references Passenger(PersonID) ON DELETE SET NULL
);