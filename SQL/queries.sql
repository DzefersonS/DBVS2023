-- Function that registers a person if they don't already exist
CREATE FUNCTION register_person(
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
CREATE FUNCTION register_passenger(
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
CREATE FUNCTION register_employee(
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
CREATE FUNCTION register_pilot(
    p_PersonID varchar(11), 
    p_FirstName char(64), 
    p_LastName char(64), 
    p_DateOfBirthDay date, 
    p_PhoneNumber char(15), 
    p_Email varchar(128),
    p_Position char(64), 
    p_HireDate date,
    p_LicenseNumber char(64),
    p_IssueDate date,
    p_ExpirationDate date
) RETURNS void AS $$
BEGIN
    -- Register the pilot as an employee
    PERFORM register_employee(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email, p_Position, p_HireDate);

    -- Then check if the person is already registered as a pilot
    IF NOT EXISTS (SELECT 1 FROM Pilot WHERE EmployeeID = p_PersonID) THEN
        INSERT INTO Pilot (EmployeeID, LicenseNumber, IssueDate, ExpirationDate)
        VALUES (p_PersonID, p_LicenseNumber, p_IssueDate, p_ExpirationDate);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to ban a passenger and refund each ticket individually
CREATE FUNCTION ban_passenger(p_PassengerID varchar(11)) 
RETURNS void AS $$
DECLARE
    discount INTEGER;
    ticketPrice INTEGER;
    ticketID INTEGER;
    cur CURSOR FOR SELECT TicketID, Price FROM Ticket WHERE PersonID = p_PassengerID;
BEGIN
    -- Get the discount percentage from Membership, if it exists
    SELECT Discount INTO discount FROM Passenger WHERE PassengerID = p_PassengerID;
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

-- Function that cancels a flight and refunds all tickets
CREATE FUNCTION cancel_flight(p_FlightID integer) 
RETURNS void AS $$
DECLARE
    ticketRecord RECORD;
    passengerDiscount INTEGER;
BEGIN
    -- Mark the flight as cancelled
    UPDATE Flight SET IsCancelled = true WHERE FlightID = p_FlightID;

    -- Find all tickets and calculate refunds
    FOR ticketRecord IN SELECT t.TicketID, t.PersonID, t.Price 
                        FROM Ticket t
                        WHERE t.FlightID = p_FlightID LOOP

        -- Get the discount from Membership, if it exists
        SELECT Discount INTO passengerDiscount 
        FROM Passenger 
        WHERE PassengerID = ticketRecord.PersonID;
        
        -- If the passenger is not a member, set discount to 0
        IF passengerDiscount IS NULL THEN
            passengerDiscount := 0;
        END IF;

        UPDATE Passenger 
        SET MoneyBalance = MoneyBalance + (ticketRecord.Price * (1 - passengerDiscount / 100.0)) 
        WHERE PassengerID = ticketRecord.PersonID;

        UPDATE Ticket 
        SET PersonID = NULL 
        WHERE TicketID = ticketRecord.TicketID;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function for purchasing a ticket
CREATE FUNCTION purchase_ticket(
    p_PassengerID varchar(11), 
    p_TicketID integer
) RETURNS void AS $$
DECLARE
    ticketPrice INTEGER;
    passengerBalance INTEGER;
    passengerDiscount INTEGER;
    finalPrice INTEGER;
BEGIN
    -- Get the ticket price
    SELECT Price INTO ticketPrice FROM Ticket WHERE TicketID = p_TicketID;

    -- Get the passenger's current balance
    SELECT MoneyBalance INTO passengerBalance FROM Passenger WHERE PassengerID = p_PassengerID;

    -- Get the discount from Membership, if it exists
    SELECT Discount INTO passengerDiscount FROM Passenger WHERE PassengerID = p_PassengerID;

    -- If the passenger is not a member, set discount to 0
    IF passengerDiscount IS NULL THEN
        passengerDiscount := 0;
    END IF;

    -- Calculate the final price after discount
    finalPrice := ticketPrice * (1 - passengerDiscount / 100.0);

    -- Check if the passenger has enough balance
    IF passengerBalance >= finalPrice THEN
        -- Step 2: Update the passenger's MoneyBalance
        UPDATE Passenger 
        SET MoneyBalance = passengerBalance - finalPrice
        WHERE PassengerID = p_PassengerID;

        -- Step 3: Update the ticket to assign to the passenger
        UPDATE Ticket 
        SET PersonID = p_PassengerID 
        WHERE TicketID = p_TicketID;
    ELSE
        -- Raise an exception if the balance is insufficient
        RAISE EXCEPTION 'Insufficient balance to purchase the ticket.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to add new airplane
CREATE FUNCTION add_airplane(
    p_SeatCount integer
) RETURNS void AS $$
BEGIN
    IF p_SeatCount > 0 THEN
        INSERT INTO Airplane (SeatCount) VALUES (p_SeatCount);
    ELSE
        RAISE EXCEPTION 'Invalid seat count.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update airplane
CREATE FUNCTION update_airplane(
    p_AirplaneID integer,
    p_NewSeatCount integer
) RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Airplane WHERE AirplaneID = p_AirplaneID) THEN
        IF p_NewSeatCount > 0 THEN
            UPDATE Airplane SET SeatCount = p_NewSeatCount WHERE AirplaneID = p_AirplaneID;
        ELSE
            RAISE EXCEPTION 'Invalid seat count.';
        END IF;
    ELSE
        RAISE EXCEPTION 'Airplane does not exist.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to add airport
CREATE FUNCTION add_airport(
    p_AirportName char(128),
    p_CityName char(128)
) RETURNS void AS $$
BEGIN
    IF p_AirportName IS NOT NULL AND p_CityName IS NOT NULL THEN
        INSERT INTO Airport (AirportName, CityName) VALUES (p_AirportName, p_CityName);
    ELSE
        RAISE EXCEPTION 'Invalid airport name or city name.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update airport
CREATE FUNCTION update_airport(
    p_AirportID integer,
    p_NewAirportName char(128),
    p_NewCityName char(128)
) RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Airport WHERE AirportID = p_AirportID) THEN
        UPDATE Airport 
        SET AirportName = p_NewAirportName, CityName = p_NewCityName 
        WHERE AirportID = p_AirportID;
    ELSE
        RAISE EXCEPTION 'Airport does not exist.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Function to create route
CREATE FUNCTION create_route(
    p_DepartureAirportID integer,
    p_DestinationAirportID integer
) RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Airport WHERE AirportID = p_DepartureAirportID) AND
       EXISTS (SELECT 1 FROM Airport WHERE AirportID = p_DestinationAirportID) THEN
        INSERT INTO Route (DepartureAirport, DestinationAirport) 
        VALUES (p_DepartureAirportID, p_DestinationAirportID);
    ELSE
        RAISE EXCEPTION 'Departure or destination airport does not exist.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update route
CREATE FUNCTION update_route(
    p_RouteID integer,
    p_NewDepartureAirportID integer,
    p_NewDestinationAirportID integer
) RETURNS void AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Route WHERE RouteID = p_RouteID) THEN
        IF EXISTS (SELECT 1 FROM Airport WHERE AirportID = p_NewDepartureAirportID) AND
           EXISTS (SELECT 1 FROM Airport WHERE AirportID = p_NewDestinationAirportID) THEN
            UPDATE Route 
            SET DepartureAirport = p_NewDepartureAirportID, DestinationAirport = p_NewDestinationAirportID 
            WHERE RouteID = p_RouteID;
        ELSE
            RAISE EXCEPTION 'New departure or destination airport does not exist.';
        END IF;
    ELSE
        RAISE EXCEPTION 'Route does not exist.';
    END IF;
END;
$$ LANGUAGE plpgsql;