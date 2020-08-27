  
  
-- =============================================    
-- Author:  Raju Gupta    
-- Create date: 13/03/2014    
-- Description: return the invoice details     
-- =============================================    
CREATE PROCEDURE [dbo].[usp_CP_GetInvoices]      
   
@AccountId NVARCHAR(100)     
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
 --begin     
 SELECT Amount, DatePublished,paymentType,DatePaid, Status, refCode, InvoiceId  FROM Invoices  where  AccountId=@AccountId order by InvoiceId desc  
---- SELECT   
----case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
----                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
---- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
----Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
----FROM Invoices order by DatePublished asc   
----end    
     
-- if @Status='All' AND @AccountId<>'All'    
-- --begin     
-- SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE AccountId=@AccountId  order by InvoiceId desc
---- SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
----                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
---- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
----Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
----FROM Invoices   WHERE AccountId=@AccountId  order by DatePublished asc  
----end       
-- if @Status<>'All' AND @AccountId='All'    
-- --begin     
-- SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE Status=@Status order by InvoiceId desc   
---- SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
----                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
---- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
----Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
----FROM Invoices WHERE Status=@Status order by DatePublished asc end     
-- --end    
     
--IF @Status<>'All' AND @AccountId<>'All'    
-- --BEGIN     
-- SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE Status=@Status AND AccountId=@AccountId order by InvoiceId desc  
--  --SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
--  --               when 'paypal' then '2-' +CAST(InvoiceId as varchar) ELSE  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType FROM Invoices WHERE  Status=@Status AND AccountId=@A
----ccountId order by DatePublished asc    
-- --END    
    
    
    
    
   END    
    
    
    
    
  