

CREATE Procedure [dbo].[RouteBack]
	@RequestID int,
	@ApproverID int,
	@ApprovalDate datetime,
	@Remarks varchar(500),
	@UniqueId varchar(40),
	@ReqUniqueId varchar(40)
As 
Begin

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			SELECT cast(0 as int)
		END

	--Also need to handle parallel approval case

	-- Find Last Approver ID

		Declare @rwfId int
		Declare @prevApproverId int

		Select Top 1 @rwfId = ID,@prevApproverId = ApproverID from dbo.ReqWorkflow 
		Where RequestID = @RequestID and Status = 3 Order by ApprovalOrder DESC

		if isnull(@rwfId,0) != 0
		BEGIN

			-- Mark Current Approver as 'Not Assigned'
			Update dbo.ReqWorkflow Set Status = 1,StatusTime = @ApprovalDate,IsCurrApprover=0 where RequestID = @RequestID and ApproverID = @ApproverID
			
			exec dbo.AddEmailRequestToApprover 3, @RequestID, @ApproverId, @UniqueId, '', @Remarks, @ApprovalDate,0
			-- Mark Last approver status as 'Pending'
			Update dbo.ReqWorkflow Set Status = 2,StatusTime = @ApprovalDate,IsCurrApprover=1 where ID =@rwfId

			exec dbo.AddEmailRequestToApprover 4, @RequestID, @ApproverId, @UniqueId,'', @Remarks, @ApprovalDate,@prevApproverId
			exec dbo.AddEmailRequestToStudents 3, @RequestID, @ApproverId, @UniqueId,'' , @Remarks, @ApprovalDate, '','', @prevApproverId
		
			Update dbo.ActivityLogTable Set IsPrintable = 0 Where IsPrintable =1 And Activity like '%approved%' and RequestId = @RequestID And UserId = @prevApproverId

			Select @RequestID
		END
		ELSE 
		BEGIN
			Select cast(-1 as int)
		END
		
		
End





