
CREATE VIEW [optimus].[vwSenderMaskingRules]
AS
SELECT s.Country, o.OperatorName, s.RouteId, s.CustomerType,
	s.SubAccountId,	s.AccountId, s.SenderIdFilterType, s.OriginalSenderId,
	s.[Priority], s.NewSenderId, s.NewSenderPoolId,
	p.SenderPoolName, p.SenderPoolDescription, s.Deleted
FROM optimus.SenderMaskingRules s WITH (NOLOCK)
	LEFT JOIN mno.Operator o
		ON s.OperatorId = o.OperatorId
	LEFT JOIN optimus.SenderRotationPool p
		ON ISNULL(s.NewSenderPoolId,0) = p.SenderPoolId
