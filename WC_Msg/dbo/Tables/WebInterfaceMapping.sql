CREATE TABLE [dbo].[WebInterfaceMapping] (
    [InterfaceName] VARCHAR (50)  NOT NULL,
    [AssemblyName]  VARCHAR (200) NOT NULL,
    [ClassName]     VARCHAR (200) NOT NULL,
    [RouteId]       VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_WebInterfaceMapping] PRIMARY KEY CLUSTERED ([InterfaceName] ASC),
    CONSTRAINT [FK_WebInterfaceMapping_SupplierConn] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CarrierConnections] ([RouteId])
);

