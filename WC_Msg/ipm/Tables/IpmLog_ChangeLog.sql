CREATE TABLE [ipm].[IpmLog_ChangeLog] (
    [UMID]          UNIQUEIDENTIFIER NULL,
    [SubAccountUid] INT              NULL,
    [Country]       CHAR (2)         NULL,
    [ChannelUid]    TINYINT          NULL,
    [Direction]     TINYINT          NULL,
    [InitSession]   BIT              NULL,
    [OldStatusId]   TINYINT          NULL,
    [NewStatusId]   TINYINT          NULL,
    [CreatedAt]     DATETIME         NULL,
    [UpdatedAt]     DATETIME2 (2)    NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_ChangeLog_UMID]
    ON [ipm].[IpmLog_ChangeLog]([UMID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_IpmLog_ChangeLog_CreatedAt]
    ON [ipm].[IpmLog_ChangeLog]([CreatedAt] ASC);

