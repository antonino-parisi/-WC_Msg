CREATE VIEW [rpt].[bi_AccountCredentials]
AS
	SELECT 
        AccountId,        
        Description,
        date,
        overdraftAuthorized,
        OutOfCredit,
        IsVerified
     FROM
        AccountCredentials