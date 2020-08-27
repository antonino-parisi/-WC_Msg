
-- =============================================
-- Author:		Anton Shchekalov
-- Create date: 2017-07-07
-- Description:	BillingTransaction - add new
-- =============================================
-- EXEC cp.BillingTransaction_Add @AccountUid = '47E0E533-14F0-E611-813F-06B9B96CA965', @UserId = '1DED50E1-AE43-41E1-A4AB-188D2E7DEF1C', @InvoiceNumber = '#Test1', @Currency = 'EUR', @Amount = 0.98765, @PaymentProvider = 'Fake', @PaymentRef = 'tr_123' 
CREATE PROCEDURE [cp].[BillingTransaction_Add]
	@AccountUid uniqueidentifier,
	@UserId uniqueidentifier,	-- NULL is accepted value (when payment is initiated by platform)
	@InvoiceNumber varchar(20),
	@Currency char(3),
	@Amount decimal(19,7),
	@PaymentProvider varchar(20),
	@PaymentRef varchar(50),
	@Description nvarchar(500) = NULL
AS
BEGIN

	DECLARE @AmountEUR decimal(19,7)
	SET @AmountEUR = mno.CurrencyConverter(@Amount, @Currency, 'EUR', DEFAULT)
	
	INSERT INTO cp.BillingTransaction (
		CreatedAt,
		Type,	
		InvoiceNumber,
		Currency,
		Amount,
		AmountEUR,
		AccountUid,
        UserId,
		PaymentProvider,
		PaymentRef,
		PaymentDate,
		Description)
     OUTPUT inserted.TrxId, inserted.TrxIntStatus
	 VALUES
           (SYSUTCDATETIME(), 'CARD', @InvoiceNumber, 
		   @Currency, 
		   @Amount, 
		   @AmountEUR, -- AmountEUR
		   @AccountUid, @UserId, 
		   @PaymentProvider, @PaymentRef,
		   SYSUTCDATETIME(),
		   @Description)

	-- CPv1 compatibility
	DECLARE @TrxId int = SCOPE_IDENTITY()
	DECLARE @AccountId varchar(50)
	SELECT @AccountId = AccountId FROM cp.Account WHERE AccountUid = @AccountUid

	INSERT INTO dbo.Invoices
           (Amount,
			Currency,
            DatePublished
           ,DatePaid
           ,Status
           ,AccountId
           ,refCode
           ,paymentType
           ,bankRef
           ,TaxAmount
           ,NetAmount
           ,PaypalToken
           ,ExtraInfo)
     VALUES (@Amount, @Currency, SYSUTCDATETIME(), NULL, 'UNPAID', @AccountId, 
		   'CP:' + CAST(@TrxId AS varchar(10)), @PaymentProvider, @PaymentRef, 0, @Amount, NULL, @PaymentRef)

END
