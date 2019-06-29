CREATE Procedure [dbo].[UpdateWorkFlow]
@idsStr varchar(100),
@requestId int,
@ApproverId int,
@currentTime datetime,
@otherUserLoggin varchar(50)
As 
Begin
	BEGIN TRANSACTION t1
	BEGIN TRY
		
		-- Append in comment if A user is doing this on behalf of
		if(@otherUserLoggin != '')
			SET @otherUserLoggin = '---------[By '+@otherUserLoggin+' on behalf of]'


		Declare @currUserName varchar(100)
		-- Status to Insert while adding new Entries in workflow table
		Declare @DefaultStatusForWF int = 1
		DEclare @isCurrentApprover bit = 0

		Declare @ids table(id int identity(1,1), approverId bigint)
		Declare @delTbl table(id int identity(1,1), approverId bigint,wfid int)
		Declare @insertTbl table(id int identity(1,1), approverId bigint)
		Declare @updateTbl table(id int identity(1,1), approverId bigint,wfid int)



		SELECT @currUserName = ISNULL(DesigWithName,'')
		FROM dbo.vwApproverWithDesig WHERE ApproverID = @ApproverId

		-- SET status based on if parallel approvers are allowed or not
		Select 
		@DefaultStatusForWF = case IsParalApprovalAllowed when 1 then 2 else 1 end,
		@isCurrentApprover = IsParalApprovalAllowed

		from [dbo].[FormCategories] fc inner join dbo.RequestMainData rm on fc.CategoryID = rm.CategoryID and rm.RequestID = @requestId


		-- Convert data into table from comma separated string
		insert into @ids(approverId)
		SELECT Value FROM dbo.split1 ( @idsStr ) 

		-- Find which records need to be removed
		insert into @delTbl(approverId,wfid)
		Select ApproverID,ID from [dbo].[ReqWorkflow] 
		where RequestID = @requestId 
		and ApproverID NOT IN (Select approverId from @ids)
	
		-- Find which IDs are neither removed/added
		insert into @updateTbl(approverId,wfid)
		Select u.ApproverID,u.ID from [dbo].[ReqWorkflow] u 
		inner join @ids d on u.ApproverID = d.approverId 
		and u.RequestID =@requestId and u.Status = 1 --(Not Assigned)


		-- Delete which are removed OR which were neither removed/added
		Delete from dbo.ReqWorkflow 
		where ID in (
			select wfid from @delTbl UNION ALL
			select wfid from @updateTbl
		) And Status = 1
	

		-- Find all records which should be added
		insert into @insertTbl(approverId)
		Select d.approverId from @ids d 
		where d.approverId not in(
			Select ApproverID from [dbo].[ReqWorkflow] 
			where RequestID = @requestId )
		order by d.id asc
	
		-- Add log for removed contributors
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Select @RequestID, @ApproverId, a.DesigWithName + ' is removed from contributors.' + @otherUserLoggin, 
				@currUserName + ' made a change in contributors.' ,@currentTime
		FROM  dbo.vwApproverWithDesig a INNER JOIn @delTbl d on a.ApproverID = d.approverId
	

		-- Find max approval order to be used for new entries
		Declare @maxApprOrder int  =0 
		Select @maxApprOrder = max(ApprovalOrder) from dbo.ReqWorkflow Where RequestID = @requestId

		-- Insert entries in workflow table
		INSERT INTO [dbo].[ReqWorkflow](RequestID, ApproverID, ApprovalOrder, Status, Remarks, EntryTime, ActionUserID,UserID,IsCurrApprover)
		Select @requestId,  t.approverId, isnull(@maxApprOrder,0) + id, @DefaultStatusForWF,'',@currentTime, t.approverId,a.userid,@isCurrentApprover
		from @insertTbl t INNER JOIN dbo.Approvers a on t.approverId = a.ApproverID and IsActive = 1
		
		-- Add log for added contributors
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Select @RequestID, @ApproverId, a.DesigWithName + ' is added in contributors.' + @otherUserLoggin, 
				@currUserName + ' made a change in contributors.' ,@currentTime
		FROM  dbo.vwApproverWithDesig a INNER JOIn @insertTbl d on a.ApproverID = d.approverId
		AND NOT Exists(Select * from @updateTbl where approverId = d.approverId)

		COMMIT TRANSACTION t1
	END TRY
	BEGIN CATCH
		ROLLBACK Transaction t1
		SELECT -1 as int
		Return;
	END CATCH

	Select 1 as int;
End








