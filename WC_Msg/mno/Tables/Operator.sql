CREATE TABLE [mno].[Operator] (
    [OperatorId]       INT            NOT NULL,
    [CountryISO2alpha] CHAR (2)       NOT NULL,
    [OperatorName]     NVARCHAR (255) NOT NULL,
    [JsonData]         NVARCHAR (MAX) NULL,
    [MCC_Default]      SMALLINT       NOT NULL,
    [MNC_Default]      SMALLINT       NOT NULL,
    [MCC_List]         VARCHAR (50)   NULL,
    [MNC_List]         VARCHAR (200)  NULL,
    [Active]           BIT            CONSTRAINT [DF_mnoOperator_Active] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Operator] PRIMARY KEY CLUSTERED ([OperatorId] ASC),
    CONSTRAINT [CK_mnoOperator_OperatorId] CHECK ([OperatorId]>=(100000) AND [OperatorId]<=(999999)),
    CONSTRAINT [FK_Operator_Country] FOREIGN KEY ([CountryISO2alpha]) REFERENCES [mno].[Country] ([CountryISO2alpha])
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-29
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [mno].[Operator_DataChanged]
   ON  [mno].[Operator]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'mno.Operator'
END
