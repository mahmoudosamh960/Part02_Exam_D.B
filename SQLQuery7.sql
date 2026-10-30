Use UniversityResearchSystem

-->Q1
SELECT R.Id, R.FirstName, R.LastName, P.Id AS ProjectId, P.Title
FROM Researcher R
LEFT JOIN WorksOn W ON R.Id = W.ResearcherId
LEFT JOIN ResearchProject P ON W.ProjectId = P.Id;
GO

-->Q2
SELECT P.Id, P.Title,
       CONCAT_WS(' ', R.FirstName, R.MiddleName, R.LastName) AS LeadResearcherName,
       R.Email
FROM ResearchProject P
JOIN Researcher R ON P.LeaderId = R.Id
WHERE EXISTS (
    SELECT 1
    FROM Funds F
    WHERE F.ProjectId = P.Id
);
GO

-->Q3
SELECT R.Id AS ResearcherId, R.FirstName, R.LastName,
       P.Id AS PublicationId, P.Title AS PublicationTitle
FROM Researcher R
CROSS JOIN Publication P;
GO

-->Q4
SELECT S.Id AS SupervisorId,
       CONCAT_WS(' ', S.FirstName, S.MiddleName, S.LastName) AS SupervisorName,
       J.Id AS SuperviseeId,
       CONCAT_WS(' ', J.FirstName, J.MiddleName, J.LastName) AS SuperviseeName,
       SV.SupervisionStartDate, SV.Role
FROM Supervises SV
JOIN Researcher S ON SV.SupervisorId = S.Id
JOIN Researcher J ON SV.SupervisorId = J.Id;
GO

-->Q5
SELECT R.*
FROM Researcher R
WHERE EXISTS (
    SELECT 1
    FROM Publishes PU
    WHERE PU.ResearcherId = R.Id
)
AND NOT EXISTS (
    SELECT 1
    FROM WorksOn W
    JOIN ResearchProject P ON P.Id = W.ProjectId
    WHERE W.ResearcherId = R.Id
      AND P.Status = 'Active'
);
GO

-->Q6
SELECT TOP (5) WITH TIES Id, Title, CitationCount
FROM Publication
ORDER BY CitationCount DESC;
GO

-->Q7
SELECT *
FROM Researcher
ORDER BY LastName, Id
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
GO

-->8
SELECT TOP (3) *
FROM Researcher
ORDER BY LastName, Id;

SELECT *
FROM Researcher
ORDER BY LastName, Id
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;
GO

-->Q9
SELECT Id, FirstName, LastName, Building, DateOfBirth,
       ROW_NUMBER() OVER (
           PARTITION BY Building
           ORDER BY DateOfBirth, Id
       ) AS ResearcherSequence
FROM Researcher;
GO

-->Q10
SELECT Title, Type, CitationCount,
       RANK() OVER (
           PARTITION BY Type
           ORDER BY CitationCount DESC
       ) AS PublicationRank
FROM Publication;
GO

-->Q11
SELECT Id, Title, Budget, Status,
       RANK() OVER (PARTITION BY Status ORDER BY Budget DESC) AS BudgetRank,
       DENSE_RANK() OVER (PARTITION BY Status ORDER BY Budget DESC) AS DenseBudgetRank
FROM ResearchProject;
GO

-->Q12
WITH ResearcherPublications AS (
    SELECT R.Id, R.FirstName, R.LastName,
           COUNT(PU.PublicationId) AS PublicationCount
    FROM Researcher R
    LEFT JOIN Publishes PU ON R.Id = PU.ResearcherId
    GROUP BY R.Id, R.FirstName, R.LastName
)
SELECT Id, FirstName, LastName, PublicationCount,
       NTILE(4) OVER (ORDER BY PublicationCount DESC) AS GroupNumber
FROM ResearcherPublications;
GO

-->Q13
-- FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> TOP / OFFSET-FETCH

