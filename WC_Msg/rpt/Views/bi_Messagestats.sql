CREATE VIEW [rpt].[bi_Messagestats]
AS
	select
messagestats.date,
messagestats.AccountId,
messagestats.SubAccountId,
messagestats.country,
messagestats.OperatorName,
operator.OperatorId,
messagestats.RouteId,
messagestats.MessageType,
messagestats.Cost,
messagestats.Price,
messagestats.TotalMessage,
messagestats.Error,
messagestats.Pending,
messagestats.Rejected,
messagestats.Sent
    from messagestats
    full outer join
    Operator
    on (messagestats.operatorname = operator.operatorname AND messagestats.country = operator.country)