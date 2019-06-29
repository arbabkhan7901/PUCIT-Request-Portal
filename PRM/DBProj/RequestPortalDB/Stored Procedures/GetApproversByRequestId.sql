
CREATE Procedure [dbo].[GetApproversByRequestId]
@requestId int,
@ReqUniqueId varchar (40)
As 
Begin
	--Declare @requestId int
	--Set @requestId = 18

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			return NULL;
		END


	Select rwf.ID as WFID, a.ApproverID , a.Login, a.Name, a.Designation, a.Email, rwf.Status as WorkFlowStatus
	from [dbo].[ReqWorkflow] rwf 
	INNER JOIN dbo.vwApproverWithDesig a on rwf.ApproverID = a.ApproverID
	Where rwf.RequestID = @requestId
	Order by rwf.ApprovalOrder 
End





