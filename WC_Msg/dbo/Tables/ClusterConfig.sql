CREATE TABLE [dbo].[ClusterConfig] (
    [NodeAddress]          VARCHAR (50)    NOT NULL,
    [Status]               VARCHAR (50)    NULL,
    [Lead]                 BIT             NOT NULL,
    [KeepAlive]            INT             NOT NULL,
    [NodeName]             VARCHAR (100)   NOT NULL,
    [wwwCommandQueue]      NVARCHAR (1000) NULL,
    [msCommandQueue]       NVARCHAR (1000) NULL,
    [lastConnection]       DATETIME        NULL,
    [configurationChanged] BIT             CONSTRAINT [DF_ClusterConfig_configurationChanged] DEFAULT ((0)) NOT NULL
);

