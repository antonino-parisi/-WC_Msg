CREATE TABLE [dbo].[StandardAccount] (
    [AccountId]           NVARCHAR (50)  NOT NULL,
    [SubAccountId]        NVARCHAR (50)  NOT NULL,
    [StandardRouteIdName] NVARCHAR (50)  NOT NULL,
    [PricingFormulaName]  NVARCHAR (250) NULL,
    [BlockedRoutes]       NVARCHAR (MAX) NULL,
    [RoutingMode]         NVARCHAR (250) NULL,
    CONSTRAINT [PK_StandardAccount] PRIMARY KEY CLUSTERED ([AccountId] ASC, [SubAccountId] ASC)
);


GO

-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2016-06-01
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[StandardAccount_DataChanged]
   ON  [dbo].[StandardAccount]
   AFTER INSERT, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
	BEGIN
		EXEC ms.DbDependency_DataChanged @Key = 'ms.SubAccount'
		EXEC ms.DbDependency_DataChanged @Key = 'ms.StandardAccount'
	END
END
