CREATE TABLE [rt].[SupplierConn] (
    [ConnUid]              SMALLINT      NOT NULL,
    [ConnId]               VARCHAR (50)  NOT NULL,
    [Deleted]              BIT           CONSTRAINT [DF_SupplierConn_Deleted] DEFAULT ((0)) NOT NULL,
    [IsConnected]          BIT           NOT NULL,
    [UpdatedAt]            DATETIME2 (2) CONSTRAINT [DF_SupplierConn_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UptimeLast1dSum]      INT           CONSTRAINT [DF_SupplierConn_UptimeLast1dSum] DEFAULT ((0)) NOT NULL,
    [UptimeLast7dSum]      INT           CONSTRAINT [DF_SupplierConn_UptimeLast7dSum] DEFAULT ((0)) NOT NULL,
    [UptimeLast30dSum]     INT           CONSTRAINT [DF_SupplierConn_UptimeLast30dSum] DEFAULT ((0)) NOT NULL,
    [QueueSize]            INT           NULL,
    [IsConnectedUpdatedAt] DATETIME2 (2) NULL,
    CONSTRAINT [PK_SupplierConn] PRIMARY KEY CLUSTERED ([ConnUid] ASC),
    CONSTRAINT [UIX_SupplierConn_ConnId] UNIQUE NONCLUSTERED ([ConnId] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-05
-- =============================================
CREATE TRIGGER [rt].[SupplierConn_DataChanged] 
   ON  rt.SupplierConn 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [rt].[SupplierConn] f
		INNER JOIN inserted AS i ON f.ConnUid = i.ConnUid
END
