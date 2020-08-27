CREATE TABLE [rt].[RoutingTierConditionMargin] (
    [RoutingTierConditionId] INT      NOT NULL,
    [MarginThresholdMin]     TINYINT  CONSTRAINT [DF_RoutingTierConditionMargin_MarginThresholdMin] DEFAULT ((10)) NOT NULL,
    [TimeframeInMin]         SMALLINT CONSTRAINT [DF_RoutingTierConditionMargin_TimeframeInMin] DEFAULT ((30)) NOT NULL,
    CONSTRAINT [PK_RoutingTierConditionMargin] PRIMARY KEY CLUSTERED ([RoutingTierConditionId] ASC),
    CONSTRAINT [FK_RoutingTierConditionMargin_RoutingTierCondition] FOREIGN KEY ([RoutingTierConditionId]) REFERENCES [rt].[RoutingTierCondition] ([RoutingTierConditionId])
);

