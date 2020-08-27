-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2018-05-24
-- Description:	Update of IPM record !!!! critical part of platform !!!
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------
-- 03/04/2019  Rebecca  Added portion to insert changes to ipm.IpmLog_ChangeLog

CREATE PROCEDURE [sms].[IpmLog_Update]
	@UMID uniqueidentifier,		-- filter
	@ChannelUid tinyint,			-- filter
	@ChannelId uniqueidentifier = NULL, -- TODO: will be replaced to mandatory field, after full MessageSphere deployment
	@DeliveredAt datetime2(2) = NULL,	-- only non-NULL value will be saved
	@ReadAt datetime2(2) = NULL,			-- only non-NULL value will be saved
	@StatusId int,
	@ChannelUserId varchar(50) = NULL,
	@ConnMessageId varchar(50) = NULL,
	@ChannelCost decimal(12,6),
	@ChannelCostContract decimal(12,6),
	@ConnErrorCode varchar(20) = NULL,
	@MessageFee decimal(12,6),
	@MessageFeeContract decimal(12,6),
	@ContractCurrency char(3) = NULL
AS
BEGIN
	DECLARE @timestamp datetime = GETUTCDATE() ;
	DECLARE @tab table
		(UMID uniqueidentifier,
		SubAccountUid int,
		Country char(2),
		ChannelUid tinyint,
		Direction tinyint,
		InitSession bit,
		OldStatusId tinyint,
		NewStatusId tinyint,
		CreatedAt datetime,
		UpdatedAt datetime
		) ;

	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE sms.IpmLog
		SET DeliveredAt = ISNULL(@DeliveredAt, DeliveredAt),
			ReadAt = ISNULL(@ReadAt, ReadAt),
			StatusId = @StatusId,
			ChannelUserId = ISNULL(@ChannelUserId, ChannelUserId),
			ConnMessageId = ISNULL(@ConnMessageId, ConnMessageId),
			ConnErrorCode = ISNULL(@ConnErrorCode, ConnErrorCode),
			ChannelCostEUR += @ChannelCost,
			ChannelCostContract += @ChannelCostContract,
			MessageFeeEUR += @MessageFee,
			MessageFeeContract += @MessageFeeContract,
			UpdatedAt = SYSUTCDATETIME()
		OUTPUT INSERTED.UMID, INSERTED.SubAccountUid, INSERTED.Country,
				INSERTED.ChannelUid, INSERTED.Direction, INSERTED.InitSession,
				DELETED.StatusId, INSERTED.StatusId, INSERTED.CreatedAt,
				INSERTED.UpdatedAt
		INTO @tab 
		WHERE UMID = @UMID 
			AND (
				(@ChannelId IS NOT NULL AND ChannelId IS NOT NULL AND ChannelId = @ChannelId) -- (ChannelId = @ChannelId) will be permanent condition
				OR (ChannelUid = @ChannelUid) -- temporal condition untill channellId will not be fully deployed
			)
			AND (@ContractCurrency IS NULL OR (ContractCurrency IS NOT NULL AND ContractCurrency = @ContractCurrency))

		IF @@ROWCOUNT = 0
		  THROW 50001, 'Cannot update record: Record not found or has different contract currency', 1

	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()

		INSERT INTO sms.Error (dt, [Source], UMID, [Message], Host)
		VALUES (GETUTCDATE(), 'IpmLog_Update', @UMID, ERROR_MESSAGE(), HOST_NAME())

		-- select top 1000 * from sms.Error order by id desc
	END CATCH

	-- Below code is to capture changes to ipm.IpmLog_ChangeLog for incremental aggregation
	INSERT INTO ipm.IpmLog_ChangeLog
		(UMID, SubAccountUid, Country, ChannelUid, Direction, InitSession,
		OldStatusId, NewStatusId, CreatedAt, UpdatedAt)
	SELECT UMID, SubAccountUid, Country, ChannelUid, Direction, InitSession,
		OldStatusId, NewStatusId, CreatedAt, UpdatedAt
	FROM @tab
	WHERE OldStatusId < NewStatusId ;

END
