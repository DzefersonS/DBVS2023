-- Inserting Passengers
INSERT INTO Person (PersonID, FirstName, LastName, DateOfBirthDay, PhoneNumber, Email)
VALUES 
('00000000001', 'John', 'Doe', '1985-06-15', '1234567890', 'john.doe@email.com'),
('00000000002', 'Jane', 'Smith', '1990-03-22', '1234567891', 'jane.smith@email.com'),
('00000000003', 'Alice', 'Johnson', '1978-12-05', '1234567892', 'alice.johnson@email.com');

-- Inserting Employees
INSERT INTO Person (PersonID, FirstName, LastName, DateOfBirthDay, PhoneNumber, Email)
VALUES 
('00000000004', 'Emily', 'Taylor', '1980-01-20', '1234567893', 'emily.taylor@email.com'),
('00000000005', 'Michael', 'Brown', '1975-07-11', '1234567894', 'michael.brown@email.com');

-- Inserting into Passenger
INSERT INTO Passenger (PersonID)
VALUES 
('00000000001'),
('00000000002'),
('00000000003');

-- Inserting into Employee
INSERT INTO Employee (PersonID, Position, HireDate)
VALUES 
('00000000004', 'Flight Attendant', '2010-05-10'),
('00000000005', 'Pilot', '2008-08-15');

INSERT INTO Pilot (PersonID, LicenseNumber, IssueDate, ExpirationDate)
VALUES 
('00000000005', 'LN123456', '2008-08-15', '2028-08-15');

-- Inserting into airplane
INSERT INTO Airplane (SeatCount, RegistrationNumber, TicketPrice)
VALUES 
(200, 'a', 1),
(150, 'b', 2),
(300, 'c', 3);

-- Inserting into airport
INSERT INTO Airport (AirportName, CityName)
VALUES 
('Gateway International', 'Springfield'),
('Harbor Field', 'Riverdale'),
('Summit Airport', 'Hilltown');

-- Inserting into route
INSERT INTO Route (DepartureAirport, DestinationAirport)
VALUES 
(1, 2),
(2, 3),
(3, 1);

-- Inserting into flight
select create_flight('2023-12-25 08:00:00', '2023-12-25 10:00:00', 1, 1, '00000000005', NULL);
select create_flight('2023-12-26 09:00:00', '2023-12-26 11:30:00', 2, 2, '00000000005', NULL);
select create_flight('2023-12-27 07:30:00', '2023-12-27 09:45:00', 3, 3, '00000000005', NULL);

