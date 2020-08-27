CREATE TABLE [dbo].[MessageStatusByDays] (
    [date]               DATE NOT NULL,
    [Trashed]            INT  NOT NULL,
    [Notsent]            INT  NOT NULL,
    [deliveredToCarrier] INT  NOT NULL,
    [RejectedByCarrier]  INT  NOT NULL,
    [DeliveredtoDevice]  INT  NOT NULL,
    [Sent]               INT  NOT NULL,
    CONSTRAINT [PK_MessageStatusByDays] PRIMARY KEY CLUSTERED ([date] ASC)
);

