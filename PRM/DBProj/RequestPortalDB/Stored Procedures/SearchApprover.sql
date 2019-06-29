
CREATE Procedure [dbo].[SearchApprover]
@key varchar(20)
As 
Begin
	
	Select a.ApproverID , a.Login, a.Name, a.Designation, a.Email, 0 as WorkFlowStatus
	FROM dbo.vwApproverWithDesig a
	where a.Designation like '%' +@key+ '%' 
	OR a.Name like '%' +@key+ '%' 
	order by a.Name	

End












