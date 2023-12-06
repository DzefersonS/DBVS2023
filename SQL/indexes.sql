CREATE INDEX IndexPilotID
ON Flight(PilotID);

CREATE INDEX IndexCoPilotID
ON Flight(CoPilotID);

CREATE INDEX IndexAirplaneID
ON Flight(AirplaneID);

CREATE UNIQUE INDEX PilotLicenseNumber
ON Pilot(LicenseNumber);

CREATE UNIQUE INDEX AirplaneRegistrationNumber
ON Airplane(RegistrationNumber);