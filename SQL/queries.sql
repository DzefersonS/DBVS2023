-- Function that registers a person if they don't already exist
CREATE OR REPLACE FUNCTION register_person(
    p_PersonID varchar(11), 
    p_FirstName char(64), 
    p_LastName char(64), 
    p_DateOfBirthDay date, 
    p_PhoneNumber char(15), 
    p_Email varchar(128)
) RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Person WHERE PersonID = p_PersonID) THEN
        INSERT INTO Person (PersonID, FirstName, LastName, DateOfBirthDay, PhoneNumber, Email) 
        VALUES (p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a passenger exists and insert if not
CREATE OR REPLACE FUNCTION register_passenger(
    p_PersonID varchar(11), 
    p_FirstName char(64), 
    p_LastName char(64), 
    p_DateOfBirthDay date, 
    p_PhoneNumber char(15), 
    p_Email varchar(128),
    p_MoneyBalance integer
) RETURNS void AS $$
BEGIN
    PERFORM register_person(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email);

    IF NOT EXISTS (SELECT 1 FROM Passenger WHERE PassengerID = p_PersonID) THEN
        INSERT INTO Passenger (PassengerID, MoneyBalance, IsBanned) 
        VALUES (p_PersonID, p_MoneyBalance, false);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to register an employee
CREATE OR REPLACE FUNCTION register_employee(
    p_PersonID varchar(11), 
    p_FirstName char(64), 
    p_LastName char(64), 
    p_DateOfBirthDay date, 
    p_PhoneNumber char(15), 
    p_Email varchar(128),
    p_Position char(64), 
    p_HireDate date
) RETURNS void AS $$
BEGIN
	-- Register employee as a person
    PERFORM register_person(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email);

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = p_PersonID) THEN
        INSERT INTO Employee (EmployeeID, Position, HireDate) 
        VALUES (p_PersonID, p_Position, p_HireDate);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to register a pilot
CREATE OR REPLACE FUNCTION register_pilot(
    p_PersonID varchar(11), 
    p_FirstName char(64), 
    p_LastName char(64), 
    p_DateOfBirthDay date, 
    p_PhoneNumber char(15), 
    p_Email varchar(128),
    p_Position char(64), 
    p_HireDate date,
    p_LicenseNumber char(64),
    p_LicenseType char(64),
    p_IssueDate date,
    p_ExpirationDate date
) RETURNS void AS $$
BEGIN
    -- Register the pilot as an employee
    PERFORM register_employee(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email, p_Position, p_HireDate);

    -- Then check if the person is already registered as a pilot
    IF NOT EXISTS (SELECT 1 FROM Pilot WHERE EmployeeID = p_PersonID) THEN
        INSERT INTO Pilot (EmployeeID, LicenseNumber, LicenseType, IssueDate, ExpirationDate)
        VALUES (p_PersonID, p_LicenseNumber, p_LicenseType, p_IssueDate, p_ExpirationDate);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to ban a passenger and refund each ticket individually
CREATE OR REPLACE FUNCTION ban_passenger(p_PassengerID varchar(11)) RETURNS void AS $$
DECLARE
    discount INTEGER;
    ticketPrice INTEGER;
    ticketID INTEGER;
    cur CURSOR FOR SELECT TicketID, Price FROM Ticket WHERE PersonID = p_PassengerID;
BEGIN
    -- Get the discount percentage from Membership, if it exists
    SELECT Discount INTO discount FROM Membership WHERE PassengerID = p_PassengerID;
    IF NOT FOUND THEN
        discount := 0; -- If no membership, set discount to 0
    END IF;

    -- Open the cursor
    OPEN cur;

    -- Loop through each ticket and process the refund
    LOOP
        FETCH cur INTO ticketID, ticketPrice;
        EXIT WHEN NOT FOUND;

        -- Update the MoneyBalance for each ticket
        UPDATE Passenger SET MoneyBalance = MoneyBalance + ticketPrice * (1 - discount / 100.0)
        WHERE PassengerID = p_PassengerID;
        
        -- Set PersonID to null for the current ticket
        UPDATE Ticket SET PersonID = NULL WHERE TicketID = ticketID;
    END LOOP;

    -- Close the cursor
    CLOSE cur;

    -- Delete the membership record
    DELETE FROM Membership WHERE PassengerID = p_PassengerID;

    -- Set IsBanned to true in Passenger table
    UPDATE Passenger SET IsBanned = true WHERE PassengerID = p_PassengerID;
END;
$$ LANGUAGE plpgsql;

-- Function to create new flight and creates tickets

CREATE FUNCTION create_flight(
    p_DepartureTime timestamp,
    p_ArrivalTime timestamp,
    p_RouteID integer,
    p_AirplaneID integer,
    p_PilotID varchar(11),
    p_CoPilotID varchar(11)
)
RETURNS void AS $$
DECLARE
    p_FlightID integer;
    count integer;
    currentCount integer := 1;
