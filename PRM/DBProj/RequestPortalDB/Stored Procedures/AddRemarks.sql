
CREATE Procedure [dbo].[AddRemarks]
	@RequestID int,
	@ApproverId int,
	@CreationDate datetime,
	@Comment varchar(200),
	@isprintable bit,
	@visibleToUserId int,
	@canReplyUserId int,
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

		SELECT @username= DesigWithName 
		FROM dbo.vwApproverWithDesig Where ApproverID = @ApproverId

		-- Entry in activity log
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID,ShowActionPanel)
		Values(@RequestID, @ApproverId, @Comment, @username + ' commented on it.' ,@CreationDate,@isprintable,@visibleToUserId,@canReplyUserId,1)
	
		exec dbo.AddEmailRequestToApprover 7, @RequestID, @ApproverId, @UniqueId, '', @Comment, @CreationDate,0
		
		DECLARE @TempTable TABLE (ID INT Identity(1,1), WFID INT)
		Declare @TempID int = 1
		Declare @WFID int = 0

		-- Prepare list of contributors (who have requests in pending state)
		-- @visibleToUserId = 0 means Student + Contributors
		-- @visibleToUserId = -1 means only for contributors
		-- @visibleToUserId = -2 means only for student (application creator)
		-- @visibleToUserId > 0 means only for a specific contributor
		INSERT INTO @TempTable(WFID)
		Select ID  From [dbo].[ReqWorkflow] 
		Where [RequestID] = @RequestID 
		and 
			((Status = 2 -- Pending 
				AND @visibleToUserId IN (0,-1)
			)
			OR
			(@visibleToUserId > 0 AND ApproverID = @visibleToUserId)
		   )
		--and ApproverID = case when @visibleToUserId > 0 then @visibleToUserId else ApproverID end
		and @visibleToUserId != -2 
		And ApproverID != @ApproverId

		Declare @TotalWFCount int 
		Select @TotalWFCount = Count(*) from @TempTable

		-- Add email entry for approver
		
		Declare @nextApproverUserId int
		-----------------------------------------------------------

		While @TempID <= @TotalWFCount
		BEGIN 

			Select @WFID = WFID from @TempTable Where ID = @TempID

			Select @nextApproverUserId = rwf.ApproverID  from [dbo].[ReqWorkflow] rwf Where ID = @WFID
			exec dbo.AddEmailRequestToApprover 8, @RequestID, @ApproverId, @UniqueId, '', @Comment, @CreationDate,@nextApproverUserId
			SET @TempID = @TempID + 1

		END

		--For Requester (if remarks is for student)
		IF @visibleToUserId = 0 OR @visibleToUserId =  -2  
		BEGIN
		exec dbo.AddEmailRequestToStudents 5, @RequestID, @ApproverId, @UniqueId, '', @Comment, @CreationDate, '','',0
		END
		UPDATE [dbo].[RequestMainData] SET ActionDate=GETDATE()
		Where RequestID = @RequestID
		Select @RequestID
End






