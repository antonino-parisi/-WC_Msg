CREATE TABLE [morph].[RoutingRuleFallback] (
    [FallbackRuleId]  INT          IDENTITY (1, 1) NOT NULL,
    [SubRuleId]       INT          NOT NULL,
    [FallbackRouteId] VARCHAR (50) NOT NULL,
    [Priority]        TINYINT      NOT NULL,
    CONSTRAINT [PK_morphRoutingRuleFallback] PRIMARY KEY CLUSTERED ([FallbackRuleId] ASC),
    CONSTRAINT [FK_morphRoutingRuleFallback_RoutingRule] FOREIGN KEY ([SubRuleId]) REFERENCES [morph].[RoutingRule] ([SubRuleId]),
    CONSTRAINT [IX_morphRoutingRuleFallback_Unique] UNIQUE NONCLUSTERED ([SubRuleId] ASC, [FallbackRouteId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER morph.RoutingRuleFallback_DataChanged
   ON  morph.RoutingRuleFallback
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	EXEC ms.DbDependency_DataChanged @Key = 'morph.Routing'
END
