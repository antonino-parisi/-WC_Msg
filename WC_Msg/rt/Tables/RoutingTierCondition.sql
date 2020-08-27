CREATE TABLE [rt].[RoutingTierCondition] (
    [RoutingTierConditionId] INT     IDENTITY (1, 1) NOT NULL,
    [RoutingTierId]          INT     NOT NULL,
    [ConditionTypeId]        TINYINT NOT NULL,
    [ConditionScopeId]       TINYINT CONSTRAINT [DF_RoutingTierCondition_ScopeType] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_RoutingTierCondition] PRIMARY KEY CLUSTERED ([RoutingTierConditionId] ASC),
    CONSTRAINT [FK_RoutingTierCondition_RoutingTierConditionScope] FOREIGN KEY ([ConditionScopeId]) REFERENCES [rt].[RoutingTierConditionScope] ([ConditionScopeId]),
    CONSTRAINT [FK_RoutingTierCondition_RoutingTierConditionType] FOREIGN KEY ([ConditionTypeId]) REFERENCES [rt].[RoutingTierConditionType] ([ConditionTypeId])
);

