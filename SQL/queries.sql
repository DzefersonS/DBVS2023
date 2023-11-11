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