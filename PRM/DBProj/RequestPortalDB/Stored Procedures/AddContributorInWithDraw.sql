CREATE Procedure [dbo].[AddContributorInWithDraw]

@RequestID int,
@UniqueId varchar(40)
As
BEGIN
	
	--Get Approvers ID of Teachers
	Declare @appTable table(appID int)
	Insert into @appTable (appID) 
	Select ApproverID from dbo.CourseWithdrawal where RequestID = @RequestID

	 select distinct * into #tmp From @appTable
     delete from @appTable
     insert into @appTable                
     select * from #tmp drop table #tmp
	 select * from @appTable

	--Declaring variables
	Declare @ApproverID int, @currentTime datetime
	Declare @DefaultStatusForWF int = 1, @isCurrentApprover bit = 0
	Declare @count int, @ctr int = 0 , @ReqUniqueId varchar (40)
	Declare @pFirstApproverID int,@pSecondApproverID int, @maxApprovalOrder int = 1

	--Get current Time and no. of Teachers(Approvers) for the request
	SELECT @currentTime = SYSDATETIME()
	SELECT @count = COUNT(*) from @appTable

	--Inserting Teachers as Approvers in Request Workflow Table
	while (@ctr < @count)
	BEGIN
		Select @ApproverID = appID from @appTable

		-- SET status based on if parallel approvers are allowed or not
		Select 	@DefaultStatusForWF = case IsParalApprovalAllowed when 1 then 2 else 1 end, @isCurrentApprover = IsParalApprovalAllowed
		from [dbo].[FormCategories] fc 
		inner join dbo.RequestMainData rm on fc.CategoryID = rm.CategoryID and rm.RequestID = @RequestID

		-- Insert entry in workflow table
		INSERT INTO [dbo].[ReqWorkflow](RequestID, ApproverID, ApprovalOrder, Status, Remarks, EntryTime, ActionUserID,UserID,IsCurrApprover)
		Select @RequestId, @ApproverID, @maxApprovalOrder, @DefaultStatusForWF,'',@currentTime, t.approverId,t.userid,@isCurrentApprover
		from  dbo.Approvers t Where t.ApproverID = @ApproverID AND IsActive = 1 and ApproverID NOT IN (Select ApproverID from dbo.ReqWorkflow where RequestID = @RequestID)

		Delete from @appTable where appID = @ApproverID
		Set @ctr = @ctr + 1
		Set @maxApprovalOrder = @maxApprovalOrder + 1
	END
	
	UPDATE dbo.ReqWorkflow SET ApprovalOrder= @maxApprovalOrder WHERE ApprovalOrder = 0
	UPDATE dbo.ReqWorkflow SET Status = 2, IsCurrApprover = 1 where ApprovalOrder = 1 and RequestID = @RequestID

	DECLARE @TempTable TABLE (ID INT Identity(1,1), WFID INT)
	Declare @TempID int = 1
	Declare @WFID int = 0

	INSERT INTO @TempTable(WFID)
	Select ID  From [dbo].[ReqWorkflow] Where [RequestID] = @RequestID and Status = 2
		
	Declare @TotalWFCount int
	Declare @requester_name varchar(50), @requester_email varchar (50), @UserId int
	Select @TotalWFCount = Count(*) from @TempTable

	Declare @nextApproverUserId int
	While @TempID <= @TotalWFCount
	BEGIN 
		Select @WFID = WFID from @TempTable Where ID = @TempID
		Select @nextApproverUserId = rwf.ApproverID  
		from [dbo].[ReqWorkflow] rwf 
		Where ID = @WFID
			
		exec dbo.AddEmailRequestToApprover 2, @RequestID,@ApproverID, @UniqueId, '', '',@currentTime,@nextApproverUserId
		SET @TempID = @TempID + 1
	END
END