CREATE Procedure [dbo].[SaveRequest]
	@RequestID int,
	@CategoryID int,
	@UserId int,
	@RollNo varchar(20),
	@CreationDate datetime,
	@TargetSemester int,
	@Reason varchar(200),
	@TargetDate datetime,
	@CurrentSemester int,
	@Status int,
	@Subject varchar(50),
	@UniqueId varchar(40),
	@ReqUniqueId varchar(40)	

As 
Begin

	IF @RequestID = 0
	BEGIN

		Declare @IsOldCampus bit
		Declare @IsNewCampus bit
		
		
		Declare @requester_email varchar(50)
		Declare @requester_name varchar(100)

		Select @IsOldCampus= IsOldCampus, @requester_email = email,
		@requester_name = name
		from dbo.Users where UserId = @UserId

		IF @IsOldCampus = 1
			SET @IsNewCampus = 0
		ELSE
			SET @IsNewCampus = 1


		INSERT INTO [dbo].[RequestMainData](CategoryID, UserId, RollNo, CreationDate, TargetSemester, Reason, TargetDate, CurrentSemester,  RequestStatus, Subject,ReqUniqueId,ActionDate)
		Values(@CategoryID, @UserId, @RollNo, @CreationDate, @TargetSemester, @Reason, @TargetDate, @CurrentSemester,   @Status, @Subject, @ReqUniqueId,GETDATE())

		Select @RequestID = SCOPE_IDENTITY()

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId,'', @RollNo + ' created application.',@CreationDate,0,0)


		Declare @formName varchar(100)
		Declare @IsParalApprovalAllowed bit  = 0 
		Declare @DefaultStatusForWF int = 1
		Declare @DefaultIsCurrApprover bit = 0

		Select @formName = upper(Category), @IsParalApprovalAllowed = IsParalApprovalAllowed 
		from [dbo].[FormCategories] Where CategoryID = @CategoryID;

		IF @IsParalApprovalAllowed = 1
		BEGIN
			SET @DefaultStatusForWF = 2
			SET @DefaultIsCurrApprover = 1
		END
	

		INSERT INTO [dbo].[ReqWorkflow](RequestID, ApproverID,UserID, ApprovalOrder, Status, Remarks, EntryTime, ActionUserID,IsCurrApprover)
		Select @RequestID, ah.ApproverID,a.UserID, ApprovalOrder, case ApprovalOrder when 1 then 2 else @DefaultStatusForWF end as status,'',@CreationDate,  ah.ApproverID,
		case ApprovalOrder when 1 then 1 else @DefaultIsCurrApprover end as iscurrentapprover
		from [dbo].[ApproverHierarchy] ah inner join dbo.Approvers a on ah.ApproverID = a.ApproverID
		Where ah.FormID = @CategoryID and (IsForNewCampus =@IsNewCampus OR IsForOldCampus = @IsOldCampus)
		ORDER By ApprovalOrder
		

		DECLARE @TempTable TABLE (ID INT Identity(1,1), WFID INT)
		Declare @TempID int = 1
		Declare @WFID int = 0


		INSERT INTO @TempTable(WFID)
		Select ID  From [dbo].[ReqWorkflow] Where [RequestID] = @RequestID and Status = 2
		
		Declare @TotalWFCount int 
		Select @TotalWFCount = Count(*) from @TempTable

		Declare @nextApproverUserId int
		
		While @TempID <= @TotalWFCount
		BEGIN 

			Select @WFID = WFID from @TempTable Where ID = @TempID

			Select @nextApproverUserId = rwf.ApproverID  
			from [dbo].[ReqWorkflow] rwf 
			Where ID = @WFID
			exec dbo.AddEmailRequestToApprover 2, @RequestID,0, @UniqueId, '', '',@CreationDate,@nextApproverUserId
			SET @TempID = @TempID + 1

		END

		exec dbo.AddEmailRequestToStudents 4, @RequestID, 0, @UniqueId, '', '', @CreationDate, '','',0
		
	END

	Select @RequestID
End