-->Q14
SELECT ResearcherId, COUNT(*) AS ProjectCount
FROM WorksOn
GROUP BY ResearcherId
HAVING COUNT(*) > 2;
GO

-->Q15
SELECT CONCAT_WS(' ', FirstName, MiddleName, LastName) AS FullName,
       LOWER(Email) AS Email,
       DATEDIFF(YEAR, DateOfBirth, GETDATE())
       - CASE
           WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateOfBirth, GETDATE()), DateOfBirth) > GETDATE()
           THEN 1 ELSE 0
         END AS Age
FROM Researcher;
GO

-->Q16
SELECT Id, Title, StartDate, EndDate,
       DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE())) AS DurationDays,
       MONTH(StartDate) AS StartMonth,
       YEAR(StartDate) AS StartYear
FROM ResearchProject;
GO

-->Q17
SELECT *
FROM Researcher
WHERE LOWER(Email) LIKE '%@university.edu';
GO

-->Q18
SELECT *,
       ISNULL(MiddleName, 'N/A') AS MiddleNameDisplay,
       ISNULL(CAST(RoomNumber AS VARCHAR(20)), 'N/A') AS RoomNumberDisplay
FROM Researcher;
GO

-->Q19
SELECT Id, Title, Budget,
       CASE
           WHEN Budget < 50000 THEN 'Small'
           WHEN Budget <= 150000 THEN 'Medium'
           ELSE 'Large'
       END AS BudgetCategory
FROM ResearchProject;
GO

-->Q20
SELECT CONCAT_WS(' ', R.FirstName, R.MiddleName, R.LastName) AS FullName,
       SUM(P.Budget) AS TotalBudget
FROM Researcher R
JOIN ResearchProject P ON R.Id = P.LeaderId
GROUP BY R.Id, R.FirstName, R.MiddleName, R.LastName;
GO

-->Q21
SELECT Building, COUNT(*) AS ResearcherCount
FROM Researcher
GROUP BY Building
HAVING COUNT(*) > 3;
GO

-->Q22
SELECT Type,
       AVG(CAST(CitationCount AS DECIMAL(10,2))) AS AverageCitations,
       SUM(CitationCount) AS TotalCitations,
       COUNT(*) AS PublicationCount
FROM Publication
GROUP BY Type
HAVING AVG(CAST(CitationCount AS DECIMAL(10,2))) > 50;
GO

-->Q23
SELECT ResearcherId,
       COUNT(*) AS ProjectCount,
       SUM(HoursPerWeek) AS TotalHours
FROM WorksOn
GROUP BY ResearcherId
HAVING COUNT(*) > 2
   AND SUM(HoursPerWeek) > 60;
GO

-->Q24
SELECT *
FROM ResearchProject
WHERE Budget > (
    SELECT AVG(Budget)
    FROM ResearchProject
);
GO

-->Q25
SELECT R.*
FROM Researcher R
WHERE (
    SELECT COUNT(*)
    FROM Publishes PU
    WHERE PU.ResearcherId = R.Id
) > (
    SELECT AVG(CAST(PublicationCount AS DECIMAL(10,2)))
    FROM (
        SELECT R2.Id, COUNT(PU2.PublicationId) AS PublicationCount
        FROM Researcher R2
        LEFT JOIN Publishes PU2 ON R2.Id = PU2.ResearcherId
        WHERE R2.Building = R.Building
        GROUP BY R2.Id
    ) AS BuildingPublicationCounts
);
GO

-->Q26
SELECT R.*
FROM Researcher R
WHERE EXISTS (
    SELECT 1
    FROM Supervises S
    WHERE S.SupervisorId = R.Id
);
GO

-->Q27
SELECT P.Id, P.Title,
       (
           SELECT COUNT(*)
           FROM WorksOn W
           WHERE W.ProjectId = P.Id
       ) AS ResearcherCount
FROM ResearchProject P;
GO

