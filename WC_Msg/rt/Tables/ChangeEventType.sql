CREATE TABLE [rt].[ChangeEventType] (
    [EventTypeId] TINYINT      NOT NULL,
    [EventType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ChangeEventType] PRIMARY KEY CLUSTERED ([EventTypeId] ASC)
);

