CREATE TABLE [dbo].[AccountMTConfig] (
    [SubAccountId]         VARCHAR (50)  NOT NULL,
    [DefaultTPOA]          VARCHAR (50)  NULL,
    [ForceTPOA]            BIT           CONSTRAINT [DF_AccountMTConfig_ForceTPOA] DEFAULT ((0)) NOT NULL,
    [DeliveryReportLevel]  INT           NOT NULL,
    [RoutingMethod]        VARCHAR (50)  CONSTRAINT [DF_AccountMTConfig_RoutingMethod] DEFAULT ('not-set') NOT NULL,
    [SmartRetry]           BIT           CONSTRAINT [DF_AccountMTConfig_SmartRetry] DEFAULT ((0)) NOT NULL,
    [SmartRetryExpression] VARCHAR (100) NULL,
    [UseMNOLookup]         BIT           CONSTRAINT [DF_AccountMTConfig_UseMNOLookup] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountMTConfig] PRIMARY KEY CLUSTERED ([SubAccountId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-22
-- Description:	Table update tracker trigger
-- =============================================
CREATE TRIGGER [dbo].[AccountMTConfig_DataChanged] 
   ON dbo.AccountMTConfig
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		exec ms.DbDependency_DataChanged @Key = 'dbo.AccountMTConfig'
END
