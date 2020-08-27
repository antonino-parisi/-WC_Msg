-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2019-10-31
-- Description:	MAP Accounts - Get by filter
-- =============================================
-- Modified By: Alexjander Bacalso
-- Modified Date: 2020-07-08
-- Description: MAP-948 | MAP AM - Transactions to show only the successful payments
-- =============================================
-- EXEC map.[BillingTransaction_GetMany] @AccountUid = '47E0E533-14F0-E611-813F-06B9B96CA965', @Type = 'CARD'
CREATE PROCEDURE [map].[BillingTransaction_GetMany]
	@AccountUid uniqueidentifier,
	@Type varchar(10) = NULL,
	@AmountEURFrom int = NULL,
	@AmountEURTo int = NULL,
	@CreatedFrom smalldatetime = NULL,
	@CreatedTo smalldatetime = NULL,
	@MapUserId smallint = NULL,
	@DescriptionSearch nvarchar(100) = NULL,
	@PageOffset smallint = 0,
	@PageSize smallint = 100
AS
BEGIN
	
	SELECT
		trx.AccountUid,
		trx.CreatedAt,
		trx.Type,
		trx.Currency,
		trx.Amount,
		trx.AmountEUR,
		trx.Description,
		trx.MapUserId,
		trx.TrxIntStatus,
		mu.FirstName AS MapUser_FirstName, 
		mu.LastName AS MapUser_LastName, 
		mu.Email AS MapUser_Email
	FROM cp.BillingTransaction trx
		LEFT JOIN map.[User] mu ON trx.MapUserId = mu.UserId
	WHERE AccountUid = @AccountUid
		-- same conditions as in query below
		AND (@Type IS NULL OR trx.Type = @Type)
		AND (@AmountEURFrom IS NULL OR trx.AmountEUR >= @AmountEURFrom) 
		AND (@AmountEURTo IS NULL OR trx.AmountEUR <= @AmountEURTo)
		AND (@CreatedFrom IS NULL OR trx.CreatedAt >= @CreatedFrom)
		AND (@CreatedTo IS NULL OR trx.CreatedAt <= @CreatedTo)
		AND (@MapUserId IS NULL OR trx.MapUserId = @MapUserId)
		AND (@DescriptionSearch IS NULL OR trx.Description LIKE '%' + @DescriptionSearch + '%')
        AND (trx.Type = 'OVERDRAFT' OR trx.TrxIntStatus = 'SUCCESS')
	ORDER BY trx.TrxId DESC
	OFFSET (@PageOffset) ROWS FETCH NEXT (@PageSize) ROWS ONLY

	SELECT 
		COUNT(1) AS TotalRows, 
		MIN(trx.AmountEUR) AS AmountEUR_Min,
		MAX(trx.AmountEUR) AS AmountEUR_Max
	FROM cp.BillingTransaction trx
	WHERE AccountUid = @AccountUid
		-- same conditions as in query above
		AND (@Type IS NULL OR trx.Type = @Type)
		-- AND (@AmountEURFrom IS NULL OR trx.AmountEUR >= @AmountEURFrom) 
		-- AND (@AmountEURTo IS NULL OR trx.AmountEUR <= @AmountEURTo)
		AND (@CreatedFrom IS NULL OR trx.CreatedAt >= @CreatedFrom)
		AND (@CreatedTo IS NULL OR trx.CreatedAt <= @CreatedTo)
		AND (@MapUserId IS NULL OR trx.MapUserId = @MapUserId)
		AND (@DescriptionSearch IS NULL OR trx.Description LIKE '%' + @DescriptionSearch + '%')
        AND (trx.Type = 'OVERDRAFT' OR trx.TrxIntStatus = 'SUCCESS')
END