-->Q28
SELECT MAX(Budget) AS SecondHighestBudget
FROM ResearchProject
WHERE Budget < (
    SELECT MAX(Budget)
    FROM ResearchProject
);
GO

-->Q29
SELECT DISTINCT R.*
FROM Researcher R
JOIN WorksOn W ON W.ResearcherId = R.Id
WHERE NOT EXISTS (
    SELECT 1
    FROM Publishes PU
    WHERE PU.ResearcherId = R.Id
);
GO

-->Q30
SELECT DISTINCT R.*
FROM Researcher R
JOIN Supervises S ON S.SupervisorId = R.Id
JOIN ResearchProject P ON P.LeaderId = R.Id;
GO

-->Q31
CREATE FUNCTION dbo.GetProjectDurationDays (@ProjectId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT;

    SELECT @Duration = DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE()))
    FROM ResearchProject
    WHERE Id = @ProjectId;

    RETURN @Duration;
END;
GO

-->Q32
CREATE FUNCTION dbo.GetResearcherProjects (@ResearcherId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT P.Title AS ProjectTitle, W.Role, W.HoursPerWeek
    FROM WorksOn W
    JOIN ResearchProject P ON P.Id = W.ProjectId
    WHERE W.ResearcherId = @ResearcherId
);
GO

-->Q33
CREATE FUNCTION dbo.GetResearcherStatistics (@ResearcherId INT)
RETURNS @Stats TABLE
(
    TotalProjects INT,
    TotalPublications INT,
    TotalHoursPerWeek INT,
    AverageCitationsPerPublication DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Stats
    SELECT
        (SELECT COUNT(*)
         FROM WorksOn
         WHERE ResearcherId = @ResearcherId),

        (SELECT COUNT(*)
         FROM Publishes
         WHERE ResearcherId = @ResearcherId),

        (SELECT ISNULL(SUM(HoursPerWeek), 0)
         FROM WorksOn
         WHERE ResearcherId = @ResearcherId),

        (SELECT AVG(CAST(P.CitationCount AS DECIMAL(10,2)))
         FROM Publishes PU
         JOIN Publication P ON P.Id = PU.PublicationId
         WHERE PU.ResearcherId = @ResearcherId);

    RETURN;
END;
GO

-->Q34
CREATE NONCLUSTERED INDEX IX_ResearchProject_Status_StartDate
ON ResearchProject (Status, StartDate);
GO

-->Q35
-- Clustered index: determines the physical order of table data;
-- a table can have only one clustered index.
-- Non-clustered index: stores separate index structure with row locators;
-- a table can have multiple non-clustered indexes.
-- Creating a clustered index on a heap converts it into a clustered table.
GO

-->Q36
CREATE NONCLUSTERED INDEX IX_Researcher_Email
ON Researcher (Email)
INCLUDE (FirstName, LastName);
GO

-->Q37
CREATE VIEW ActiveProjectSummary
AS
SELECT
    P.Title AS ProjectTitle,
    CONCAT_WS(' ', R.FirstName, R.MiddleName, R.LastName) AS LeaderName,
    COUNT(DISTINCT W.ResearcherId) AS TeamMembers,
    ISNULL(SUM(W.HoursPerWeek), 0) AS TotalHoursPerWeek,
    P.Budget AS TotalBudget
FROM ResearchProject P
JOIN Researcher R ON R.Id = P.LeaderId
LEFT JOIN WorksOn W ON W.ProjectId = P.Id
WHERE P.Status = 'Active'
GROUP BY P.Id, P.Title, R.FirstName, R.MiddleName, R.LastName, P.Budget;
GO

-->Q38
CREATE VIEW ResearcherPublicationStats
WITH SCHEMABINDING
AS
SELECT
    R.Id AS ResearcherId,
    R.FirstName,
    R.MiddleName,
    R.LastName,
    COUNT_BIG(*) AS TotalPublications
FROM dbo.Researcher R
JOIN dbo.Publishes PU ON PU.ResearcherId = R.Id
GROUP BY R.Id, R.FirstName, R.MiddleName, R.LastName;
GO

CREATE UNIQUE CLUSTERED INDEX IX_ResearcherPublicationStats
ON ResearcherPublicationStats (ResearcherId);
GO

-->Q39
-- Requirements: SCHEMABINDING, deterministic expressions,
-- two-part object names, and COUNT_BIG(*) when GROUP BY is used.
-- Create a unique clustered index first.
-- Benefits: materialized results and faster repeated queries.
-- Choose indexed views for expensive, frequently queried aggregations;
-- use regular views or tables when data changes frequently or flexibility is needed.
GO

-->Q40
CREATE PROCEDURE dbo.AddResearcherToProject
    @ResearcherId INT,
    @ProjectId INT,
    @JoinDate DATE,
    @Role VARCHAR(50),
    @HoursPerWeek INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Researcher WHERE Id = @ResearcherId)
        RETURN 1;

    IF NOT EXISTS (SELECT 1 FROM ResearchProject WHERE Id = @ProjectId)
        RETURN 1;

    IF EXISTS (
        SELECT 1
        FROM WorksOn
        WHERE ResearcherId = @ResearcherId
          AND ProjectId = @ProjectId
    )
        RETURN 1;

    INSERT INTO WorksOn
        (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
    VALUES
        (@ResearcherId, @ProjectId, @JoinDate, @Role, @HoursPerWeek);

    RETURN 0;
END;
GO

-->Q41
CREATE PROCEDURE dbo.UpdateProjectStatus
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM ResearchProject
            WHERE Id = @ProjectId
              AND Status = 'Pending'
        )
            THROW 50001, 'Project does not exist or is not Pending.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM WorksOn WHERE ProjectId = @ProjectId
        )
            THROW 50002, 'Project must have at least one researcher.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM Funds WHERE ProjectId = @ProjectId
        )
            THROW 50003, 'Project must have at least one funding source.', 1;

        UPDATE ResearchProject
        SET Status = 'Active'
        WHERE Id = @ProjectId;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-->Q42
