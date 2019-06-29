
CREATE Procedure [dbo].[AddContributor]
	@RequestID int,
	@ApproverIDToAdd int,
	@currentTime datetime,
	@CurrentApproverID int,
	@otherUserLogin varchar(50),
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
			return;
		END
		
		Declare @wfid int = 0

		-- Append in comment if A user is doing this on behalf of
		if(@otherUserLogin != '')
			SET @otherUserLogin = '---------[By '+@otherUserLogin+' on behalf of]'


		-- Status to Insert while adding new Entries in workflow table
		Declare @DefaultStatusForWF int = 1
		DEclare @isCurrentApprover bit = 0
		-- SET status based on if parallel approvers are allowed or not
		Select 
			@DefaultStatusForWF = case IsParalApprovalAllowed when 1 then 2 else 1 end,
			@isCurrentApprover = IsParalApprovalAllowed
		from [dbo].[FormCategories] fc inner join dbo.RequestMainData rm on fc.CategoryID = rm.CategoryID and rm.RequestID = @requestId

		
	   -- Find max approval order to be used for new entries
		Declare @maxApprOrder int  =0 
		Select @maxApprOrder = max(ApprovalOrder) from dbo.ReqWorkflow Where RequestID = @requestId


		-- Insert entry in workflow table
		INSERT INTO [dbo].[ReqWorkflow](RequestID, ApproverID, ApprovalOrder, Status, Remarks, EntryTime, ActionUserID,UserID,IsCurrApprover)
		Select @requestId,  t.approverId, isnull(@maxApprOrder,0) + 1, @DefaultStatusForWF,'',@currentTime, t.approverId,t.userid,@isCurrentApprover
		from  dbo.Approvers t Where t.ApproverID = @ApproverIDToAdd AND IsActive = 1
		
		select @wfid = scope_identity()

		/* Activity Log Changes */

		Declare @currUserName varchar(100)
		SELECT @currUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @CurrentApproverID

		Declare @TagetUserName varchar(100)
		SELECT @TagetUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverIDToAdd

		-- Add log for added contributors
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Select @RequestID, @CurrentApproverID, @TagetUserName + ' is added in contributors.' + @otherUserLogin, 
				@currUserName + ' made a change in contributors.' ,@currentTime
					  
		select cast(@wfid as int)
End





