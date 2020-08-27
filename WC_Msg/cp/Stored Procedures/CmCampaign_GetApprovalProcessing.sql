
-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-06-14
-- Description:	Get campaigns waiting for approval
-- =============================================
-- EXEC cp.CmCampaign_GetApprovalProcessing @AccountId='TORINOCORP-6qQ69'

CREATE PROCEDURE [cp].[CmCampaign_GetApprovalProcessing]
	@AccountId varchar(50) = NULL,
	@CampaignId int = NULL
AS
BEGIN
	DECLARE @AccountUid uniqueidentifier ;
	DECLARE @email_tab TABLE (AccountUid uniqueidentifier, EmailList nvarchar(MAX)) ;

	-- IF @AccountId IS NULL AND @CampaignId IS NULL
	-- 	RETURN ;

	IF @AccountId IS NOT NULL
		SELECT @AccountUid = AccountUid
		FROM cp.Account WITH (NOLOCK)
		WHERE AccountId = @AccountId ;

	WITH t AS
		(SELECT DISTINCT AccountUid, [Login], COUNT(1) OVER (PARTITION BY AccountUid) Total,
				COUNT(1) OVER (PARTITION BY AccountUid ORDER BY [Login]) rownum			
		FROM
			(SELECT DISTINCT c.AccountUid, u.[Login]
			FROM cp.CmCampaign c WITH (NOLOCK) JOIN cp.[User] u WITH (NOLOCK)
				ON c.AccountUid = u.AccountUid
			WHERE c.CampaignStatusId = 6 /* waiting approval */
				AND (@AccountUid IS NULL OR c.AccountUid = @AccountUid)
				AND (@CampaignId IS NULL OR c.CampaignId = @CampaignId)
				AND u.UserStatus = 'A'
				AND u.DeletedAt IS NULL
				AND u.AccessLevel = 'A'	
				AND (c.ApprovalDeadlineAt IS NULL OR (c.ApprovalDeadlineAt < DATEADD(MINUTE, 60, GETUTCDATE()) AND c.ApprovalDeadlineAt > GETUTCDATE()))
			) A
		)

	INSERT INTO @email_tab
	SELECT DISTINCT AccountUid, (
		SELECT [Login] + CASE WHEN s1.rownum = s1.Total THEN '' ELSE ',' END FROM t s1
		WHERE s1.AccountUid = s2.AccountUid
	FOR XML PATH (''), TYPE).value('(.)[1]','varchar(max)') --value is case-sensitive. Must be lowercase --csvList
	from t s2 ;

	SELECT c.SubAccountId, c.CampaignId, c.CampaignStatusId, c.CampaignName,
            c.AccountUid,
            -- c.CampaignType,
			-- TemplateId, TemplateSenderId, TemplateBody,
            ScheduledAt,
            -- PriceCurrency, Price,
			-- SmsTotal, SmsDelivered, SmsRejected, SmsError, MsgTotal, MsgDelivered, MsgRejected, MsgError,
			-- DeletedAt, DeletedBy,
            ApprovalDeadlineAt, CampaignDetailsUrl, ApprovalDeadlineNotified, RejectionMsg,
			u.[Login], u.Firstname, u.Lastname, u.UserStatus, u.AccessLevel
            -- e.EmailList
	FROM cp.CmCampaign c WITH (NOLOCK)
		LEFT JOIN cp.[User] u WITH (NOLOCK)
			ON c.CreatedBy = u.UserId
		LEFT JOIN @email_tab e
			ON c.AccountUid = e.AccountUid
	WHERE (@AccountUid IS NULL OR c.AccountUid = @AccountUid)
		AND (@CampaignId IS NULL OR CampaignId = @CampaignId)
		AND CampaignStatusId = 6 /* waiting approval */
		AND (ApprovalDeadlineAt IS NULL OR ApprovalDeadlineAt < GETUTCDATE())
	ORDER BY 1, 2 ;

	SELECT c.SubAccountId, c.CampaignId, c.CampaignStatusId, c.CampaignName,
            c.AccountUid,
            -- c.CampaignType,
			-- TemplateId, TemplateSenderId, TemplateBody,
            ScheduledAt,
            -- PriceCurrency, Price,
			-- SmsTotal, SmsDelivered, SmsRejected, SmsError, MsgTotal, MsgDelivered, MsgRejected, MsgError,
			-- DeletedAt, DeletedBy,
            ApprovalDeadlineAt, CampaignDetailsUrl, ApprovalDeadlineNotified, RejectionMsg,
			u.[Login], u.Firstname, u.Lastname, u.UserStatus, u.AccessLevel, e.EmailList
	FROM cp.CmCampaign c WITH (NOLOCK)
		LEFT JOIN cp.[User] u WITH (NOLOCK)
			ON c.CreatedBy = u.UserId
		LEFT JOIN @email_tab e
			ON c.AccountUid = e.AccountUid
	WHERE (@AccountUid IS NULL OR c.AccountUid = @AccountUid)
		AND (@CampaignId IS NULL OR CampaignId = @CampaignId)
		AND CampaignStatusId = 6 /* waiting approval */
		AND (ApprovalDeadlineNotified IS NULL OR ApprovalDeadlineNotified = 0)
		AND (ApprovalDeadlineAt IS NULL
            OR (ApprovalDeadlineAt < DATEADD(MINUTE, 60, GETUTCDATE()) AND ApprovalDeadlineAt > GETUTCDATE())
            )
	ORDER BY 1, 2 ;

END
