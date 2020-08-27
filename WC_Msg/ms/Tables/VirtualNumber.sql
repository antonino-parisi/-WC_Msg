CREATE TABLE [ms].[VirtualNumber] (
    [VNId]        INT           IDENTITY (1, 1) NOT NULL,
    [Country]     CHAR (2)      NOT NULL,
    [VN]          BIGINT        NOT NULL,
    [VNType]      CHAR (1)      NOT NULL,
    [Product_SMS] BIT           CONSTRAINT [DF_VirtualNumber_Product_SMS] DEFAULT ((0)) NOT NULL,
    [Product_VO]  BIT           CONSTRAINT [DF_VirtualNumber_Product_VO] DEFAULT ((0)) NOT NULL,
    [Product_MMS] BIT           CONSTRAINT [DF_VirtualNumber_Product_MMS] DEFAULT ((0)) NOT NULL,
    [SMS_ConnUid] INT           NULL,
    [SMS_MTFirst] BIT           CONSTRAINT [DF_VirtualNumber_SMS_MTFirst] DEFAULT ((0)) NULL,
    [AddressReq]  CHAR (1)      CONSTRAINT [DF_VirtualNumber_AddressReq] DEFAULT ('N') NOT NULL,
    [UpdatedAt]   DATETIME2 (2) CONSTRAINT [DF_VirtualNumber_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_VirtualNumber] PRIMARY KEY CLUSTERED ([VNId] ASC),
    CONSTRAINT [CK_VirtualNumber_SMS] CHECK ([Product_SMS]=(1) AND [SMS_ConnUid] IS NOT NULL AND [SMS_MTFirst] IS NOT NULL OR [Product_SMS]=(0)),
    CONSTRAINT [FK_VirtualNumber_Country] FOREIGN KEY ([Country]) REFERENCES [mno].[Country] ([CountryISO2alpha]),
    CONSTRAINT [FK_VirtualNumber_DimVirtualNumberType] FOREIGN KEY ([VNType]) REFERENCES [ms].[DimVirtualNumberType] ([VNType]),
    CONSTRAINT [UIX_VirtualNumber] UNIQUE NONCLUSTERED ([Country] ASC, [VN] ASC)
);


GO
-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2020-04-14
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ms].[VirtualNumber_DataChanged]
   ON  [ms].[VirtualNumber]
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.VirtualNumber'
END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'N - NO, L - Local, G - Global', @level0type = N'SCHEMA', @level0name = N'ms', @level1type = N'TABLE', @level1name = N'VirtualNumber', @level2type = N'COLUMN', @level2name = N'AddressReq';

