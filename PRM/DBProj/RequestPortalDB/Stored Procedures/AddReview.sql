CREATE Procedure [dbo].[AddReview]
	@RequestID int,
	@UserID int,
	@CreationDate datetime,
	@Comment varchar(200),
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
			Select cast(0 as int);
		END


		Declare @username varchar(100)
		Declare @to_email varchar(50)
		Declare @ApproverId int;
		Declare @login varchar(50)

		SELECT @ApproverId=ApproverID
		FROM dbo.ReqWorkflow Where RequestID = @RequestID and ApprovalOrder=1

		Select Top 1 @ApproverId=ApproverID from dbo.ReqWorkflow 
		Where RequestID = @RequestID and Status = 2 Order by ApprovalOrder ASC

		SELECT @username=u.Name,@to_email =u.Email,@login=u.Login
		FROM dbo.Users u Where UserId = @UserID

		-- Entry in activity log
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserID, @Comment, @login + ' asked for review.' ,@CreationDate,0,0)

		exec dbo.AddEmailRequestToStudents 6, @RequestID, @ApproverId, @UniqueId, '', @Comment, @CreationDate, '','',0



		DECLARE @TempTable TABLE (ID INT Identity(1,1), WFID INT)
		Declare @TempID int = 1
		Declare @WFID int = 0

		
		INSERT INTO @TempTable(WFID)
		Select ID  From [dbo].[ReqWorkflow] 
		Where [RequestID] = @RequestID 
		and 
			(Status = 2 -- Pending 
				and
			ApproverID = @ApproverId
		   )
		

		Declare @TotalWFCount int 
		Select @TotalWFCount = Count(*) from @TempTable

		-- Add email entry for approver
		
		Declare @nextApproverUserId int
		-----------------------------------------------------------

		While @TempID <= @TotalWFCount
		BEGIN 
			--SET @temp_email_body = @email_body;

			Select @WFID = WFID from @TempTable Where ID = @TempID
			Select @nextApproverUserId = rwf.ApproverID  from [dbo].[ReqWorkflow] rwf Where ID = @WFID

			exec dbo.AddEmailRequestToApprover 9, @RequestID, @ApproverId, @UniqueId, '', @Comment, @CreationDate,@nextApproverUserId

			SET @TempID = @TempID + 1

		END
		UPDATE [dbo].[RequestMainData] SET ActionDate=GETDATE()
		Where RequestID = @RequestID
		Select @RequestID
End





