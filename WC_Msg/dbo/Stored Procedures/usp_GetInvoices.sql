  
  
-- =============================================    
-- Author:  Raju Gupta    
-- Create date: 21/09/2011    
-- Description: return the invoice details     
-- =============================================    
CREATE PROCEDURE [dbo].[usp_GetInvoices]      
@Status NVARCHAR(100),    
@AccountId NVARCHAR(100)     
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
 if @Status='All' AND @AccountId='All'    
 --begin     
 SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices order by InvoiceId desc  
-- SELECT   
--case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
--                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
-- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
--Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
--FROM Invoices order by DatePublished asc   
--end    
     
 if @Status='All' AND @AccountId<>'All'    
 --begin     
 SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE AccountId=@AccountId  order by InvoiceId desc
-- SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
--                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
-- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
--Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
--FROM Invoices   WHERE AccountId=@AccountId  order by DatePublished asc  
--end       
 if @Status<>'All' AND @AccountId='All'    
 --begin     
 SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE Status=@Status order by InvoiceId desc   
-- SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
--                 when 'paypal' then '2-' +CAST(InvoiceId as varchar)            
-- else  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,  
--Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType  
--FROM Invoices WHERE Status=@Status order by DatePublished asc end     
 --end    
     
IF @Status<>'All' AND @AccountId<>'All'    
 --BEGIN     
 SELECT InvoiceId,Amount,DatePublished,DatePaid,Status,AccountId,NetAmount,TaxAmount,refCode,bankRef,paymentType  FROM Invoices   WHERE Status=@Status AND AccountId=@AccountId order by InvoiceId desc  
  --SELECT case paymentType when 'BankTransfer'  then '2-' +CAST(InvoiceId as varchar)   
  --               when 'paypal' then '2-' +CAST(InvoiceId as varchar) ELSE  '1-' +CAST(InvoiceId as varchar) END AS InvoiceId ,Amount,DatePublished,DatePaid,Status,AccountId,refCode,bankRef,paymentType FROM Invoices WHERE  Status=@Status AND AccountId=@A
--ccountId order by DatePublished asc    
 --END    
    
    
    
    
   END    
    
    
    
    
  