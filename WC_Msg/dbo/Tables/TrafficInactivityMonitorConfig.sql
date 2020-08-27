CREATE TABLE [dbo].[TrafficInactivityMonitorConfig] (
    [SourceOrDestination]  NVARCHAR (50) NOT NULL,
    [ItemType]             VARCHAR (50)  NOT NULL,
    [MessageTypeToMonitor] VARCHAR (50)  NOT NULL,
    [InactivityAlertTime]  INT           NOT NULL
);

