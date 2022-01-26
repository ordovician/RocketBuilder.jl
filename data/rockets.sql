-- Remember to turn on foreign key constrains after connecting to database.
-- otherwise ON UPDATE CASCADE doesn't work
-- sqlite> PRAGMA foreign_keys = ON;

-- Show tables:
-- sqlite> .tables
-- Show table fields
-- sqlite> .schema Tanks

CREATE TABLE Tanks (
    Tank TEXT PRIMARY KEY,
    TotalMass REAL,
    DryMass REAL
);

CREATE TABLE Engines (
    Engine TEXT PRIMARY KEY,
    Mass REAL,
    ThrustSL REAL,
    ThrustVac REAL,
    IspSL REAL,
    IspVac REAL
);

CREATE TABLE Rockets (
    RocketID INT PRIMARY KEY,
    Rocket TEXT,
    Tank TEXT REFERENCES Tanks(Tank) ON UPDATE CASCADE
    Engine TEXT REFERENCES Engines(Engine) ON UPDATE CASCADE
);

INSERT INTO Tanks VALUES('FL-T100', 560, 6);
INSERT INTO Tanks VALUES('FL-T200', 1300, 130);
INSERT INTO Tanks VALUES('FL-T400', 2250, 250);

INSERT INTO Tanks VALUES('Electron booster', 10200, 950);

INSERT INTO Engines VALUES('Merlin 1D', 470, 845, 914, 282, 311);
INSERT INTO Engines VALUES('Rutherford', 35, 25, 26, 311, 343);
