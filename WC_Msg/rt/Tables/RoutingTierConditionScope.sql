CREATE TABLE [rt].[RoutingTierConditionScope] (
    [ConditionScopeId]   TINYINT      NOT NULL,
    [ConditionScopeName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RoutingTierConditionScope] PRIMARY KEY CLUSTERED ([ConditionScopeId] ASC)
);

