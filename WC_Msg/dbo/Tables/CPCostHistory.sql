CREATE TABLE [dbo].[CPCostHistory] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [ChangedBy]   [sysname]       NOT NULL,
    [Action]      VARCHAR (50)    NOT NULL,
    [ChangedDate] DATETIME        NOT NULL,
    [Operator]    NVARCHAR (50)   NOT NULL,
    [RouteId]     NVARCHAR (50)   NOT NULL,
    [Cost]        DECIMAL (18, 5) NOT NULL,
    [Active]      BIT             NOT NULL,
    CONSTRAINT [PK_CPCostHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);

