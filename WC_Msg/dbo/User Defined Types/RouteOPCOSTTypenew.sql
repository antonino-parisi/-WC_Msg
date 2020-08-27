CREATE TYPE [dbo].[RouteOPCOSTTypenew] AS TABLE (
    [Operator]    NVARCHAR (50)   NULL,
    [Cost]        DECIMAL (18, 5) NOT NULL,
    [RouteId]     NVARCHAR (50)   NULL,
    [RouteStatus] VARCHAR (50)    NULL);

