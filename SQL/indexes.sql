CREATE OR REPLACE INDEX IndexPilotID
ON Flight(PilotID);

CREATE OR REPLACE INDEX IndexCoPilotID
ON Flight(CoPilotID);

CREATE OR REPLACE INDEX IndexAirplaneID
ON Flight(AirplaneID);

CREATE OR REPLACE UNIQUE INDEX PilotLicenseNumber
ON Pilot(LicenseNumber);

CREATE OR REPLACE UNIQUE INDEX AirplaneRegistrationNumber
ON Airplane(RegistrationNumber);