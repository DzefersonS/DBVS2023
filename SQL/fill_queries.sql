-- Inserting Passengers
SELECT register_passenger('001', 'Michael', 'Brown', '1970-03-03', '123-456-7892', 'michael.brown@email.com', 5000);
SELECT register_passenger('002', 'Emily', 'Johnson', '1980-04-04', '123-456-7893', 'emily.johnson@email.com', 3000);
SELECT register_passenger('003', 'Grace', 'Lee', '1978-11-09', '123-456-7898', 'grace.lee@email.com', 10000);
SELECT register_passenger('004', 'Lucas', 'Garcia', '1983-02-17', '123-456-7899', 'lucas.garcia@email.com', 1500);


-- Inserting Employees
SELECT register_employee('005', 'David', 'Wilson', '1975-05-05', '123-456-7894', 'david.wilson@email.com', 'Manager', '2000-05-05');
SELECT register_pilot('006', 'Sarah', 'Miller', '1982-06-06', '123-456-7895', 'sarah.miller@email.com', 'Pilot', '2005-06-06', 'PLT100', '2005-06-06', '2025-06-06');
SELECT register_employee('007', 'Emma', 'Martinez', '1986-09-05', '123-456-7800', 'emma.martinez@email.com', 'Crew', '2010-09-05');
SELECT register_pilot('008', 'Noah', 'Rodriguez', '1979-12-12', '123-456-7801', 'noah.rodriguez@email.com', 'Co-Pilot', '2008-12-12', 'PLT101', '2008-12-12', '2028-12-12');

-- Inserting into airplane
SELECT add_airplane(200, 5, 'A1');
SELECT add_airplane(150, 10, 'B1');
SELECT add_airplane(300, 7, 'C1');
SELECT add_airplane(100, 11, 'D1');

-- Inserting into airport
SELECT add_airport('Heathrow', 'London');
SELECT add_airport('JFK', 'New York');
SELECT add_airport('Charles de Gaulle', 'Paris');
SELECT add_airport('Changi', 'Singapore');

-- Inserting into route
SELECT create_route(1, 2);
SELECT create_route(2, 1);
SELECT create_route(3, 4);
SELECT create_route(4, 3);

-- Inserting into flight
SELECT create_flight('2024-01-01 08:00:00', '2024-01-01 12:00:00', 1, 1, '006', '008');

-- Buying a few tickets
SELECT purchase_ticket('001', 1);
SELECT purchase_ticket('002', 2);
