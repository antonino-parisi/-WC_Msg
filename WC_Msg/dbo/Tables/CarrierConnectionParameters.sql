CREATE TABLE [dbo].[CarrierConnectionParameters] (
    [RouteId]        NVARCHAR (50)  NOT NULL,
    [ParameterName]  NVARCHAR (50)  NOT NULL,
    [ParameterValue] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_CarrierConnectionParameters] PRIMARY KEY CLUSTERED ([RouteId] ASC, [ParameterName] ASC)
);


GO

-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-21
-- Description:	Table update tracker trigger
-- =============================================
CREATE TRIGGER [dbo].[CarrierConnectionParameters_DataChanged] 
   ON [dbo].[CarrierConnectionParameters]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		exec ms.DbDependency_DataChanged @Key = 'dbo.CarrierConnectionParameters'
END
