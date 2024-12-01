
-- Problem types table
CREATE TABLE ProblemTypes (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Description TEXT,
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMPTZ
);

-- Difficulty levels table
CREATE TABLE DifficultyLevels (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(10) NOT NULL,
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Problems table
CREATE TABLE Problems (
    ID SERIAL PRIMARY KEY,
    TypeID INTEGER REFERENCES ProblemTypes(ID),
    DifficultyID INTEGER REFERENCES DifficultyLevels(ID),
    ImagePath VARCHAR(255),
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMPTZ,
    IsActive BOOLEAN DEFAULT TRUE
);

-- Worksheets table
CREATE TABLE Worksheets (
    ID SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    TargetLevel VARCHAR(50),
    CreatedBy VARCHAR(100),
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMPTZ,
    IsPublished BOOLEAN DEFAULT FALSE
);

-- Worksheet problems junction table
CREATE TABLE WorksheetProblems (
    WorksheetID INTEGER REFERENCES Worksheets(ID) ON DELETE CASCADE,
    ProblemID INTEGER REFERENCES Problems(ID) ON DELETE CASCADE,
    ProblemOrder INTEGER NOT NULL,
    CONSTRAINT PK_WorksheetProblems PRIMARY KEY (WorksheetID, ProblemID)
);

-- Tags table
CREATE TABLE Tags (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL UNIQUE,
    CreatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Problem tags junction table
CREATE TABLE ProblemTags (
    ProblemID INTEGER REFERENCES Problems(ID) ON DELETE CASCADE,
    TagID INTEGER REFERENCES Tags(ID) ON DELETE CASCADE,
    CONSTRAINT PK_ProblemTags PRIMARY KEY (ProblemID, TagID)
);

-- Create indexes
CREATE INDEX IX_Problems_TypeID ON Problems(TypeID);
CREATE INDEX IX_Problems_DifficultyID ON Problems(DifficultyID);
CREATE INDEX IX_WorksheetProblems_ProblemID ON WorksheetProblems(ProblemID);

-- Create trigger function
CREATE OR REPLACE FUNCTION UpdateUpdatedAtColumn()
RETURNS TRIGGER AS $$
BEGIN
    NEW.UpdatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER TR_Problems_UpdatedAt
    BEFORE UPDATE ON Problems
    FOR EACH ROW
    EXECUTE FUNCTION UpdateUpdatedAtColumn();

CREATE TRIGGER TR_Worksheets_UpdatedAt
    BEFORE UPDATE ON Worksheets
    FOR EACH ROW
    EXECUTE FUNCTION UpdateUpdatedAtColumn();

-- Add constraints
ALTER TABLE WorksheetProblems
    ADD CONSTRAINT CK_WorksheetProblems_ProblemOrder 
    CHECK (ProblemOrder > 0);

