CREATE TABLE [sms].[Error] (
    [id]      INT              IDENTITY (1, 1) NOT NULL,
    [dt]      DATETIME         NOT NULL,
    [Source]  VARCHAR (50)     NOT NULL,
    [UMID]    UNIQUEIDENTIFIER NOT NULL,
    [Message] NVARCHAR (500)   NOT NULL,
    [Host]    VARCHAR (50)     NULL,
    CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED ([id] ASC)
);

