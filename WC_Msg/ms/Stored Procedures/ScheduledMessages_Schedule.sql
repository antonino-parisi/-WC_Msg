-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2018-03-02
-- Description:	Schedule MT message
-- =============================================
CREATE PROCEDURE [ms].[ScheduledMessages_Schedule]
	@Umid uniqueidentifier,
	@SubAccountUid int,
	@Msisdn bigint,
	@Source varchar(20),
	@Body nvarchar(1600),
	@Dcs tinyint,
	@CreatedAt datetime2(2),
	@ScheduledAt datetime2(2),
	@ExpiryAt datetime2(2) NULL,
	@BatchId uniqueidentifier NULL,
	@ClientMessageId varchar(50) NULL,
	@ClientBatchId varchar(50) NULL
AS
BEGIN
	INSERT INTO sms.SmsMtScheduled 
		(Umid, SubAccountUid, MSISDN, Source, Body, DCS, CreatedAt, ScheduledAt, ExpiryAt, BatchId, ClientMessageId, ClientBatchId) 
	VALUES (@Umid, @SubAccountUid, @Msisdn, @Source, @Body, @Dcs, @CreatedAt, @ScheduledAt, @ExpiryAt, @BatchId, @ClientMessageId, @ClientBatchId)
END