CREATE PROCEDURE dbo.GetResearcherSummary
    @ResearcherId INT,
    @TotalProjects INT OUTPUT,
    @TotalPublications INT OUTPUT,
    @TotalWeeklyHours INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalProjects = COUNT(*)
    FROM WorksOn
    WHERE ResearcherId = @ResearcherId;

    SELECT @TotalPublications = COUNT(*)
    FROM Publishes
    WHERE ResearcherId = @ResearcherId;

    SELECT @TotalWeeklyHours = ISNULL(SUM(HoursPerWeek), 0)
    FROM WorksOn
    WHERE ResearcherId = @ResearcherId;
END;
GO

-->Q43
CREATE TRIGGER dbo.TR_WorksOn_MaxFiveProjects
ON WorksOn
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT I.ResearcherId
        FROM WorksOn W
        JOIN (
            SELECT DISTINCT ResearcherId
            FROM inserted
        ) I ON I.ResearcherId = W.ResearcherId
        GROUP BY I.ResearcherId
        HAVING COUNT(*) > 5
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, 'A researcher cannot work on more than five projects.', 1;
    END;
END;
GO

-->Q44
CREATE TRIGGER dbo.TR_ResearchProject_AutoCompleted
ON ResearchProject
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE P
    SET Status = 'Completed'
    FROM ResearchProject P
    JOIN inserted I ON I.Id = P.Id
    WHERE I.EndDate < CAST(GETDATE() AS DATE)
      AND I.EndDate IS NOT NULL
      AND P.Status <> 'Completed';
END;
GO

-->Q45
CREATE TABLE GrantsAudit (
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    GrantId INT,
    OldAmount DECIMAL(18,2),
    NewAmount DECIMAL(18,2),
    ModifiedBy SYSNAME,
    ModifiedDate DATETIME
);
GO

