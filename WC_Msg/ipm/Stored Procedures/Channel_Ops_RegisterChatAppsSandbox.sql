-- =============================================
-- Author:		Igor Valyansky
-- Create date: 2020-05-13
-- Description:	Register ChatApps Sandbox
-- =============================================
-- EXEC ipm.Channel_Ops_RegisterChatAppsSandbox 'core_ipm_whatsapp'
-- EXEC ipm.Channel_Ops_RegisterChatAppsSandbox 'core_ipm_whatsapp', 'WhatsApp'
-- EXEC ipm.Channel_Ops_RegisterChatAppsSandbox 'core_ipm_whatsapp', 'Viber'
CREATE PROCEDURE [ipm].[Channel_Ops_RegisterChatAppsSandbox]
	@SubAccountId varchar(50),
	@ChannelType varchar(50) = 'WhatsApp'
AS
BEGIN
	
	-- DECLARE @ChannelType varchar(50) = 'WhatsApp'
	DECLARE @sandboxChannelId uniqueidentifier;
	SELECT @sandboxChannelId = c.ChannelId
	FROM ipm.ChannelFallback AS cf
		INNER JOIN ipm.Channel AS c ON cf.ChannelId = c.ChannelId
		INNER JOIN ipm.ChannelType AS ct ON c.ChannelType = ct.ChannelType
	WHERE ct.ChannelTypeName = @ChannelType AND cf.IsForRent = 1;

	IF (@sandboxChannelId IS NULL)
	BEGIN
		PRINT 'Sandbox is not found'
		RETURN;
	END

	DECLARE @SubAccountUid INT;
	SELECT TOP 1 @SubAccountUid = SubAccountUid FROM ms.SubAccount WHERE SubAccountId = @subAccountId;
	IF (@SubAccountUid IS NULL)
	BEGIN
		PRINT 'Invalid SubAccountId'
		RETURN;
	END

	DECLARE @Priority INT = 10;
	DECLARE @SuccessStatus INT = 40;
	DECLARE @FallbackDelaySec INT = 60;
	DECLARE @isTrial BIT = 1 -- set demo account

	IF NOT EXISTS (
		SELECT FallbackId 
		FROM ipm.ChannelFallback 
		WHERE ChannelId = @sandboxChannelId AND SubAccountUid = @SubAccountUid
	)
	BEGIN
		PRINT 'Add Channel configuration'

		EXEC ipm.ChannelFallback_Add @SubAccountUid, @Priority, 
			@SuccessStatus, @FallbackDelaySec, @isTrial, @sandboxChannelId;

	END
	ELSE
	BEGIN
		PRINT 'Update Channel configuration'

		DECLARE @FallbackId INT;
		SELECT @FallbackId = FallbackId 
		FROM ipm.ChannelFallback 
		WHERE ChannelId = @sandboxChannelId AND SubAccountUid = @SubAccountUid;

		EXEC ipm.ChannelFallback_Update @FallbackId, @SubAccountUid, @Priority, 
			@SuccessStatus, @FallbackDelaySec, @isTrial, @sandboxChannelId;

	END

	-- following lines commented, as it same code executes within EXEC ipm.ChannelFallback_Add
	--UPDATE ms.SubAccount SET Product_CA = 1 WHERE SubAccountUid = @SubAccountUid;
	--INSERT INTO ipm.PricingPlanSubAccount (SubAccountUid, PeriodStart, PeriodEnd, PricingPlanId)
	--	VALUES (@SubAccountUid, SYSUTCDATETIME(), '9999-12-31', 19 /*@Default PricingPlanId*/)

	SELECT 
		f.FallbackId, a.AccountId, a.SubAccountId, a.SubAccountUid, 
		t.ChannelTypeName AS ChannelType,
		st.[Status] AS ChannelStatus,
		f.[Priority], f.FallbackDelaySec, 
		f.SuccessStatus, 
		f.IsForRent, f.IsTrial
	FROM ipm.ChannelFallback f
		INNER JOIN ms.vwSubAccount a on f.SubAccountUid = a.SubAccountUid
		INNER JOIN ipm.Channel ch ON ch.ChannelId = f.ChannelId
		INNER JOIN ipm.ChannelStatus st ON ch.StatusId = st.StatusId
		INNER JOIN ipm.ChannelType t ON ch.ChannelType = t.ChannelType
	WHERE f.SubAccountUid = @SubAccountUid;
	
END
