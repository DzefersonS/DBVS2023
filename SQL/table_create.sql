create table Passenger
(
    PersonID integer,
    FirstName char(64) not null,
    LastName char (64) not null,
    DateOfBirthDay date not null
        check (DateOfBirthDay > '1900-01-01' and DateOfBirthDay < current_date),
    PhoneNumber integer not null,
    Email char(128) not null
        check (Email ~ '%_@__%.%_'),
    MoneyBalance integer default 0,
    IsBanned boolean default false,
    primary key(PersonID)
);

create table Membership
(
    PassengerID integer,
    ExpirationDate date not null,
    Discount integer not null default 0
        check (Discount >= 0 and Discount <= 100),
    foreign key (PassengerID) references Passenger(PersonID)
);

create table Employee
(
    EmployeeID serial,
    FirstName char(64) not null,
    LastName char(64) not null,
    DateOfBirthDay date not null
        check (DateOfBirthDay > '1900-01-01' and DateOfBirthDay < current_date),
    PhoneNumber char(15),
    Email char(128) not null
        check (Email ~ '%_@__%.%_'),
    Position char(64) not null,
    HireDate date not null
	check (HireDate >= DateOfBirthDay + interval '18 years' and HireDate <= current_date),
    primary key(EmployeeID)
);

create table Pilot
(
    EmployeeID integer,
    LicenseNumber char(64),
    LicenseType char(64),
    IssueDate date,
    ExpirationDate date
	check (ExpirationDate >= current_date),
  	primary key (EmployeeID),
    foreign key (EmployeeID) references Employee(EmployeeID)
);

create table Airplane
(
    AirplaneID serial,
    SeatCount integer not null,
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
    PilotID integer references Pilot(EmployeeID),
    CoPilotID integer references Pilot(EmployeeID),
    primary key(FlightID)
);

create table Ticket
(
    TicketID serial,
    FlightID integer not null references Flight(FlightID),
    SeatID integer,
    PersonID integer references Passenger(PersonID),
    Price integer not null,
    primary key(TicketID)
);
