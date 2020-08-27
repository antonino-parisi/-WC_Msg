CREATE TABLE [sms].[DimSmsStatus] (
    [StatusId]          TINYINT      NOT NULL,
    [Status]            VARCHAR (20) NOT NULL,
    [Level]             TINYINT      NOT NULL,
    [Final]             BIT          NOT NULL,
    [StatusOld]         VARCHAR (30) NOT NULL,
    [ShortenStatusId]   TINYINT      NOT NULL,
    [ShortenStatusName] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_DimSmsStatus] PRIMARY KEY CLUSTERED ([StatusId] ASC),
    CONSTRAINT [UIX_DimSmsStatus_Status] UNIQUE NONCLUSTERED ([Status] ASC),
    CONSTRAINT [UIX_DimSmsStatus_StatusOld] UNIQUE NONCLUSTERED ([StatusOld] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DimSmsStatus_ShortenStatusId_StatusId]
    ON [sms].[DimSmsStatus]([ShortenStatusId] ASC, [StatusId] ASC);

