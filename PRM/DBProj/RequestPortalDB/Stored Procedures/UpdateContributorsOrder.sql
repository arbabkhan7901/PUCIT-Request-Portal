

CREATE Procedure [dbo].[UpdateContributorsOrder]
	@RequestID int,
	@Approvers ArrayInt3 READONLY,
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
		 -- Find max approval order to be used for new entries
		Declare @maxApprOrder int  =0 
		Select @maxApprOrder = max(ApprovalOrder) 
		FROM dbo.ReqWorkflow Where RequestID = @requestId And Status != 1

		DECLARE @oldWorkFlowOrder VARCHAR(MAX)
		SELECT @oldWorkFlowOrder = COALESCE(@oldWorkFlowOrder + '=> ', '') + DesigWithName
		FROM [dbo].[ReqWorkflow] r INNER JOIN dbo.vwApproverWithDesig a on r.ApproverID = a.ApproverID
		Where r.RequestID = @RequestID
		Order by r.ApprovalOrder
		

		-- Update Approval Orders
		Update r SET r.ApprovalOrder = a.ID3 + @maxApprOrder 
		From [dbo].[ReqWorkflow] r INNER JOIN @Approvers a 
		ON  r.ID = a.ID1  -- WFID 
		AND r.ApproverID = a.ID2 -- ApproverID
		AND r.Status = 1 -- Pending


		-- Append in comment if A user is doing this on behalf of
		if(@otherUserLogin != '')
			SET @otherUserLogin = '---------[By '+@otherUserLogin+' on behalf of]'

		
		/* Activity Log Changes */
		Declare @currUserName varchar(100)
		SELECT @currUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @CurrentApproverID


		-- Add log for added contributors
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Select @RequestID, @CurrentApproverID, 'Approvers Order is changed in workflow.' + @otherUserLogin + ' Earlier It was: ' + @oldWorkFlowOrder, 
				@currUserName + ' made a change in contributors.' ,@currentTime
					  
		select cast(1 as int)
End





