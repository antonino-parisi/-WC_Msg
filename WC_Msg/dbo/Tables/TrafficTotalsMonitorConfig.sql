CREATE TABLE [dbo].[TrafficTotalsMonitorConfig] (
    [SubAccountId]         NVARCHAR (50) NOT NULL,
    [MessageTypeToMonitor] VARCHAR (50)  NOT NULL,
    [TotalThreshold]       INT           NOT NULL,
    [SampleTimeInterval]   INT           NOT NULL
);

