-- =============================================
-- Author:		Shchekalov Anton
-- Create date: 2017-02-23
-- =============================================
-- EXEC cp.CmCampaign_Create @AccountId='AcmeCorp-0aA4C', ...., @CreatedBy = 'E9BCBF9B-CDC9-4BA6-8C4B-92B41C7F280D'
-- =============================================
-- Change History
-- =============================================
-- Date        Author               Description 
-- ----------  -------------------  ------------------------------------
-- 2019-06-11   Nathanael Hinay     Add CampaignStatusId and other params when saving data
-- 2020-02-04   Raul Torrefiel      Add Price and PriceCurrency params when saving data

CREATE PROCEDURE [cp].[CmCampaign_Create]
	@AccountId varchar(50) = NULL,
	@AccountUid uniqueidentifier = NULL, -- one of @AccountId or @AccountUid must be specified
	@SubAccountId varchar(50),
	@Product varchar(3) = 'SMS',
	@ChannelType char(2) = 'SM',
    @CampaignName nvarchar(100),
	@TemplateBody nvarchar(1600),
	@TemplateSenderId varchar(20),
	@TemplateId int,
	@ScheduledAt datetime2(2),
	@CreatedBy uniqueidentifier,		-- UserId that creates record
    @CampaignStatusId int = 0,
    @CampaignDetailsUrl varchar(300) = NULL,
	@ClientMessageId varchar(50) = NULL,
    @Price decimal(20,7) = 0.0,
    @PriceCurrency char(3) = NULL,
	@CampaignMeta nvarchar(1024) = NULL
AS
BEGIN
	
	SET @AccountUid = cp.fnGetAccountUid(@AccountUid, @AccountId)
	
	DECLARE @SubAccountUid int
	SELECT @SubAccountUid = SubAccountUid FROM dbo.Account WHERE SubAccountId = @SubAccountId
	
	IF @SubAccountUid IS NULL
		THROW 51000, 'Attempt to create campaign with non-existing SubAccountId', 1;  
		
	----------------------------------------------
	-- Logic of defining CampaignType is here. 
	-- Yes, it's hardcoded for simplicity :(. Cause SMS-2-Survey feature is too young yet and changing
	----------------------------------------------
	DECLARE @CampaignType varchar(6) = 'basic'
	IF @TemplateBody LIKE '%smstoweb.net%' SET @CampaignType = 'survey'
	----------------------------------------------

	IF @ScheduledAt < SYSUTCDATETIME() SET @ScheduledAt = SYSUTCDATETIME()

	-- Main insert
	INSERT INTO cp.CmCampaign
           (CampaignStatusId
           ,AccountUid
           ,SubAccountId
		   ,SubAccountUid
		   ,Product
           ,CampaignName
           ,TemplateBody
           ,TemplateSenderId
		   ,TemplateId
		   ,CampaignType
           ,SmsTotal
           ,SmsDelivered
           ,SmsError
		   ,MsgTotal
           ,MsgDelivered
           ,MsgError
           ,ScheduledAt
           ,CreatedAt
           ,CreatedBy
           ,ApprovalDeadlineAt
           ,CampaignDetailsUrl
           ,ApprovalDeadlineNotified
		   ,ClientMessageId
		   ,ChannelType
           ,Price
           ,PriceCurrency
		   ,CampaignMeta)
	OUTPUT inserted.CampaignId
    VALUES (
		@CampaignStatusId /* Status */, 
		@AccountUid, @SubAccountId, @SubAccountUid,
		@Product,
		@CampaignName, 
		@TemplateBody, 
		@TemplateSenderId, 
		@TemplateId, 
		@CampaignType,
		0, 0, 0, 
		0, 0, 0, 
		@ScheduledAt, 
		SYSUTCDATETIME(), 
		@CreatedBy,
        IIF(@CampaignStatusId > 0, DATEADD(hour, 24, SYSUTCDATETIME()), NULL),
        @CampaignDetailsUrl,
        0, --ApprovalDeadlineNotified
		@ClientMessageId,
		@ChannelType,
        @Price,
        @PriceCurrency,
		@CampaignMeta)
	
	EXEC cp.CmSenderIdSuggestion_Add @AccountUid = @AccountUid, @SenderId = @TemplateSenderId
END
