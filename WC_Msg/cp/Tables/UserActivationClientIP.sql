CREATE TABLE [cp].[UserActivationClientIP] (
    [AttemptDate] DATE         NOT NULL,
    [ClientIP]    VARCHAR (50) NOT NULL,
    [Attempt]     TINYINT      CONSTRAINT [DF_UserActivationClientIP_Attempt] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_UserActivationClientIP] PRIMARY KEY CLUSTERED ([AttemptDate] ASC, [ClientIP] ASC)
);

