create FUNCTION register_person(
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

create FUNCTION register_passenger(
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

    IF NOT EXISTS (SELECT 1 FROM Passenger WHERE PersonID = p_PersonID) THEN
        INSERT INTO Passenger (PersonID, MoneyBalance, IsBanned) 
        VALUES (p_PersonID, p_MoneyBalance, false);
    END IF;
END;
$$ LANGUAGE plpgsql;

create FUNCTION register_employee(
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
    PERFORM register_person(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email);

    IF NOT EXISTS (SELECT 1 FROM Employee WHERE PersonID = p_PersonID) THEN
        INSERT INTO Employee (PersonID, Position, HireDate) 
        VALUES (p_PersonID, p_Position, p_HireDate);
    END IF;
END;
$$ LANGUAGE plpgsql;

create FUNCTION register_pilot(
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
    PERFORM register_employee(p_PersonID, p_FirstName, p_LastName, p_DateOfBirthDay, p_PhoneNumber, p_Email, p_Position, p_HireDate);

    IF NOT EXISTS (SELECT 1 FROM Pilot WHERE PersonID = p_PersonID) THEN
        INSERT INTO Pilot (PersonID, LicenseNumber, IssueDate, ExpirationDate)
        VALUES (p_PersonID, p_LicenseNumber, p_IssueDate, p_ExpirationDate);
    END IF;
END;
$$ LANGUAGE plpgsql;

create FUNCTION ban_passenger(p_PersonID varchar(11)) 
RETURNS void AS $$
DECLARE
    p_Discount INTEGER;
    p_ticketPrice INTEGER;
    p_ticketID INTEGER;
    cur CURSOR FOR SELECT Ticket.TicketID, Ticket.Price FROM Ticket WHERE PersonID = p_PersonID;
BEGIN
    SELECT Passenger.Discount INTO p_Discount FROM Passenger WHERE PersonID = p_PersonID;
    IF NOT FOUND THEN
        p_Discount := 0;
    END IF;

    OPEN cur;

    LOOP
        FETCH cur INTO p_ticketID, p_ticketPrice;
        EXIT WHEN NOT FOUND;

        UPDATE Passenger SET MoneyBalance = MoneyBalance + p_ticketPrice * (1 - discount / 100.0)
        WHERE PersonID = p_PersonID;
        
        UPDATE Ticket SET PersonID = NULL WHERE TicketID = p_ticketID;
    END LOOP;

    CLOSE cur;

    UPDATE Passenger SET IsBanned = true WHERE PersonID = p_PersonID;
END;
$$ LANGUAGE plpgsql;

create FUNCTION create_flight(
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

create FUNCTION cancel_flight(p_FlightID integer) 
RETURNS void AS $$
DECLARE
    ticketRecord RECORD;
    passengerDiscount INTEGER;
BEGIN
    UPDATE Flight SET IsCancelled = true WHERE FlightID = p_FlightID;

    FOR ticketRecord IN SELECT t.TicketID, t.PersonID, t.Price 
                        FROM Ticket t
                        WHERE t.FlightID = p_FlightID LOOP

        SELECT Discount INTO passengerDiscount 
        FROM Passenger 
        WHERE PersonID = ticketRecord.PersonID;
        
        IF passengerDiscount IS NULL THEN
            passengerDiscount := 0;
        END IF;

        UPDATE Passenger 
        SET MoneyBalance = MoneyBalance + (ticketRecord.Price * (1 - passengerDiscount / 100.0)) 
        WHERE PersonID = ticketRecord.PersonID;

        DELETE FROM Ticket 
        WHERE TicketID = ticketRecord.TicketID;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

create FUNCTION purchase_ticket(
    p_PersonID varchar(11), 
    p_TicketID integer
) RETURNS void AS $$
DECLARE
    ticketPrice INTEGER;
    passengerBalance INTEGER;
    passengerDiscount INTEGER;
    finalPrice INTEGER;
BEGIN
    SELECT Price INTO ticketPrice FROM Ticket WHERE TicketID = p_TicketID;

    SELECT MoneyBalance INTO passengerBalance FROM Passenger WHERE PersonID = p_PersonID;

    SELECT Discount INTO passengerDiscount FROM Passenger WHERE PersonID = p_PersonID;

    IF passengerDiscount IS NULL THEN
        passengerDiscount := 0;
    END IF;

    finalPrice := ticketPrice * (1 - passengerDiscount / 100.0);

    IF passengerBalance >= finalPrice THEN
        UPDATE Passenger 
        SET MoneyBalance = passengerBalance - finalPrice
        WHERE PersonID = p_PersonID;

        UPDATE Ticket 
        SET PersonID = p_PersonID 
        WHERE TicketID = p_TicketID;
    ELSE
        RAISE EXCEPTION 'Insufficient balance to purchase the ticket.';
    END IF;
END;
$$ LANGUAGE plpgsql;

create FUNCTION add_airplane(
    p_SeatCount integer,
    p_TicketPrice integer,
    p_RegistrationNumber char(64)
) RETURNS void AS $$
BEGIN
    INSERT INTO Airplane (SeatCount, TicketPrice, RegistrationNumber) VALUES (p_SeatCount, p_TicketPrice, p_RegistrationNumber);
END;
$$ LANGUAGE plpgsql;

create FUNCTION update_airplane(
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

create FUNCTION add_airport(
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

create FUNCTION update_airport(
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

create FUNCTION create_route(
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

create FUNCTION update_route(
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