-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2019-11-04
-- Description:	Get IPM MO records for Status Update
-- =============================================
CREATE PROCEDURE [sms].[IpmLog_GetMo]
	@SubAccountUid int,
	@CreatedAtMax datetime2(2), 
	@CreatedAtMin datetime2(2), 
	@UMID uniqueidentifier = NULL,
	@MSISDN bigint = NULL,
	@ConnMessageId varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @UMID IS NOT NULL
	BEGIN
		SELECT 
			l1.UMID, 
			l1.ChannelUid AS ChannelType,
			l1.ChannelId,
			l1.MSISDN,
			l1.ChannelUserId,
			l1.CreatedAt,
			l1.ConnMessageId	
		FROM sms.IpmLog l1 WITH (NOLOCK)
			INNER JOIN sms.IpmLog l2 WITH (NOLOCK) ON 
				l1.MSISDN = l2.MSISDN AND 
				l1.ChannelUserId = l2.ChannelUserId AND
				l1.SubAccountUid = l2.SubAccountUid AND 
				l1.Direction = l2.Direction
		WHERE l2.UMID = @UMID AND 
			l2.SubAccountUid = @SubAccountUid AND
			l2.Direction = 0 AND
			l1.CreatedAt >= @CreatedAtMin AND 
			l1.CreatedAt < @CreatedAtMax
	END
	ELSE IF (@MSISDN IS NOT NULL)
	BEGIN		
		SELECT 
			UMID, 
			ChannelUid AS ChannelType,
			ChannelId,
			MSISDN,
			ChannelUserId,
			CreatedAt,
			ConnMessageId
		FROM sms.IpmLog WITH (NOLOCK)
		WHERE SubAccountUid = @SubAccountUid AND
			CreatedAt >= @CreatedAtMin AND 
			CreatedAt < @CreatedAtMax AND
			MSISDN = @MSISDN AND
			Direction = 0
	END
	ELSE IF (@ConnMessageId IS NOT NULL)
	BEGIN		
		SELECT 
			UMID, 
			ChannelUid AS ChannelType,
			ChannelId,
			MSISDN,
			ChannelUserId,
			CreatedAt,
			ConnMessageId
		FROM sms.IpmLog WITH (NOLOCK)
		WHERE SubAccountUid = @SubAccountUid AND
			CreatedAt >= @CreatedAtMin AND 
			CreatedAt < @CreatedAtMax AND
			ConnMessageId = @ConnMessageId AND
			Direction = 0
	END
END
