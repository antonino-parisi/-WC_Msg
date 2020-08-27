CREATE TABLE [dbo].[NumberingPlan] (
    [Prefix]           VARCHAR (50)   NOT NULL,
    [Country]          NVARCHAR (50)  NOT NULL,
    [OperatorName]     NVARCHAR (100) NOT NULL,
    [CountryCode]      SMALLINT       NOT NULL,
    [ISO-3166-alpha-2] CHAR (2)       NULL,
    [OperatorId]       NVARCHAR (50)  NULL,
    CONSTRAINT [PK_NumberingPlan] PRIMARY KEY CLUSTERED ([Prefix] ASC)
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-08
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[NumberingPlan_DataChanged]
   ON  [dbo].[NumberingPlan]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.NumberingPlan'
END
