CREATE TYPE [dbo].[RouteOPCOSTType] AS TABLE (
    [Operator] NVARCHAR (50)   NULL,
    [Cost]     DECIMAL (18, 5) NOT NULL,
    [RouteId]  NVARCHAR (50)   NULL);