BEGIN
    SELECT SeatCount INTO count FROM Airplane WHERE AirplaneID = p_AirplaneID;

    INSERT INTO Flight (DepartureTime, ArrivalTime, RouteID, AirplaneID, PilotID, CoPilotID)
    VALUES (p_DepartureTime, p_ArrivalTime, p_RouteID, p_AirplaneID, p_PilotID, p_CoPilotID)
    RETURNING FlightID INTO p_FlightID;
    
   WHILE currentCount <= count LOOP
        INSERT INTO Ticket (FlightID, SeatID, Price)
        VALUES (p_FlightID, currentCount, 1);
        currentCount := currentCount + 1;
    END LOOP;
END; $$
LANGUAGE plpgsql;

--/ MINOR QUERIES. NOT FUNCTIONS /--
-- Create a new airport
INSERT INTO Airport (AirportName, CityName)
VALUES ('airport_name', 'city_name');

-- Create a new route
INSERT INTO Route (DepartureAirport, DestinationAirport)
VALUES ('departure_airport_id', 'destination_airport_id');

-- Create a new airplane
INSERT INTO Airplane (SeatCount)
VALUES ('seat_count');



-- Limits person to buying two tickets per flight

CREATE FUNCTION PassengerMaxTicketCount()
RETURNS TRIGGER AS $$
BEGIN

    IF (SELECT COUNT(*) FROM Ticket WHERE PersonID = NEW.PersonID AND FlightID = NEW.FlightID) = 2
    THEN RAISE EXCEPTION 'Passenger can buy maximum of two tickets';
    END IF;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER PassengerMaxTicketCountTrigger
BEFORE INSERT
ON Ticket
FOR EACH ROW
EXECUTE FUNCTION PassengerMaxTicketCount();

-- Checks if flights do not overlap

CREATE FUNCTION FlightOverlap()
RETURNS TRIGGER AS $$
DECLARE
    LastFlightArrival timestamp;
    LastFlightDeparture timestamp;
    cur CURSOR FOR SELECT ArrivalTime, DepartureTime FROM Flight;
BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO LastFlightArrival, LastFlightDeparture;
        EXIT WHEN NOT FOUND;

        IF NOT (NEW.DepartureTime > LastFlightArrival OR NEW.ArrivalTime < LastFlightDeparture)
        THEN RAISE EXCEPTION 'Flights overlap';
        END IF;

    END LOOP;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER FlightOverlapTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION FlightOverlap();

-- Limits airplane to having maximum one flight per day

CREATE FUNCTION AirplaneMaxFlightPerDay()
RETURNS TRIGGER AS $$
DECLARE
    LastFlightArrival timestamp;
    cur CURSOR FOR SELECT ArrivalTime FROM Flight WHERE AirplaneID = NEW.AirplaneID;
BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO LastFlightArrival;
        EXIT WHEN NOT FOUND;

        IF LastFlightArrival > NEW.DepartureTime - INTERVAL '24 hours'
        THEN RAISE EXCEPTION 'Airplane must pass 24 hour maintenance before next flight';
        END IF;

    END LOOP;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;


CREATE TRIGGER AirplaneMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION AirplaneMaxFlightPerDay();

-- Limits pilot to having maximum one flight per 12h

CREATE FUNCTION PilotMaxFlightPerDay()
RETURNS TRIGGER AS $$
DECLARE
    LastFlightArrival timestamp;
    cur CURSOR FOR SELECT ArrivalTime FROM Flight WHERE PilotID = NEW.PilotID;
BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO LastFlightArrival;
        EXIT WHEN NOT FOUND;

        IF LastFlightArrival > NEW.DepartureTime - INTERVAL '12 hours'
        THEN RAISE EXCEPTION 'Pilot must rest for 12 hour next flight';
        END IF;

    END LOOP;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER PilotMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION PilotMaxFlightPerDay();

-- Limits copilot to having maximum one flight per 12h

CREATE FUNCTION CoPilotMaxFlightPerDay()
RETURNS TRIGGER AS $$
DECLARE
    LastFlightArrival timestamp;
    cur CURSOR FOR SELECT ArrivalTime FROM Flight WHERE CoPilotID = NEW.CoPilotID;
BEGIN
    OPEN cur;

    LOOP
        FETCH cur INTO LastFlightArrival;
        EXIT WHEN NOT FOUND;

        IF LastFlightArrival > NEW.DepartureTime - INTERVAL '12 hours'
        THEN RAISE EXCEPTION 'Pilot must rest for 12 hour next flight';
        END IF;

    END LOOP;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE TRIGGER CoPilotMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION CoPilotMaxFlightPerDay();

-- Indexes

CREATE INDEX IndexPilotID
ON Flight(PilotID);

CREATE INDEX IndexCoPilotID
ON Flight(CoPilotID);

CREATE INDEX IndexAirplaneID
ON Flight(AirplaneID);

-- Views

-- Flights that have not sold all tickets
CREATE VIEW FlightNotSoldOut
AS SELECT
    F.FlightID, F.AirplaneID FROM Flight F
    JOIN Airplane A ON F.AirplaneID = A.AirplaneID
    WHERE (SELECT COUNT(*) FROM Ticket T WHERE T.FlightID = F.FlightID and T.PersonID IS NOT NULL) < A.SeatCount;