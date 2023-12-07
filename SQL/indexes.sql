create INDEX IndexPilotID
ON Flight(PilotID);

create INDEX IndexCoPilotID
ON Flight(CoPilotID);

create INDEX IndexAirplaneID
ON Flight(AirplaneID);

create UNIQUE INDEX PilotLicenseNumber
ON Pilot(LicenseNumber);

create UNIQUE INDEX AirplaneRegistrationNumber
ON Airplane(RegistrationNumber);