CREATE TRIGGER TR_Grants_AuditUpdates
ON Grants
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO GrantsAudit
        (GrantId, OldAmount, NewAmount, ModifiedBy, ModifiedDate)
    SELECT
        I.Id,
        D.Amount,
        I.Amount,
        SYSTEM_USER,
        GETDATE()
    FROM inserted I
    JOIN deleted D ON I.Id = D.Id;
END;
GO

-->Q46
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ProjectId INT;
    DECLARE @GrantId INT;
    DECLARE @ResearcherId INT = 1;
    DECLARE @ProjectTitle VARCHAR(200) = 'New Research Project';
    DECLARE @Budget DECIMAL(18,2) = 100000;
    DECLARE @GrantAmount DECIMAL(18,2) = 50000;

    INSERT INTO ResearchProject
        (Title, StartDate, EndDate, Budget, Status, LeadId)
    VALUES
        (@ProjectTitle, GETDATE(), NULL, @Budget, 'Pending', @ResearcherId);

    SET @ProjectId = SCOPE_IDENTITY();

    IF NOT EXISTS (
        SELECT 1 FROM Researcher WHERE Id = @ResearcherId
    )
        THROW 50010, 'Researcher does not exist.', 1;

    INSERT INTO WorksOn
        (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
    VALUES
        (@ResearcherId, @ProjectId, GETDATE(), 'Lead', 10);

    INSERT INTO Grants (Amount)
    VALUES (@GrantAmount);

    SET @GrantId = SCOPE_IDENTITY();

    INSERT INTO Funds (GrantId, ProjectId, AllocationAmount, AllocationDate)
    VALUES (@GrantId, @ProjectId, @GrantAmount, GETDATE());

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-->Q47
-- Atomicity:All project creation steps succeed together or all are rolled back.
-- Consistency:Constraints and rules remain valid after the transaction.
-- Isolation:Concurrent transactions do not see incomplete project creation.
-- Durability:Once committed, the project and its funding persist.
GO

--Q48
--Both queries can return the same researchers.
--EXISTS is often efficient for checking whether a matching row exists.
--IN may also perform equally well because SQL Server can optimize both.
--Performance depends on indexes, statistics, row counts, and the execution plan.
--A useful index:
CREATE NONCLUSTERED INDEX IX_WorksOn_ProjectId_ResearcherId
ON WorksOn (ProjectId, ResearcherId);
GO

-->Q49
--Optimization 1: Index ResearchProject for filtering and ordering.
CREATE NONCLUSTERED INDEX IX_ResearchProject_Status_StartDate
ON ResearchProject (Status, StartDate DESC)
INCLUDE (Id, Title);
GO

--Optimization 2:Index WorksOn for joining by ProjectId.
CREATE NONCLUSTERED INDEX IX_WorksOn_ProjectId
ON WorksOn (ProjectId)
INCLUDE (ResearcherId);
GO

--Optimization 3: Ensure Researcher.Id is a primary key or indexed.
--Optimization 4: Ensure statistics are up to date.
--Optimization 5: Select only required columns and inspect the execution plan.
GO

-->Q50
--Option A: Write the query each time.
--Pros: Always reflects current data; no object maintenance.
--Cons: Repeated code; harder to maintain consistently.

--Option B: Create a view.
--Pros: Reusable query; simplifies reporting; reflects current data.
--Cons: Does not automatically store results or guarantee faster execution.

--Option C: Create a stored procedure.
--Pros: Reusable, supports parameters, can encapsulate logic and permissions.
--Cons: Requires EXECUTE; changes need procedure maintenance.

--Option D: Create an indexed view.
--Pros: Stores indexed results and can improve repeated expensive queries.
--Cons: Extra storage and update overhead; has restrictions and maintenance costs.

--Recommended: A stored procedure for regularly retrieving the top 10
--publications with their authors, using ORDER BY CitationCount DESC.
--Add suitable indexes to support the query. Use an indexed view only if
--workload analysis shows its benefits outweigh maintenance overhead.
GO