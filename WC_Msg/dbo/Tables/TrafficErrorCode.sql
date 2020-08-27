CREATE TABLE [dbo].[TrafficErrorCode] (
    [RouteID]            VARCHAR (50)  NOT NULL,
    [SupplierErrorCode]  VARCHAR (50)  NOT NULL,
    [SupplierReasonCode] VARCHAR (500) NOT NULL,
    [WavecellErrorCode]  VARCHAR (50)  NOT NULL,
    [WavecellReasonCode] VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_TrafficErrorCode] PRIMARY KEY CLUSTERED ([RouteID] ASC, [SupplierErrorCode] ASC)
);


GO


-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-02-02
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [dbo].[TrafficErrorCode_DataChanged]
   ON  [dbo].[TrafficErrorCode]
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'dbo.TrafficErrorCode'
END
