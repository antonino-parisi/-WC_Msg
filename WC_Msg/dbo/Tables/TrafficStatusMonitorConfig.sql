CREATE TABLE [dbo].[TrafficStatusMonitorConfig] (
    [SubAccountId]          NVARCHAR (50) NOT NULL,
    [SampleTimeInterval]    INT           NOT NULL,
    [RejectedRateThreshold] INT           NOT NULL
);

