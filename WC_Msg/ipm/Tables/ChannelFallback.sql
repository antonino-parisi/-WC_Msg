CREATE TABLE [ipm].[ChannelFallback] (
    [FallbackId]       INT              IDENTITY (1, 1) NOT NULL,
    [SubAccountUid]    INT              NOT NULL,
    [Priority]         TINYINT          NOT NULL,
    [FallbackDelaySec] INT              CONSTRAINT [DF_ChannelFallback_FallbackDelaySec] DEFAULT ((60)) NOT NULL,
    [SuccessStatus]    INT              CONSTRAINT [DF_ChannelFallback_SuccessStatus] DEFAULT ((0)) NOT NULL,
    [IsForRent]        BIT              CONSTRAINT [DF_ChannelFallback_IsForRent] DEFAULT ((0)) NOT NULL,
    [IsTrial]          BIT              CONSTRAINT [DF_ChannelFallback_IsTrial] DEFAULT ((0)) NOT NULL,
    [ChannelId]        UNIQUEIDENTIFIER NOT NULL,
    [SkipFallback]     BIT              CONSTRAINT [DF_ChannelFallback_ExcludeFromFallback] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ChannelFallback] PRIMARY KEY CLUSTERED ([FallbackId] ASC),
    CONSTRAINT [CK_ChannelFallback_IsForRent] CHECK ([IsForRent]=(0) OR [IsForRent]=(1) AND [IsTrial]=(0)),
    CONSTRAINT [FK_ChannelFallback_Channel] FOREIGN KEY ([ChannelId]) REFERENCES [ipm].[Channel] ([ChannelId]),
    CONSTRAINT [FK_ChannelFallback_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ChannelFallback_SubAccountUid_Priority]
    ON [ipm].[ChannelFallback]([SubAccountUid] ASC, [Priority] ASC);


GO
-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-01-16
-- Description:	Simple DB dependancy logic
-- =============================================
CREATE TRIGGER [ipm].[ChannelFallback_DataChanged]
   ON  ipm.ChannelFallback
   AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ipm.ChannelFallback'
END
