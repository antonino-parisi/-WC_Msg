CREATE TABLE [ms].[RateLimits] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [SubAccountUid] INT             NULL,
    [Method]        VARCHAR (10)    NOT NULL,
    [Endpoint]      NVARCHAR (2048) NOT NULL,
    [Period]        VARCHAR (10)    NOT NULL,
    [Limit]         FLOAT (53)      NOT NULL,
    [UpdatedAt]     DATETIME2 (2)   CONSTRAINT [DF_RateLimits_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_RateLimits] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [CK_RateLimits_Method] CHECK ([Method]='DELETE' OR [Method]='PATCH' OR [Method]='PUT' OR [Method]='POST' OR [Method]='HEAD' OR [Method]='GET'),
    CONSTRAINT [FK_RateLimits_SubAccount] FOREIGN KEY ([SubAccountUid]) REFERENCES [ms].[SubAccount] ([SubAccountUid])
);


GO

-- =============================================
-- Author:		Tony Ivanov
-- Create date: 2020-06-15
-- Description:	Update settings trigger
-- =============================================
CREATE TRIGGER [ms].[RateLimits_DataChanged]
   ON  [ms].[RateLimits]
   AFTER INSERT, UPDATE, DELETE
AS
BEGIN

	IF NOT UPDATE(UpdatedAt)
		UPDATE rl
		SET UpdatedAt = SYSUTCDATETIME()
		FROM ms.RateLimits rl
			INNER JOIN inserted AS i ON rl.Id = i.Id

	IF EXISTS (SELECT 1 FROM inserted) OR EXISTS (SELECT 1 FROM deleted)
		EXEC ms.DbDependency_DataChanged @Key = 'ms.RateLimits'
END
