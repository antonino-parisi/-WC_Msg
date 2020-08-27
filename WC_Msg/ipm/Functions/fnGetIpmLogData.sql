

-- =============================================
-- Author:		Rebecca
-- Create date: 2019-02-11
-- =============================================
-- Usage : SELECT * FROM ipm.fnGetIpmLogData('2019-10-01', '2019-10-03', 'sun_life_ChatApps', DEFAULT)
-- =============================================
-- Change History
-- =============================================
-- Date        Author   Description 
-- --------    -------  ------------------------------------

CREATE FUNCTION [ipm].[fnGetIpmLogData] (
	@StartDate DATETIME,
	@EndDate DATETIME,
	@SubAccountId VARCHAR(50) = NULL,
	@ChannelType CHAR(20) = NULL)
RETURNS TABLE  
AS  
RETURN  
    SELECT L.CreatedAt, sa.SubAccountId, L.Country, C.CountryName, Ch.ChannelType ChannelId,
            L.StatusId, L.Direction, L.Step, L.DeliveredAt, L.ReadAt, L.InitSession,
            L.MSISDN, ChannelCostEUR, MessageFeeEUR
    FROM sms.IpmLog L WITH (NOLOCK, INDEX(IX_IpmLog_SubAccount_CreatedAt))
        LEFT JOIN ms.SubAccount sa WITH (NOLOCK)
            ON L.SubAccountUid = sa.SubAccountUid
        LEFT JOIN mno.Country C WITH (NOLOCK)
            ON L.Country = C.CountryISO2alpha
        LEFT JOIN ipm.ChannelType Ch WITH (NOLOCK)
            ON L.ChannelUid = Ch.ChannelTypeId
    WHERE L.CreatedAt >= @StartDate
        AND L.CreatedAt < @EndDate
        AND (@SubAccountId IS NULL OR
            L.SubAccountUid = (SELECT SubAccountUid FROM dbo.Account WITH (NOLOCK)
                                WHERE SubAccountId = @SubAccountId))
        AND (@ChannelType IS NULL OR
            L.ChannelUid = (SELECT ChannelTypeId FROM ipm.ChannelType WITH (NOLOCK)
                                WHERE ChannelType = @ChannelType));
