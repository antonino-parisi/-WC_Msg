-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-17
-- Description:	Insert of IPM record !!!! critical part of platform !!!
-- =============================================
CREATE PROCEDURE [sms].[IpmLog_Insert]
	@UMID uniqueidentifier,
    @ChannelUid tinyint,
    @SubAccountUid int,
	@ChannelId UNIQUEIDENTIFIER = NULL,
    @Direction bit,
    @Step tinyint,
    @StatusId tinyint,
    @Country char(2),
    @MSISDN bigint,
    @ChannelUserId varchar(50) = NULL,
    @ContentTypeId tinyint,
    @Content nvarchar(1600),
    @CreatedAt datetime2(2) = NULL,
    @ConnMessageId varchar(50) = NULL,
    @ConnErrorCode varchar(20) = NULL,
	@Cost decimal(12,6) = NULL,
    @CostCurrency char(3) = 'EUR',
    @Price decimal(12,6) = NULL,
    @PriceCurrency char(3) = 'EUR',
    @ChannelCost decimal(12,6) = NULL,
    @ChannelCostContract decimal(12,6) = NULL,
    @MessageFee decimal(12,6) = NULL,
    @MessageFeeContract decimal(12,6) = NULL,
    @ContractCurrency char(3) = 'EUR',
    @ClientMessageId varchar(50) = NULL,
    @ClientBatchId varchar(50) = NULL,
    @BatchId uniqueidentifier = NULL,
    @DlrCallbackUrl varchar(2000) = NULL
AS
BEGIN
	DECLARE @InitSession BIT = 1 ;

	SET NOCOUNT ON;

	IF (@CreatedAt IS NULL) SET @CreatedAt = SYSUTCDATETIME()

	BEGIN TRY

		IF @Direction = 1
			SELECT @InitSession = 0
			FROM sms.IpmLog WITH (NOLOCK)
			WHERE
				SubAccountUid = @SubAccountUid
				AND CreatedAt >= DATEADD(hour, -24, @CreatedAt)
				--AND CreatedAt <= @CreatedAt
				AND MSISDN = @MSISDN
				AND ChannelUid = @ChannelUid
				AND Direction = 0;

		INSERT INTO sms.IpmLog
           (UMID
           ,ChannelUid
           ,SubAccountUid
		   ,ChannelId
           ,Direction
           ,Step
           ,StatusId
           ,Country
           ,MSISDN
           ,ChannelUserId
           ,ContentTypeId
           ,Content
           ,CreatedAt
           ,UpdatedAt
           ,ConnMessageId
           ,ConnErrorCode
           ,ChannelCostEUR
           ,MessageFeeEUR
           ,ChannelCostContract
           ,MessageFeeContract
           ,ContractCurrency
           ,ClientMessageId
           ,ClientBatchId
           ,BatchId
		   ,InitSession)
		VALUES
           (@UMID
           ,@ChannelUid
           ,@SubAccountUid
		   ,@ChannelId
           ,@Direction
           ,@Step
           ,@StatusId
           ,@Country
           ,@MSISDN
           ,@ChannelUserId
           ,@ContentTypeId
           ,@Content
           ,@CreatedAt
           ,SYSUTCDATETIME()
           ,@ConnMessageId
           ,@ConnErrorCode
           ,@ChannelCost
           ,@MessageFee
           ,@ChannelCostContract
           ,@MessageFeeContract
           ,@ContractCurrency
           ,@ClientMessageId
           ,@ClientBatchId
           ,@BatchId
		   ,@InitSession) ;
	
		-- DR callback
		IF (@DlrCallbackUrl IS NOT NULL)
		BEGIN
			INSERT INTO sms.SmsCallbackCache (UMID, CallbackUrl)
			VALUES (@UMID, @DlrCallbackUrl)
		END

	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()

		INSERT INTO sms.Error (dt, [Source], UMID, [Message], Host)
		VALUES (GETUTCDATE(), 'IpmLog_Insert', @UMID, ERROR_MESSAGE(), HOST_NAME())

		-- select top 1000 * from sms.Error order by id desc
	END CATCH
END
