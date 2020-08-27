CREATE TABLE [rt].[ChangeEvent] (
    [EventId]         INT             IDENTITY (1, 1) NOT NULL,
    [CreatedAt]       DATETIME2 (2)   CONSTRAINT [DF_ChangeEvent_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [EventTypeId]     TINYINT         NOT NULL,
    [RoutingPlanId]   INT             NULL,
    [PricingPlanId]   INT             NULL,
    [CustomerGroupId] INT             NULL,
    [Countries]       VARCHAR (100)   NULL,
    [EventSummary]    NVARCHAR (4000) NULL,
    [EventData]       NVARCHAR (MAX)  NOT NULL,
    [CreatedBy]       SMALLINT        NOT NULL,
    [EventNotes]      NVARCHAR (4000) NULL,
    CONSTRAINT [PK_ChangeEvent_EventId] PRIMARY KEY NONCLUSTERED ([EventId] ASC),
    CONSTRAINT [FK_ChangeEvent_ChangeEventType] FOREIGN KEY ([EventTypeId]) REFERENCES [rt].[ChangeEventType] ([EventTypeId])
);


GO
CREATE CLUSTERED INDEX [IX_ChangeEvent_Clustered_CreatedAt]
    ON [rt].[ChangeEvent]([CreatedAt] ASC);

