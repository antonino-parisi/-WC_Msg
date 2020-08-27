CREATE TABLE [dbo].[CarrierConnections] (
    [RouteId]                      VARCHAR (50)    NOT NULL,
    [RouteUid]                     SMALLINT        IDENTITY (1, 1) NOT NULL,
    [Description]                  NVARCHAR (1000) NULL,
    [ConnectionType]               VARCHAR (50)    NOT NULL,
    [AssemblyName]                 VARCHAR (500)   NOT NULL,
    [ClassName]                    VARCHAR (500)   NOT NULL,
    [Route_MT_Queue]               VARCHAR (500)   NOT NULL,
    [TrashOnConnectionFail]        BIT             NOT NULL,
    [TrashOnMessageFail]           BIT             NOT NULL,
    [ThreadCount]                  INT             NOT NULL,
    [LogFolder]                    VARCHAR (500)   CONSTRAINT [DF_CarrierConnections_LogFolder] DEFAULT ('') NOT NULL,
    [LogLevel]                     INT             CONSTRAINT [DF_CarrierConnections_LogLevel] DEFAULT ((0)) NOT NULL,
    [Active]                       BIT             NOT NULL,
    [StabilityTrigger]             INT             CONSTRAINT [DF_CarrierConnections_StabilityTrigger] DEFAULT ((0)) NOT NULL,
    [info]                         VARCHAR (500)   NULL,
    [Issue]                        VARCHAR (500)   NULL,
    [IsRingtoneSupport]            BIT             CONSTRAINT [DF__CarrierCo__IsRin__18B6AB08] DEFAULT ((0)) NOT NULL,
    [IsOptLogoSupport]             BIT             CONSTRAINT [DF__CarrierCo__IsOpt__19AACF41] DEFAULT ((0)) NOT NULL,
    [IsPictureSupport]             BIT             CONSTRAINT [DF__CarrierCo__IsPic__1A9EF37A] DEFAULT ((0)) NOT NULL,
    [IsUnicodeSupport]             BIT             CONSTRAINT [DF__CarrierCo__IsUni__1B9317B3] DEFAULT ((0)) NOT NULL,
    [IsFlashSupport]               BIT             CONSTRAINT [DF__CarrierCo__IsFla__1C873BEC] DEFAULT ((0)) NOT NULL,
    [IsWapPushSupport]             BIT             CONSTRAINT [DF__CarrierCo__IsWap__1D7B6025] DEFAULT ((0)) NOT NULL,
    [IsConcatenatedMessageSupport] BIT             CONSTRAINT [DF__CarrierCo__IsCon__1E6F845E] DEFAULT ((0)) NOT NULL,
    [UpdatedAt]                    DATETIME2 (2)   CONSTRAINT [DF_CarrierConnections_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Priority]                     TINYINT         CONSTRAINT [DF_CarrierConnections_Priority] DEFAULT ((10)) NOT NULL,
    [BufferSize]                   TINYINT         CONSTRAINT [DF_CarrierConnections_BufferSize] DEFAULT ((50)) NOT NULL,
    [ThrottlingRate]               DECIMAL (5, 2)  CONSTRAINT [DF_CarrierConnections_ThrottlingRate] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CarrierConnections] PRIMARY KEY CLUSTERED ([RouteId] ASC),
    CONSTRAINT [UIX_CarrierConnections_RouteUid] UNIQUE NONCLUSTERED ([RouteUid] ASC)
);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-11-21
-- Description:	Table update tracker trigger
-- =============================================
CREATE TRIGGER [dbo].[CarrierConnections_DataChanged] 
   ON [dbo].[CarrierConnections]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		exec ms.DbDependency_DataChanged @Key = 'dbo.CarrierConnections'
END

GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2017-12-06
-- =============================================
CREATE TRIGGER [dbo].[CarrierConnections_DataUpdated] 
   ON  dbo.CarrierConnections 
   AFTER UPDATE
AS 
BEGIN
	UPDATE f
	SET [UpdatedAt] = SYSUTCDATETIME()
	FROM [dbo].[CarrierConnections] f
		INNER JOIN inserted AS i ON f.RouteId = i.RouteId
END
