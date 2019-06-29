
CREATE Procedure [dbo].[RemoveContributor]
	@RequestID int,
	@WfID int,
	@ApproverIDToRemove int,
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
	
	-- Append in comment if A user is doing this on behalf of
		if(@otherUserLogin != '')
			SET @otherUserLogin = '---------[By '+@otherUserLogin+' on behalf of]'

	   Delete from dbo.ReqWorkflow Where ID = @WfID And RequestID = @RequestID And ApproverID = @ApproverIDToRemove

		/* Activity Log Changes */

		Declare @currUserName varchar(100)
		SELECT @currUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @CurrentApproverID

		Declare @TagetUserName varchar(100)
		SELECT @TagetUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverIDToRemove

		-- Add log for removed contributors
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Select @RequestID, @CurrentApproverID, @TagetUserName + ' is removed from contributors.' + @otherUserLogin, 
				@currUserName + ' made a change in contributors.' ,@currentTime

	  
		select cast(1 as int)
End






