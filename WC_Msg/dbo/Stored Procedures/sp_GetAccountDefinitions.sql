-- TODO: rewrite this ugly SP
CREATE PROCEDURE [dbo].[sp_GetAccountDefinitions]
			
AS


CREATE TABLE #TEMPTABLE_acc
(
     AccountId nvarchar(50),
     SubAccountId  nvarchar(50)
       
)

insert into #TEMPTABLE_acc select AccountId,SubAccountId from StandardAccount order by AccountId asc
insert into #TEMPTABLE_acc SELECT AccountId,SubAccountId  FROM Account  order by AccountId asc


select * from  #TEMPTABLE_acc

drop table #TEMPTABLE_acc