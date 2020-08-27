CREATE TABLE [morph].[Routing] (
    [RuleId]              INT          IDENTITY (1, 1) NOT NULL,
    [SubAccountId]        VARCHAR (50) NOT NULL,
    [Country]             CHAR (2)     NULL,
    [OperatorId]          INT          NULL,
    [IsActiveRoute]       BIT          NOT NULL,
    [RouteStrategy]       TINYINT      CONSTRAINT [DF_morph_Routing_RouteStrategy] DEFAULT ((1)) NOT NULL,
    [Currency]            CHAR (3)     NOT NULL,
    [Price]               REAL         NOT NULL,
    [UseCheapestRoute]    BIT          CONSTRAINT [DF_morph_Routing_UseCheapestRoute] DEFAULT ((1)) NOT NULL,
    [DataSourceId]        TINYINT      CONSTRAINT [DF_morph_Routing_Source] DEFAULT ((2)) NOT NULL,
    [CreatedTimeUtc]      DATETIME     CONSTRAINT [DF_morph_Routing_CreatedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [LastModifiedTimeUtc] DATETIME     CONSTRAINT [DF_morph_Routing_LastModifiedTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_morph_Routing] PRIMARY KEY CLUSTERED ([RuleId] ASC),
    CONSTRAINT [FK_morph_Routing_Operator] FOREIGN KEY ([OperatorId]) REFERENCES [mno].[Operator] ([OperatorId]),
    CONSTRAINT [IX_morph_Routing_Unique] UNIQUE NONCLUSTERED ([SubAccountId] ASC, [Country] ASC, [OperatorId] ASC)
);


GO

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER morph.Routing_DataChanged
   ON  morph.Routing
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	EXEC ms.DbDependency_DataChanged @Key = 'morph.Routing'
END

