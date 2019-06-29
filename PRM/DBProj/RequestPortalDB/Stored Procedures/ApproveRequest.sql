CREATE Procedure [dbo].[ApproveRequest]
	@RequestID int,
	@ApproverID int,
	@ApprovalDate datetime,
	@Remarks varchar(500),
	@Status int,
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

		ELSE
	BEGIN try
		Begin Transaction t1
	--Update Request Flow Status
	IF isnull(@Remarks,'') != ''
	BEGIN
		Update [dbo].[ReqWorkflow] SET Status = @Status, StatusTime = @ApprovalDate, ActionUserID = @ApproverID, Remarks = @Remarks, IsCurrApprover = 0
		Where RequestID = @RequestID and ApproverID =  @ApproverID and Status = 2 
	END
	ELSE
	BEGIN
		Update [dbo].[ReqWorkflow] SET Status = @Status, StatusTime = @ApprovalDate, ActionUserID = @ApproverID, IsCurrApprover = 0
		Where RequestID = @RequestID and ApproverID =  @ApproverID and Status = 2 
	END

	Declare @statusText varchar(20) ='approved'

	if @status = 4
	BEGIN
		SET @statusText = 'rejected';

		Update [dbo].[ReqWorkflow] SET Status = 5, StatusTime = @ApprovalDate, ActionUserID = 0
		Where RequestID = @RequestID and status IN (1,2)
	END

	exec dbo.AddEmailRequestToApprover 1, @RequestID, @ApproverId, @UniqueId, @statusText, @Remarks, @ApprovalDate,0
	exec dbo.AddEmailRequestToStudents 1, @RequestID, @ApproverId, @UniqueId, @statusText, @Remarks, @ApprovalDate, '','',0


	--Update Request Status
	Declare @count int
	Select @count = count(*) from dbo.ReqWorkflow Where RequestID = @RequestID and Status IN (1,2)   -- 1 means notAssigned, 2 means Pending

	-- IF It was last approver or App is rejected
	if @count = 0 OR @Status = 4 
	BEGIN
		UPDATE [dbo].[RequestMainData] SET RequestStatus = @Status, LastModifiedOn = @ApprovalDate,RequestToken = @UniqueId
		Where RequestID = @RequestID


		Declare @IsRecAllowed bit = 0
		Declare @msg varchar(100) = 'Approved by all approvers'
		Declare @subj varchar(100) = 'Application is closed'

		IF @Status = 4 
		BEGIN
			SET @msg = 'Rejected';
		END
		ELSE 
		BEGIN
			SELECt @IsRecAllowed = IsRecievingAllowed from [dbo].[RequestMainData] r INNER JOIN [dbo].[FormCategories] fc
			ON r.CategoryID = fc.CategoryID and r.RequestID = @RequestID
			
			IF @IsRecAllowed = 1 
			BEGIN
				SET @subj = 'Pending for Recieving Activity'
			END
		END

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable, VisibleToUserID,CanReplyUserID)
			Values(@RequestID, @ApproverID, @msg, @subj,@ApprovalDate,0,0,0)

		exec dbo.AddEmailRequestToStudents 2, @RequestID, @ApproverId, @UniqueId, @statusText, @Remarks, @ApprovalDate,'','',0
	END
	ELSE --Not Last approver, also not rejected
	Begin
		-- Find Next approver
		Declare @rwfId int
		Declare @nextApproverId int

		Select Top 1 @rwfId = ID,@nextApproverId = ApproverID from dbo.ReqWorkflow 
		Where RequestID = @RequestID and Status = 1 Order by ApprovalOrder ASC
		
		if isnull(@rwfId,0) != 0
		BEGIN
			-- Mark Next approver status as 'Pending'
			Update dbo.ReqWorkflow Set Status = 2,StatusTime = @ApprovalDate, IsCurrApprover = 1 where ID =@rwfId

			exec dbo.AddEmailRequestToApprover 2, @RequestID, @ApproverId, @UniqueId, @statusText, @Remarks, @ApprovalDate,@nextApproverId
		END
	END
	UPDATE [dbo].[RequestMainData] SET ActionDate=GETDATE()
		Where RequestID = @RequestID
		commit transaction t1
	end TRY
	Begin catch	
		rollback transaction t1
	End catch
	
	Select @RequestID
End






