CREATE TABLE [rt].[RoutingTierConditionDR] (
    [RoutingTierConditionId]  INT      NOT NULL,
    [DrRateThreshold]         TINYINT  CONSTRAINT [DF_RoutingTierConditionDR_DrRateThreshold] DEFAULT ((10)) NOT NULL,
    [DrLatencyThresholdInMin] SMALLINT NULL,
    [TimeframeInMin]          SMALLINT CONSTRAINT [DF_RoutingTierConditionDR_TimeframeInMin] DEFAULT ((30)) NOT NULL,
    [MinSmsVolume]            INT      CONSTRAINT [DF_RoutingTierConditionDR_MinVolume] DEFAULT ((1000)) NOT NULL,
    CONSTRAINT [PK_RoutingTierConditionDR] PRIMARY KEY CLUSTERED ([RoutingTierConditionId] ASC),
    CONSTRAINT [FK_RoutingTierConditionDR_RoutingTierCondition] FOREIGN KEY ([RoutingTierConditionId]) REFERENCES [rt].[RoutingTierCondition] ([RoutingTierConditionId])
);

