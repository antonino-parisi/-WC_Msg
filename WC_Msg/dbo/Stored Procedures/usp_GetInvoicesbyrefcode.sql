  
    
-- =============================================    
-- Author:  Raju Gupta    
-- Create date: 21/09/2011    
-- Description: return the invoice details     
-- =============================================    
CREATE PROCEDURE [dbo].[usp_GetInvoicesbyrefcode]      
@bankref_or_InvoiceId NVARCHAR(100),    
@StartDate DATE,
@EndDate DATE     
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.
 
 IF(@StartDate<>'1970-01-01' AND @EndDate<>'1970-01-01' AND @bankref_or_InvoiceId<>'')
BEGIN     
 IF Isnumeric(@bankref_or_InvoiceId)=1   
 BEGIN  
 SELECT * FROM Invoices WHERE InvoiceId=@bankref_or_InvoiceId AND DatePublished between @StartDate and @EndDate order by InvoiceId desc
end
 ELSE  
BEGIN  
 SELECT *  FROM Invoices WHERE bankRef=@bankref_or_InvoiceId AND DatePublished between @StartDate and @EndDate  order by InvoiceId desc   


END
END
IF(@StartDate='1970-01-01' AND @EndDate='1970-01-01' AND @bankref_or_InvoiceId<>'')
BEGIN

IF Isnumeric(@bankref_or_InvoiceId)=1   
 BEGIN  
 SELECT * FROM Invoices WHERE InvoiceId=@bankref_or_InvoiceId order by InvoiceId desc

 END  
 ELSE  
BEGIN  
 SELECT *  FROM Invoices WHERE bankRef=@bankref_or_InvoiceId  order by InvoiceId desc   

END  
END

IF(@StartDate<>'1970-01-01' AND @EndDate<>'1970-01-01' AND @bankref_or_InvoiceId='')
Begin
SELECT * FROM Invoices WHERE DatePublished between @StartDate and @EndDate order by InvoiceId desc
End





END      