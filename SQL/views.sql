CREATE VIEW FlightsNotSoldOut
AS SELECT f.FlightID, f.AirplaneID FROM Flight f
    JOIN Airplane a ON f.AirplaneID = a.AirplaneID
    WHERE (SELECT COUNT(*) FROM Ticket t WHERE t.FlightID = f.FlightID and t.PersonID IS NOT NULL) < a.SeatCount;

CREATE VIEW BannedPassengers AS
SELECT *
FROM Person p
JOIN Passenger ps ON p.PersonID = ps.PersonID
WHERE ps.IsBanned = true;

CREATE VIEW EmployeeDetails AS
SELECT *
FROM Person p
JOIN Employee e ON p.PersonID = e.PassengerID;

CREATE VIEW PassengerDetails AS
SELECT
    p.PersonID,
    p.FirstName,
    p.LastName,
    p.DateOfBirthDay,
    p.PhoneNumber,
    p.Email,
    ps.MoneyBalance,
    ps.IsBanned,
    ps.Discount
FROM Person p
JOIN Passenger ps ON p.PersonID = ps.PersonID;

CREATE VIEW TicketDetails AS
SELECT
    t.TicketID,
    t.Price,
    t.SeatID,
    t.PersonID,
    p.FirstName,
    p.LastName,
    p.DateOfBirthDay,
    f.FlightID,
    f.DepartureTime,
    f.ArrivalTime,
    f.IsCancelled,
    a.SeatCount,
    a.TicketPrice,
    r.DepartureAirport,
    r.DestinationAirport
FROM Ticket t
JOIN Flight f ON t.FlightID = f.FlightID
JOIN PassengerDetails p ON t.PersonID = p.PersonID
JOIN Airplane a ON f.AirplaneID = a.AirplaneID
JOIN Route r ON f.RouteID = r.RouteID;

CREATE MATERIALIZED VIEW FlightRevenueByRoute AS
SELECT
    r.RouteID,
    f.FlightID,
    SUM(t.Price)
FROM Flight f
LEFT JOIN Ticket t ON f.FlightID = t.FlightID
LEFT JOIN Route r ON f.RouteID = r.RouteID
WHERE t.PersonID IS NOT NULL
GROUP BY r.RouteID, f.FlightID;

REFRESH MATERIALIZED VIEW FlightRevenueByRoute;

CREATE MATERIALIZED VIEW EmployeeCountByPosition AS
SELECT
    e.Position,
    COUNT(e.PersonID)
FROM Employee e
GROUP BY e.Position;

REFRESH MATERIALIZED VIEW EmployeeCountByPosition;