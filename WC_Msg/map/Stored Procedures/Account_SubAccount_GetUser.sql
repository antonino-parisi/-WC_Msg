-- =============================================
-- Author:		Rebecca Loh
-- Create date: 2019-11-28
-- Description:	Get users info given AccountUid
-- =============================================
-- EXEC map.Account_SubAccount_GetUser @AccountUid='076A6104-0483-E711-8143-02D85F55FCE7'

CREATE PROCEDURE [map].[Account_SubAccount_GetUser]
	@AccountUid uniqueidentifier,
	@Email nvarchar(255) = NULL,
	@UserName nvarchar(500) = NULL
AS
BEGIN

	SELECT u.UserId, FirstName, Lastname, [Login], UserStatus, AccessLevel,
			a.Product_SMS, a.Product_CA, a.Product_VI, a.Product_VO,
			us.SubAccountUid, s.SubAccountId
	FROM cp.[User] u
		LEFT JOIN cp.Account a ON u.AccountUid = a.AccountUid
		LEFT JOIN cp.UserSubAccount us ON u.UserId = us.UserId
		LEFT JOIN ms.SubAccount s ON us.SubAccountUid = s.SubAccountUid
	WHERE u.AccountUid = @AccountUid
		AND ((@Email IS NULL OR [Login] LIKE '%' + @Email + '%')
		AND (@UserName IS NULL OR FirstName LIKE '%' + @UserName + '%' OR LastName LIKE '%' + @UserName + '%')) ;

	SELECT @@ROWCOUNT TotalRows;
END
