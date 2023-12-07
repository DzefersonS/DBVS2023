-- Limits person to buying two tickets per flight
CREATE OR REPLACE FUNCTION PassengerMaxTicketCount()
RETURNS TRIGGER AS $$
BEGIN

    IF (SELECT COUNT(*) FROM Ticket WHERE PersonID = NEW.PersonID AND FlightID = NEW.FlightID) = 2
    THEN RAISE EXCEPTION 'Passenger can buy maximum of two tickets';
    END IF;

    RETURN NEW;
END; $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER PassengerMaxTicketCountTrigger
BEFORE INSERT
ON Ticket
FOR EACH ROW
EXECUTE FUNCTION PassengerMaxTicketCount();

-- Checks if flights do not overlap
CREATE OR REPLACE FUNCTION FlightOverlap()
RETURNS TRIGGER AS $$
DECLARE
    LastFlightArrival timestamp;
    LastFlightDeparture timestamp;
    cur CURSOR FOR SELECT ArrivalTime, DepartureTime FROM Flight WHERE NEW.AirplaneID = AirplaneID OR NEW.PilotID = PilotID;
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

CREATE OR REPLACE TRIGGER FlightOverlapTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION FlightOverlap();

-- Limits airplane to having maximum one flight per day
CREATE OR REPLACE FUNCTION AirplaneMaxFlightPerDay()
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


CREATE OR REPLACE TRIGGER AirplaneMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION AirplaneMaxFlightPerDay();

-- Limits pilot to having maximum one flight per 12h
CREATE OR REPLACE FUNCTION PilotMaxFlightPerDay()
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

CREATE OR REPLACE TRIGGER PilotMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION PilotMaxFlightPerDay();

-- Limits copilot to having maximum one flight per 12h
CREATE OR REPLACE FUNCTION CoPilotMaxFlightPerDay()
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

CREATE OR REPLACE TRIGGER CoPilotMaxFlightPerDayTrigger
BEFORE INSERT
ON Flight
FOR EACH ROW
EXECUTE FUNCTION CoPilotMaxFlightPerDay();