CREATE TABLE [morph].[RoutingRule] (
    [SubRuleId]           INT          IDENTITY (1, 1) NOT NULL,
    [RuleId]              INT          NOT NULL,
    [StartTime]           TIME (0)     NOT NULL,
    [EndTime]             TIME (0)     NOT NULL,
    [Weight]              TINYINT      NOT NULL,
    [RouteId]             VARCHAR (50) NOT NULL,
    [RouteId_Fallback]    VARCHAR (50) NULL,
    [CreatedTimeUtc]      DATETIME     CONSTRAINT [DF_morph_RoutingRule_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [LastModifiedTimeUtc] DATETIME     CONSTRAINT [DF_morph_RoutingRule_LastModifiedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_morph_RoutingRule] PRIMARY KEY CLUSTERED ([SubRuleId] ASC),
    CONSTRAINT [CK_morph_RoutingRule_Weight] CHECK ([Weight]>=(0) AND [Weight]<=(100)),
    CONSTRAINT [FK_morph_RoutingRule_RuleId] FOREIGN KEY ([RuleId]) REFERENCES [morph].[Routing] ([RuleId]),
    CONSTRAINT [IX_morph_RoutingRule_Unique] UNIQUE NONCLUSTERED ([RuleId] ASC, [StartTime] ASC, [RouteId] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER morph.RoutingRule_DataChanged
   ON  morph.RoutingRule
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	EXEC ms.DbDependency_DataChanged @Key = 'morph.Routing'
END
