CREATE TABLE [rt].[RoutingTierConditionBind] (
    [RoutingTierConditionId] INT NOT NULL,
    [DowntimeThresholdInSec] INT CONSTRAINT [DF_RoutingTierConditionBind_DowntimeThresholdInSec] DEFAULT ((30)) NOT NULL,
    [QueueSizeMax]           INT CONSTRAINT [DF_RoutingTierConditionBind_QueueSizeMax] DEFAULT ((99999)) NULL,
    CONSTRAINT [PK_RoutingTierConditionBind] PRIMARY KEY CLUSTERED ([RoutingTierConditionId] ASC),
    CONSTRAINT [FK_RoutingTierConditionBind_RoutingTierCondition] FOREIGN KEY ([RoutingTierConditionId]) REFERENCES [rt].[RoutingTierCondition] ([RoutingTierConditionId])
);

