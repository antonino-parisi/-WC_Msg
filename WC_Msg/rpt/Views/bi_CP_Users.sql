CREATE VIEW [rpt].[bi_CP_Users]
AS
	SELECT
  u.UserId
, u.Login
, u.Accountuid
, u.firstname
, u.lastname
, u.phone
, u.createdat
, u.lastloginat
, u.phoneverified
, a.accountid
, a.country
, a.companyaddress
, a.accountcurrency
FROM cp.[User]u
LEFT JOIN cp.Account a
 ON u.AccountUid = a.AccountUid