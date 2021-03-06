

CREATE Procedure [dbo].[AddRemarks]
	@RequestID int,
	@ApproverId int,
	@CreationDate datetime,
	@Comment varchar(200),
	@isprintable bit,
	@visibleToUserId int,
	@canReplyUserId int
As 
Begin
		Declare @username varchar(100)
		Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
		on a.UserID = u.UserID
		where a.ApproverID = @ApproverId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID,ShowActionPanel)
		Values(@RequestID, @ApproverId, @Comment, @username + ' commented on it.' ,@CreationDate,@isprintable,@visibleToUserId,@canReplyUserId,1)
	
		Select @RequestID
End





GO
/****** Object:  StoredProcedure [dbo].[ApproveRequest]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[ApproveRequest]
	@RequestID int,
	@ApproverID int,
	@ApprovalDate datetime,
	@Remarks varchar(500),
	@Status int,
	@UniqueId varchar(30)
As 
Begin
	

	BEGIN try
		Begin Transaction t1

	Declare @email_subj varchar(200)
	Declare @email_body varchar(500)
	Declare @to_email varchar(50)
	Declare @username varchar(100)


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

	
	-- Get email & Login of Approver
	Select @to_email = u.email, @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
	on a.UserID = u.UserID and a.ApproverID = @ApproverId



	INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable, VisibleToUserID,CanReplyUserID)
	Values(@RequestID, @ApproverID, @Remarks, @username + '  has ' + @statusText +' it.',@ApprovalDate,1,0,0)

	/*Email Handling Code */

	SET @email_subj = upper(@statusText) + ' SUCCESSFULLY ACAD/' + cast(@RequestID as varchar);
	SET @email_body = 'You have successfully ' + @statusText +' the application';
	
	--Email for approver
	INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus, UniqueID)
	Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId

	SET @email_subj = 'NOTIFICATION ACAD/' + cast(@RequestID as varchar);
	SET @email_body = 'Some action has been taken on your application, please login Student Request Portal for further information';

	SELECT @to_email = email from dbo.Users u INNER JOIN dbo.RequestMainData rmd on u.UserId = rmd.UserId and rmd.RequestID = @RequestID

	--Email for Student
	INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
	Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId



	--Update Request Status
	Declare @count int
	Select @count = count(*) from dbo.ReqWorkflow Where RequestID = @RequestID and Status IN (1,2)   -- 1 means notAssigned, 2 means Pending

	-- IF It was last approver or App is rejected
	if @count = 0 OR @Status = 4 
	BEGIN
		UPDATE [dbo].[RequestMainData] SET RequestStatus = @Status, LastModifiedOn = @ApprovalDate Where RequestID = @RequestID


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

			SET @email_subj = 'NEW APPLICATION ACAD/' + cast(@RequestID as varchar);
			SET @email_body = 'A new appication has been assigned to you, please login to Student Request Portal';

			--Select @to_email = email,@username= Designation + '(' + Name + ')' from dbo.Users where UserId = @nextApproverId

			Select @to_email = u.email, @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
			on a.UserID = u.UserID and a.ApproverID = @nextApproverId


			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
			Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable, VisibleToUserID,CanReplyUserID)
			Values(@RequestID, @ApproverID, 'Assigned By System', 'Request is assigned to ' + @username,@ApprovalDate,0,0,0)
		END
	END

		commit transaction t1
	end TRY
	Begin catch
		rollback transaction t1
	End catch
	
	Select @RequestID
End





GO
/****** Object:  StoredProcedure [dbo].[EnableDisableRequestEdit]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[EnableDisableRequestEdit]
	@RequestID int,
	@DateTime datetime,
	@ApproverId int,
	@flag bit,
	@remarks varchar(200)
As 
Begin
	   Update dbo.RequestMainData Set CanStudentEdit = @flag, [LastModifiedOn] = @DateTime Where RequestID = @RequestID

	   Declare @text varchar(20) = 'disabled'

	   if @flag = 1
	   begin
		Set @text = 'enabled'
	   end

		--Declare @username varchar(100)
		--Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @ApproverId

		Declare @username varchar(100)
		Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
		on a.UserID = u.UserID
		where a.ApproverID = @ApproverId


		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @ApproverId,'Application is ' + @text + ' for editing: ' + @remarks , @username + ' updated request.' ,@DateTime,0,0,0)
	
		Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[Find_Text_In_SP]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Find_Text_In_SP]
@StringToSearch varchar(100)
AS
BEGIN
SET @StringToSearch = '%' +@StringToSearch + '%'
SELECT Distinct SO.Name
FROM sysobjects SO (NOLOCK)
INNER JOIN syscomments SC (NOLOCK) on SO.Id = SC.ID
AND SO.Type = 'P'
AND SC.Text LIKE @stringtosearch
ORDER BY SO.Name

END
GO
/****** Object:  StoredProcedure [dbo].[GetActivityLogConversationData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetActivityLogConversationData]
	@RequestId int,
	@activityLogID int,
	@UserID int,
	@accessType int,
	@ApproverId int
As 
Begin

		declare @id int = @UserID
		if @accessType =2 --Assigned
		begin
			Set @id = @ApproverId
		end
		
		if dbo.IsValidLogId(@RequestId,@ActivityLogID,@id,@accessType) = 1
		begin
			Select al.*,u.Name as UserName 
			from [dbo].[ActivityLogConversations] al inner join dbo.Users u on al.UserID = u.UserId
			and al.ActivityLogID = @activityLogID
			Order by al.MessageTime desc
		end
		else 
		begin
			Select al.*,'' as UserName 
			from [dbo].[ActivityLogConversations] al where ConversationID =-1
		end
		
End
GO
/****** Object:  StoredProcedure [dbo].[GetActivityLogData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetActivityLogData]
	@RequestID int,
	@UserID int,
	@accessType int
As 
Begin

		--declare @RequestID int = 8
		--declare	@UserID int = 1
		--declare @accessType int =2
	
		Declare @approvers table (userid int)
		Declare @creatorId int = 0

		if @accessType = 1
		begin
			select @creatorId = UserId from dbo.RequestMainData where RequestID = @RequestID
		end
		else if @accessType = 2
		begin
			insert into @approvers
			Select distinct ApproverID from dbo.ReqWorkflow where RequestID = @RequestID
		end
		else
		begin
			insert into @approvers
			select @UserID
		end


		Select a.Id, a.RequestId, a.UserId, a.Comments, a.Activity, a.ActivityTime, a.IsPrintable, isnull(a.VisibleToUserID,0) as VisibleToUserID, isnull(a.CanReplyUserID,0) as CanReplyUserID,
				cast(case when a.UserId = @UserID then a.ShowActionPanel else 0 end as bit) as ShowActionPanel,
				'' as SignatureName, 
		cast(
			 (case  when a.ShowActionPanel = 0 then 0 else
					(case when a.UserID = @UserID then 1 else
							(case when isnull(a.CanReplyUserID,0) = 0 then 0 
							  when isnull(a.CanReplyUserID,0) = -1 AND @UserID IN (select userid from @approvers) then 1 
							  when isnull(a.CanReplyUserID,0) = -2  AND @UserID = @creatorId then 1 
							  when isnull(a.CanReplyUserID,0) = -3  AND (@UserID IN (select userid from @approvers) OR @UserID = @creatorId) then 1
							   when isnull(a.CanReplyUserID,0) > 0 AND isnull(a.CanReplyUserID,0) = @UserID  then 1
							  else 0 end) 
					 end ) 
			  end
			  
			  ) as bit) as CanReplyFlag
		from [dbo].[ActivityLogTable] a 
		Where a.RequestId = @RequestID 
		and (a.UserID = @UserID 
			OR ( isnull(a.VisibleToUserID,0) = 0  AND (@UserID IN (select userid from @approvers) OR @UserID = @creatorId))
			OR ( isnull(a.VisibleToUserID,0) = -1 AND @UserID IN (select userid from @approvers))
			OR ( isnull(a.VisibleToUserID,0) = -2 AND @UserID = @creatorId)
			OR ( isnull(a.VisibleToUserID,0) > 0 AND isnull(a.VisibleToUserID,0) = @UserID)
			)
		order by a.ActivityTime Desc, a.Id Desc
End


-- execute [dbo].[GetActivityLogData] 8,1,2

GO
/****** Object:  StoredProcedure [dbo].[GetAppCountByStatus]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[GetAppCountByStatus]
	@accessType int,
	@userid int
AS 
BEGIN


	--Declare @accessType int = 1
	--Declare @userid int = 1021


	if @accessType = 1  OR @accessType = 4 --It means self created or All
	BEGIN
		select isnull(count(*),0) as 'All',
		isnull(Sum(case when RequestStatus = 2 OR RequestStatus = 6  then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when RequestStatus = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when RequestStatus = 4 then 1 else 0 end),0) 'Rejected',
		0 as 'NotAssigned',
		0 as 'RejectedBeforeAssignment'
		from [dbo].[RequestMainData] Where UserId = case when @accessType = 1 then @userid else UserId end
	END
	ELSE if @accessType = 2  --It means assigned
	BEGIN
		select isnull(sum(case when rwf.Status = 5 then 0 else 1 end),0) as 'All',
		isnull(Sum(case when rwf.Status = 2 then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when rwf.Status = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when rwf.Status = 4 then 1 else 0 end),0) 'Rejected',
		isnull(Sum(case when rwf.Status = 1 then 1 else 0 end),0) 'NotAssigned'
		from [dbo].[RequestMainData] rmd INNER JOIN [dbo].[ReqWorkflow] rwf on  rwf.RequestID = rmd.RequestID

		Where rwf.ApproverID = @userid
	END

END

GO
/****** Object:  StoredProcedure [dbo].[GetApproversByRequestId]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetApproversByRequestId]
@requestId int
As 
Begin
	--Declare @requestId int
	--Set @requestId = 18
	Select a.ApproverID as UserId, u.Login, u.Name, a.Designation, u.Email, rwf.Status as WorkFlowStatus
	from [dbo].[ReqWorkflow] rwf inner join dbo.Approvers a on rwf.ApproverID = a.ApproverID
	INNER JOIN dbo.Users u on a.UserID = u.UserID
	Where rwf.RequestID = @requestId
	Order by rwf.ApprovalOrder 
End
GO
/****** Object:  StoredProcedure [dbo].[GetEmailRequestsByUniqueID]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[GetEmailRequestsByUniqueID]
	@UniqueID varchar(30)
AS 
BEGIN
	
	Select * from dbo.EmailRequests
	Where UniqueID = @UniqueID

END



GO
/****** Object:  StoredProcedure [dbo].[GetRequestAccessParams]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[GetRequestAccessParams]
@RequestId int,
@accessType int,
@currUserId int,
@OnlyValidateRequest bit
As 
Begin

	--input variables
	--Declare @RequestId int = 13
	--Declare @accessType int =0
	--Declare @currUserId int = 8

	--output
	Declare @RecFlag bit = 0
	Declare @RouteBackFlag bit =0
	Declare @canStdEditFlag bit = 0
	Declare @IsPendingForCurrUser bit =0
	Declare @IsValidAccess bit = 0
	Declare @AppStatus int =0

	if @accessType = 1  --It means self created
	BEGIN
		if(SELECT count(*) from [dbo].[RequestMainData] where RequestID = @requestId and UserID = @currUserId) > 0
		BEGIN
			SET @IsValidAccess = 1
		END
	END
	ELSE if @accessType = 2  --It means assigned
	BEGIN
		if(Select count(*) from [dbo].[ReqWorkflow] where RequestID = @requestId and ApproverID = @currUserId) > 0
		BEGIN
			SET @IsValidAccess = 1
		END
	END
	ELSE if @accessType = 4 --It means All
	BEGIN
		SET @IsValidAccess = 1
	END


	If @OnlyValidateRequest = 0 AND @IsValidAccess = 1
	BEGIN
		--local variables
		Declare @isParallelAllowed bit =0
		Declare @data table(ID int identity(1,1), ReqWFID int, ApproverID int, Status int, IsCurrApprover bit)

		Insert into @data(ReqWFID,ApproverID,Status,IsCurrApprover)
		Select ID,ApproverID,Status,IsCurrApprover from dbo.ReqWorkflow Where RequestID = @RequestId order by ID

		
		-- If Category allows Reciving, Request is approved and Recieving is not done yet
		Select @RecFlag = case when fc.IsRecievingAllowed = 1 AND rm.IsRecievingDone =0 AND rm.RequestStatus = 3 then 1 else 0 end,
		@isParallelAllowed = IsParalApprovalAllowed,
		@canStdEditFlag = case @accessType when 1 then rm.CanStudentEdit else 0 end,
		@AppStatus = rm.RequestStatus
		from [dbo].[FormCategories] fc 
		inner join [dbo].[RequestMainData] rm on fc.CategoryID = rm.CategoryID and rm.RequestID = @RequestId


		-- Check if currently pending for current user
		if exists(select top 1 * from @data Where ApproverID = @currUserId and Status = 2 and IsCurrApprover = 1)
		Begin
			SET @IsPendingForCurrUser = 1
		End

		-- request is assigned to current user, not parallel approvers allowed and it current user is not first approver
		if(@isParallelAllowed = 0 
		and (select count(*) from @data where Status IN (3,4 )) > 0
		and @IsPendingForCurrUser = 1)
		begin 
		 SET @RouteBackFlag = 1
		end
	END

	SELECT @IsValidAccess as IsValidAccess, @RecFlag as RecFlag,@RouteBackFlag as RouteBackFlag, @canStdEditFlag as CanStdEditFlag,@IsPendingForCurrUser as IsPendingForCurrUser, @AppStatus as AppStatus

End

-- execute dbo.GetRequestAccessParams 2,2,8,0
GO
/****** Object:  StoredProcedure [dbo].[GetRolePermissionById]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[GetRolePermissionById]
	@ApproverId int
AS 
BEGIN
		Select distinct r.* from dbo.Roles r INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @ApproverId and ur.IsApproverIdInUserID = 1

		Select distinct p.*,pm.RoleId from dbo.Permissions p 
		INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
		INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @ApproverId and ur.IsApproverIdInUserID = 1

END

/*
declare @date datetime = getdate()
execute dbo.ValidateUser 'BITF13M005','123',@date,'123'
select * from dbo.LoginHistory

*/


GO
/****** Object:  StoredProcedure [dbo].[HandleRecieving]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[HandleRecieving]
	@RequestID int,
	@ApproverId int,
	@CreationDate datetime,
	@Comment varchar(200)
As 
Begin

		Update dbo.RequestMainData SET IsRecievingDone = 1 where RequestID = @RequestID

		--Declare @username varchar(100)
		--Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @ApproverId

		Declare @username varchar(100)
		Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
		on a.UserID = u.UserID
		where a.ApproverID = @ApproverId


		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable)
		Values(@RequestID, @ApproverId, @Comment, @username + ' has performed recieving activity.' ,@CreationDate,0)
	
		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable)
		Values(@RequestID, @ApproverId, '', 'Application is closed now!' ,@CreationDate,0)

		Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[IsRequestIDValid]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[IsRequestIDValid]
	@requestId int,
	@userid int,
	@accessType int
AS 
BEGIN

	if @accessType = 1  --It means self created
	BEGIN
		SELECT count(*) from [dbo].[RequestMainData] where RequestID = @requestId and UserID = @userid
	END
	ELSE if @accessType = 2  --It means assigned
	BEGIN
		Select count(*) from [dbo].[ReqWorkflow] where RequestID = @requestId and ApproverID = @userid
	END
	ELSE if @accessType = 4 --It means All
	BEGIN
		Select 1
	END

END
GO
/****** Object:  StoredProcedure [dbo].[RemoveAttachment]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[RemoveAttachment]
	@RequestID int,
	@attachment varchar(50),
	@DateTime datetime,
	@UserId int
As 
Begin
	   Update dbo.Attachments SET IsActive = 0 Where [FileName] = @attachment

	   Declare @fileName varchar(50)
	   
	   Select @fileName = typeName from dbo.AttachmentTypes where AttachmentTypeID = (Select AttachmentTypeID from dbo.Attachments Where [FileName] = @attachment)

	   Declare @username varchar(100)
		Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, 'Attachment [' + @fileName + '] has been removed', @username + ' removed a file.' ,@DateTime,0,0,0)
	
		Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[RouteBack]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[RouteBack]
	@RequestID int,
	@ApproverID int,
	@ApprovalDate datetime,
	@Remarks varchar(500),
	@UniqueId varchar(30)
As 
Begin

	Declare @email_subj varchar(200)
	Declare @email_body varchar(500)
	Declare @to_email varchar(50)
	Declare @username varchar(100)

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
			
			SET @email_subj = 'APPLICATION ACAD/' + cast(@RequestID as varchar);
			SET @email_body = 'An appication has been un-assigned from you, please login to Student Request Portal';
			--Select @to_email = email,@username= Designation + '(' + Name + ')' from dbo.Users where UserId = @ApproverID

			Select @to_email = u.email, @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
			on a.UserID = u.UserID and a.ApproverID = @ApproverId



			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
			Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
			Values(@RequestID, @ApproverID, @Remarks, 'Request is [Routed Back] By ' + @username + ' to previous approver',@ApprovalDate)

			
			-- Mark Last approver status as 'Pending'
			Update dbo.ReqWorkflow Set Status = 2,StatusTime = @ApprovalDate,IsCurrApprover=1 where ID =@rwfId

			SET @email_subj = 'APPLICATION ACAD/' + cast(@RequestID as varchar);
			SET @email_body = 'An appication has been re-assigned to you, please login to Student Request Portal';
			
			-- Select @to_email = email,@username= Designation + '(' + Name + ')' from dbo.Users where UserId = @prevApproverId

			Select @to_email = u.email, @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
			on a.UserID = u.UserID and a.ApproverID = @prevApproverId


			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
			Select @email_subj, @email_body, @to_email, 1, 1, @UniqueId

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
			Values(@RequestID, @ApproverID, 'Routed Back:' + @Remarks, 'Request is re-assigned to ' + @username,@ApprovalDate)

			Select @RequestID
		END
		ELSE 
		BEGIN
			Select cast(-1 as int)
		END
		
		
End


-- execute [dbo].RouteBack 13,0,'1/1/2013',0


GO
/****** Object:  StoredProcedure [dbo].[SaveAttachment]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SaveAttachment]
	@RequestID int,
	@fileName varchar(100),
	@attachment varchar(50),
	@CreationDate datetime,
	@UserId int
As 
Begin
	   Declare @typeId int
	   Select @typeId = AttachmentTypeID from dbo.AttachmentTypes where typeName = @fileName

	   if @typeId is null
	   Begin
		INSERT INTO dbo.AttachmentTypes(typeName) 
		Select @fileName
		Select @typeId = SCOPE_IDENTITY()
	   End 
	   
	   Insert into dbo.Attachments(RequestID, AttachmentTypeID, UploadDate, IsActive, FileName)
	   Select @RequestID, @typeId, @CreationDate, 1, @attachment


		Declare @username varchar(100)
		Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, '[' + @fileName + '] is uploaded', @username + ' uploaded a file.' ,@CreationDate,0,0,0)
	
		Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[SaveLogConversation]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SaveLogConversation]
	@RequestId int,
	@ActivityLogID bigint,
	@UserID int,
	@accessType int,
	@MessageTime datetime,
	@Message varchar(200),
	@ApproverId int
	
As 
Begin
		
		declare @id int = @UserID
		if @accessType =2 --Assigned
		begin
			Set @id = @ApproverId
		end

		if dbo.IsValidLogId(@RequestId,@ActivityLogID,@id,@accessType) = 1
		begin
			INSERT INTO [dbo].[ActivityLogConversations](ActivityLogID, UserID, Message, MessageTime)
			Values(@ActivityLogID,@UserID,@Message,@MessageTime)
			Select cast(SCOPE_IDENTITY() as bigint)
		end
		else
		begin
			select cast(-1 as bigint)
		end
		
End







GO
/****** Object:  StoredProcedure [dbo].[SaveRequest]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




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
	@UniqueId varchar(30)	

As 
Begin

	IF @RequestID = 0
	BEGIN

		Declare @IsOldCampus bit
		Declare @to_email varchar(50)
		Select @IsOldCampus= IsOldCampus, @to_email = email from dbo.Users where UserId = @UserId



		INSERT INTO [dbo].[RequestMainData](CategoryID, UserId, RollNo, CreationDate, TargetSemester, Reason, TargetDate, CurrentSemester,  RequestStatus, Subject)
		Values(@CategoryID, @UserId, @RollNo, @CreationDate, @TargetSemester, @Reason, @TargetDate, @CurrentSemester,   @Status, @Subject)

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
		Where ah.FormID = @CategoryID and (IsForNewCampus = (case when @IsOldCampus = 0 then 1 else 0 end) OR IsForOldCampus = (case when @IsOldCampus = 1 then 1 else 0 end))
		

		ORDER By ApprovalOrder
		

		DECLARE @TempTable TABLE (ID INT Identity(1,1), WFID INT)
		Declare @TempID int = 1
		Declare @WFID int = 0


		INSERT INTO @TempTable(WFID)
		Select ID  From [dbo].[ReqWorkflow] Where [RequestID] = @RequestID and Status = 2
		
		Declare @TotalWFCount int 
		Select @TotalWFCount = Count(*) from @TempTable


		-- Add email entry for approver
		Declare @email_subj varchar(200) = 'NEW APPLICATION ALERT - ACAD/' + cast(@RequestID as varchar);
		Declare @email_body varchar(500) = 'You have received a new ' + @formName +' APPLICATION From Roll no: ' + @RollNo + ' , please login to Student Request Portal'
		
		Declare @nextApproverUserId int
		Declare @username varchar(100)
		-----------------------------------------------------------


		While @TempID <= @TotalWFCount
		BEGIN 

			Select @WFID = WFID from @TempTable Where ID = @TempID

			Select @to_email = email,@nextApproverUserId = rwf.UserID  from [dbo].[ReqWorkflow] rwf inner join dbo.Users u on rwf.UserID = u.UserId
			Where ID = @WFID

			Select @to_email = email,@username= Designation + '(' + Name + ')' from dbo.Users where UserId = @nextApproverUserId

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,VisibleToUserID,CanReplyUserID)
			Values(@RequestID, @UserId, 'Assigned By System', 'Request is assigned to ' + @username,@CreationDate,0,0)
			-----------------------------------------------------------

			INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
			Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId

			SET @TempID = @TempID + 1

		END


		-- Add email entry for requester
		SET @email_subj = 'APPLICATION SUBMITTED - ACAD/' + cast(@RequestID as varchar);
		SET @email_body = 'Your ' + @formName +' APPLICATION has been sent successfully, please login Student Request Portal for further information';
		
		
		INSERT INTO [dbo].[EmailRequests](Subject, MessageBody, EmailTo, ScheduleType, EmailRequestStatus,UniqueID)
		Select @email_subj, @email_body, @to_email, 1, 1,@UniqueId


	END

	Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[SearchApplications]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SearchApplications]
	@rollNo varchar(50),
	@name varchar(50),
	@startDate date,
	@endDate date,
	@status int,
	@category int,
	@accessType int,
	@userid int
AS 
BEGIN
	
	--Declare @rollNo varchar(50) = ''
	--Declare @name varchar(50) = ''
	--Declare @startDate date =  '1900-01-01'
	--Declare @endDate date = '2100-01-01'
	--Declare @status int = 6
	--Declare @category int = 0
	--Declare @accessType int = 1
	--Declare @userid int = 1021


	if @accessType = 1  --It means self created
	BEGIN
		SELECT rmd.RequestID as ApplicationId, rmd.RollNo, rmd.CreationDate as EntryTime, fc.Category as [Subject], rmd.RequestStatus as Status
		from [dbo].[RequestMainData] rmd 
		INNER JOIN [dbo].[FormCategories] fc ON rmd.CategoryID = fc.CategoryID
		WHERE UserId = @userid
		AND (cast(rmd.CreationDate as date) Between @startDate and @endDate) 
		AND rmd.CategoryID = (case when @category > 0 then @category else rmd.CategoryID end)
		AND rmd.RequestStatus = (case when @status > 0 then @status else rmd.RequestStatus end)
		Order by rmd.CreationDate DESC
	END
	ELSE if @accessType = 2  --It means assigned
	BEGIN
		SELECT rmd.RequestID as ApplicationId, rmd.RollNo, rmd.CreationDate as EntryTime, fc.Category as [Subject], rwf.Status
		from [dbo].[RequestMainData] rmd 
		INNER JOIN [dbo].[FormCategories] fc ON rmd.CategoryID = fc.CategoryID
		INNER JOIN [dbo].[ReqWorkflow] rwf on rwf.RequestID = rmd.RequestID
		INNER JOIN dbo.Users u on u.UserId = rmd.UserId
		WHERE u.Login like '%' + @rollNo +'%'
		AND u.Name like '%' + @name +'%'
		AND (cast(rmd.CreationDate as date) Between @startDate and @endDate) 
		AND rmd.CategoryID = (case when @category > 0 then @category else rmd.CategoryID end)
		AND rwf.Status = (case when @status > 0 then @status else rwf.Status end) AND rwf.Status != 5 
		And rwf.ApproverID = @userid
		Order by rmd.CreationDate DESC
	END
	ELSE if @accessType = 4 --It means All
	BEGIN
		SELECT rmd.RequestID as ApplicationId, rmd.RollNo, rmd.CreationDate as EntryTime, fc.Category as [Subject] , rmd.RequestStatus as Status
		from [dbo].[RequestMainData] rmd 
		INNER JOIN [dbo].[FormCategories] fc ON rmd.CategoryID = fc.CategoryID
		INNER JOIN dbo.Users u on u.UserId = rmd.UserId
		WHERE u.Login like '%' + @rollNo +'%'
		AND u.Name like '%' + @name +'%'
		AND (cast(rmd.CreationDate as date) Between @startDate and @endDate) 
		AND rmd.CategoryID = (case when @category > 0 then @category else rmd.CategoryID end)
		AND rmd.RequestStatus = (case when @status > 0 then @status else rmd.RequestStatus end)
		Order by rmd.CreationDate DESC
	END

END
GO
/****** Object:  StoredProcedure [dbo].[SearchApprover]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SearchApprover]
@key varchar(20)
As 
Begin
	
	Select a.ApproverID as UserId, u.Login, u.Name, a.Designation, u.Email, 0 as WorkFlowStatus
	from dbo.Approvers a INNER JOIN dbo.Users u on a.UserID = u.UserID and u.IsContributor = 1
	where a.Designation like '%' +@key+ '%' 
	OR u.Name like '%' +@key+ '%' 
	order by u.Name	
End
GO
/****** Object:  StoredProcedure [dbo].[UpdateActivityLogActionItem]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[UpdateActivityLogActionItem]
	@RequestID int,
	@ActID int,
	@DateTime datetime,
	@UserId int,
	@type int,
	@value int	
As 
Begin

	IF @type = 1 
	BEGIN
	 Update [dbo].[ActivityLogTable]
	 SET VisibleToUserID = @value, UpdatedTime = @DateTime
	 Where Id = @ActID and UserId = @UserId and RequestId = @RequestID
	END

	IF @type = 2
	BEGIN
	 Update [dbo].[ActivityLogTable]
	 SET CanReplyUserID = @value, UpdatedTime = @DateTime
	 Where Id = @ActID and UserId = @UserId and RequestId = @RequestID
	END
	  
	select cast(1 as int)
End







GO
/****** Object:  StoredProcedure [dbo].[UpdateAttachment]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[UpdateAttachment]
	@RequestID int,
	@attachment varchar(50),
	@Datetime datetime,
	@UserId int,
	@oldattachment varchar(50)
As 
Begin

	   Declare @fileName varchar(50)
	   Select @fileName = typeName from dbo.AttachmentTypes where AttachmentTypeID = (Select AttachmentTypeID from dbo.Attachments Where [FileName] = @oldattachment)
	   
	   Update dbo.Attachments SET FileName = @attachment Where FileName = @oldattachment

		Declare @username varchar(100)
		Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @UserId

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID)
		Values(@RequestID, @UserId, '[' + @fileName + '] is uploaded again', @username + ' updated a file.' ,@Datetime,0,0,0)
	
		Select @RequestID
End







GO
/****** Object:  StoredProcedure [dbo].[UpdateCGPA]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[UpdateCGPA]
	@RequestID int,
	@CGPA float,
	@DateTime datetime,
	@ApproverId int
As 
Begin

	Declare @old_cgpa float =0

	select @old_cgpa=isnull(CGPA,0) from [dbo].[BonafideCertificateData] Where RequestID  = @RequestID

	Update t SET CGPA = @CGPA, UpdatedTime = @DateTime, ModifiedBy = @ApproverId
	from [dbo].[BonafideCertificateData] t inner join dbo.RequestMainData rmc on t.RequestID = rmc.RequestID and rmc.CategoryID = 8
	Where t.RequestID  = @RequestID  
	 
	
		Declare @username varchar(100)
		Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
		on a.UserID = u.UserID
		where a.ApproverID = @ApproverId

	INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime,IsPrintable,VisibleToUserID,CanReplyUserID,ShowActionPanel)
	Values(@RequestID, @ApproverId, 'CGPA is updated from ['+cast(@old_cgpa as varchar)+'] to ['+ cast(@CGPA as varchar)+']', @username + ' update CGPA.' ,@DateTime,0,0,0,0)
	

	  
	select cast(1 as int)
End







GO
/****** Object:  StoredProcedure [dbo].[UpdateWorkFlow]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[UpdateWorkFlow]
@idsStr varchar(100),
@requestId int,
@ApproverId int,
@currentTime datetime
As 
Begin

	--Declare @currUserName varchar(100)	
	--Select @currUserName= Designation + '(' + Name + ')' from dbo.Users where UserId = @ApproverId

	Declare @currUserName varchar(100)
	Select @currUserName= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
	on a.UserID = u.UserID
	where a.ApproverID = @ApproverId

	Declare @IsParalApprovalAllowed bit  = 0 
	Declare @DefaultStatusForWF int = 1

	Select @DefaultStatusForWF = case IsParalApprovalAllowed when 1 then 2 else 1 end
	from [dbo].[FormCategories] fc inner join dbo.RequestMainData rm on fc.CategoryID = rm.CategoryID and rm.RequestID = @requestId


	Declare @ids table(id int identity(1,1), userid bigint)
	Declare @delTbl table(id int identity(1,1), userid bigint,wfid int)
	Declare @insertTbl table(id int identity(1,1), userid bigint)
	Declare @updateTbl table(id int identity(1,1), userid bigint,wfid int)

	-- Convert data into table from comma separated string
	insert into @ids(userid)
	SELECT Value FROM dbo.split1 ( @idsStr ) 

	-- Find which records need to be removed
	insert into @delTbl(userid,wfid)
	Select ApproverID,ID from [dbo].[ReqWorkflow] 
	where RequestID = @requestId 
	and ApproverID NOT IN (Select userid from @ids)
	
	-- Find which IDs are neither removed/added
	insert into @updateTbl(userid,wfid)
	Select u.ApproverID,u.ID from [dbo].[ReqWorkflow] u 
	inner join @ids d on u.ApproverID = d.UserID 
	and u.RequestID =@requestId and u.Status = 1 --(Not Assigned)

	-- Delete which are removed
	Delete from dbo.ReqWorkflow where ID in (select wfid from @delTbl)
	-- Delete which were neither removed/added
	Delete from dbo.ReqWorkflow where ID in (select wfid from @updateTbl)

	-- Find all records which should be added
	insert into @insertTbl(userid)
	Select d.userid from @ids d where d.userid not in(
		Select ApproverID from [dbo].[ReqWorkflow] 
		where RequestID = @requestId )
	order by d.id asc


	Declare @count int
	Declare @counter int = 1
	Declare @userid bigint
	Declare @wfid int
	Declare @username varchar(100)

	Select @count = count(*) from @delTbl

	While @counter <= @count
	Begin
		Select @userid = userid
		from @delTbl where id = @counter

		Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
		on a.UserID = u.UserID
		where a.ApproverID = @userid

		--Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @userid

		INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
		Values(@RequestID, @ApproverId, @username + ' is removed from contributors.', @currUserName + ' made a change in contributors.' ,@currentTime)	 

		SET @counter = @counter + 1
	End

	Declare @maxApprOrder int  =0 
	Declare @actualUserId int =0
	Select @maxApprOrder = max(ApprovalOrder) from dbo.ReqWorkflow Where RequestID = @requestId

	Select @count = count(*) from @insertTbl
	SET @counter = 1

	While @counter <= @count
	Begin
		Select @userid = userid from @insertTbl where id = @counter

		if( NOT Exists(Select * from @updateTbl where userid = @userid))
		BEGIN

			Select @username= a.Designation + '(' + u.Name + ')' from dbo.Users u inner join dbo.Approvers a
			on a.UserID = u.UserID
			where a.ApproverID = @userid


			--Select @username= Designation + '(' + Name + ')' from dbo.Users where UserId = @userid

			INSERT INTO [dbo].[ActivityLogTable](RequestId, UserId, Comments, Activity, ActivityTime)
			Values(@RequestID, @ApproverId, @username + ' is added in contributors.', @currUserName + ' made a change in contributors.' ,@currentTime)	 
		END

		select @actualUserId = userid from dbo.Approvers where ApproverID = @userid


		INSERT INTO [dbo].[ReqWorkflow](RequestID, ApproverID, ApprovalOrder, Status, Remarks, EntryTime, ActionUserID,UserID)
		Select @requestId, @userid, isnull(@maxApprOrder,0) + @counter, @DefaultStatusForWF,'',@currentTime,@userid,@actualUserId

		SET @counter = @counter + 1
	End

	Select 1 as int;
End



-- execute dbo.UpdateWorkFlow '100,1002'
GO
/****** Object:  StoredProcedure [dbo].[ValidateUser]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[ValidateUser]
	@Login varchar(50),
	@Password varchar(50),
	@CurrTime datetime,
	@MachineIP varchar(20)
AS 
BEGIN
	Declare @UserId int = 0
	Declare @iscontributor bit =0

	SELECT @UserId=UserId, @iscontributor=IsContributor from dbo.Users u where Login = @Login and Password = @Password and isActive = 1

	Select * from dbo.Users where UserID = @UserId

	if @UserId > 0
	BEGIN
		
		
		

		if @iscontributor = 1
		begin

			Declare @approvers table (ApproverID int,Designation varchar(50),UserID int,IsActive bit)

			insert into @approvers select * from dbo.Approvers where UserID = @UserId

			select * from @approvers

			Declare @approverid int
			select top 1 @approverid = ApproverId from @approvers

			select @approverid

			Select distinct r.* from dbo.Roles r INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @approverid and ur.IsApproverIdInUserID = 1

			Select distinct p.*,pm.RoleId from dbo.Permissions p 
			INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
			INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @approverid and ur.IsApproverIdInUserID = 1

		end
		else 
		begin
			Select distinct r.* from dbo.Roles r INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @UserId

			Select distinct p.*,pm.RoleId from dbo.Permissions p 
			INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
			INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @UserId
		end
	
		INSERT INTO dbo.LoginHistory(UserID, LoginID, MachineIP, LoginTime)
		Select @UserId,@Login,@MachineIP,@CurrTime
	END

END

/*
declare @date datetime = getdate()
execute dbo.ValidateUser 'BITF13M005','123',@date,'123'
select * from dbo.LoginHistory

*/


GO
/****** Object:  UserDefinedFunction [dbo].[IsValidLogId]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[IsValidLogId]
(
	@RequestID int,
	@ActivityLogID bigint,
	@UserID int,
	@accessType int
)
RETURNS bit
AS
BEGIN
	
	Declare @output bit = 0
	Declare @approvers table (userid int)
	Declare @creatorId int = 0

	if @accessType = 1
	begin
		select @creatorId = UserId from dbo.RequestMainData where RequestID = @RequestID
	end
	if @accessType = 2
	begin
		insert into @approvers
		Select distinct ApproverID from dbo.ReqWorkflow where RequestID = @RequestID
	end

	if exists(Select * from 
			[dbo].[ActivityLogTable] a 
			Where a.Id =@ActivityLogID
			and (a.UserID = @UserID 
				OR ( isnull(a.VisibleToUserID,0) = 0  AND (@UserID IN (select userid from @approvers) OR @UserID = @creatorId))
				OR ( isnull(a.VisibleToUserID,0) = -1 AND @UserID IN (select userid from @approvers))
				OR ( isnull(a.VisibleToUserID,0) = -2 AND @UserID = @creatorId)
				OR ( isnull(a.VisibleToUserID,0) > 0 AND a.VisibleToUserID = @UserID)
				)

				)
				begin
					SET @output = 1
				end

		return @output
END

GO
/****** Object:  UserDefinedFunction [dbo].[Split1]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split1](@input AS Varchar(4000) )
RETURNS
      @Result TABLE(Value BIGINT)
AS
BEGIN
      DECLARE @str VARCHAR(20)
      DECLARE @ind Int
      IF(@input is not null)
      BEGIN
            SET @ind = CharIndex(',',@input)
            WHILE @ind > 0
            BEGIN
                  SET @str = SUBSTRING(@input,1,@ind - 1)
                  SET @input = SUBSTRING(@input,@ind+1,LEN(@input)-@ind)
                  INSERT INTO @Result values (@str)
                  SET @ind = CharIndex(',',@input)
            END
            SET @str = @input
            INSERT INTO @Result values (@str)
      END
      RETURN
END
GO
/****** Object:  Table [dbo].[ActivityLogConversations]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActivityLogConversations](
	[ConversationID] [bigint] IDENTITY(1,1) NOT NULL,
	[ActivityLogID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[Message] [varchar](200) NOT NULL,
	[MessageTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ActivityLogConversations] PRIMARY KEY CLUSTERED 
(
	[ConversationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ActivityLogTable]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActivityLogTable](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RequestId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Comments] [varchar](max) NULL,
	[Activity] [varchar](max) NOT NULL,
	[ActivityTime] [datetime] NOT NULL,
	[IsPrintable] [bit] NULL,
	[VisibleToUserID] [int] NULL,
	[CanReplyUserID] [int] NULL,
	[ShowActionPanel] [bit] NOT NULL,
	[UpdatedTime] [datetime] NULL,
 CONSTRAINT [PK_ActivityLogTable] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ApproverHierarchy]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApproverHierarchy](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FormID] [int] NOT NULL,
	[ApproverID] [int] NOT NULL,
	[AltApproverID] [int] NULL,
	[ApprovalOrder] [int] NOT NULL,
	[IsForNewCampus] [bit] NULL,
	[IsForOldCampus] [bit] NULL,
 CONSTRAINT [PK_ApproverHierarchy] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Approvers]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Approvers](
	[ApproverID] [int] IDENTITY(1,1) NOT NULL,
	[Designation] [varchar](50) NOT NULL,
	[UserID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Approvers] PRIMARY KEY CLUSTERED 
(
	[ApproverID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Attachments]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Attachments](
	[AttachmentID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[AttachmentTypeID] [int] NOT NULL,
	[UploadDate] [datetime] NOT NULL,
	[IsActive] [int] NULL,
	[FileName] [varchar](200) NOT NULL,
	[Description] [varchar](500) NULL,
 CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttachmentTypes]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttachmentTypes](
	[AttachmentTypeID] [int] IDENTITY(1,1) NOT NULL,
	[typeName] [varchar](50) NOT NULL,
	[description] [text] NULL,
 CONSTRAINT [PK_AttachmentTypes] PRIMARY KEY CLUSTERED 
(
	[AttachmentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BonafideCertificateData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BonafideCertificateData](
	[RequestID] [int] NOT NULL,
	[CGPA] [float] NOT NULL,
	[ChallanForm] [varchar](15) NOT NULL,
	[PUreg] [varchar](50) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UpdatedTime] [datetime] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_BonafideCertificateData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CollegeIDCardData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CollegeIDCardData](
	[RequestID] [int] NOT NULL,
	[serialNo] [int] NULL,
	[issueDate] [datetime] NULL,
	[ExpiryDate] [datetime] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ChallanForm] [varchar](50) NOT NULL,
 CONSTRAINT [PK_CollegeIDCardData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CourseWithdrawal]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CourseWithdrawal](
	[RequestID] [int] NOT NULL,
	[CourseID] VARCHAR (50) NOT NULL,
	[CourseTitle] [varchar](100) NOT NULL,
	[CreditHours] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_CourseWithdrawal] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmailRequests]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmailRequests](
	[EmailRequestID] [bigint] IDENTITY(1,1) NOT NULL,
	[Subject] [varchar](150) NOT NULL,
	[MessageBody] [varchar](500) NOT NULL,
	[MessageParameters] [varchar](500) NULL,
	[EmailTo] [varchar](200) NOT NULL,
	[EmailCC] [varchar](200) NULL,
	[EmailBCC] [varchar](200) NULL,
	[EmailTemplate] [varchar](50) NULL,
	[ScheduleType] [int] NOT NULL,
	[ScheduleTime] [datetime] NULL,
	[EmailRequestStatus] [int] NOT NULL,
	[EntryTime] [datetime] NULL,
	[UniqueID] [varchar](30) NULL,
 CONSTRAINT [PK_EmailRequests] PRIMARY KEY CLUSTERED 
(
	[EmailRequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FinalTranscriptData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FinalTranscriptData](
	[RequestID] [int] NOT NULL,
	[FYPtitle] [varchar](50) NOT NULL,
	[PUreg] [varchar](50) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_FinalTranscriptData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FormCategories]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FormCategories](
	[CategoryID] [int] NOT NULL,
	[Category] [varchar](100) NOT NULL,
	[IsParalApprovalAllowed] [bit] NOT NULL,
	[IsRecievingAllowed] [bit] NOT NULL,
	[Instructions] [varchar](500) NULL,
 CONSTRAINT [PK_FormCategories] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LeaveApplicationForm]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LeaveApplicationForm](
	[RequestID] [int] NOT NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_LeaveApplicationForm] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LoginHistory]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoginHistory](
	[LoginHistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[LoginID] [varchar](50) NOT NULL,
	[MachineIP] [varchar](20) NOT NULL,
	[LoginTime] [datetime] NOT NULL,
 CONSTRAINT [PK_LoginHistory] PRIMARY KEY CLUSTERED 
(
	[LoginHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OptionForBscDegree]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[OptionForBscDegree](
	[RequestID] [int] NOT NULL,
	[CNIC] [nchar](15) NOT NULL,
	[dateOfBirth] [datetime] NOT NULL,
	[PUreg] [varchar](50) NOT NULL,
	[fatherSign] [varchar](50) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_OptionForBscDegree] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Permissions]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Permissions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PermissionsMapping]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermissionsMapping](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[PermissionId] [int] NOT NULL,
 CONSTRAINT [PK_PermissionsMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ReceiptOfOrignalEducationalDocuments]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReceiptOfOrignalEducationalDocuments](
	[RequestID] [int] NOT NULL,
	[DocumentName] [varchar](100) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_ReceiptOfOrignalEducationalDocuments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestMainData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequestMainData](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[RollNo] [varchar](20) NOT NULL,
	[CreationDate] [datetime] NULL,
	[TargetSemester] [int] NULL,
	[Reason] [varchar](200) NULL,
	[TargetDate] [date] NULL,
	[CurrentSemester] [int] NULL,
	[RequestStatus] [int] NOT NULL,
	[Subject] [varchar](50) NULL,
	[LastModifiedOn] [datetime] NULL,
	[IsRecievingDone] [bit] NULL,
	[CanStudentEdit] [bit] NULL,
 CONSTRAINT [PK_RequestMainData] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReqWorkflow]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReqWorkflow](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[ApproverID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[AltApproverID] [int] NULL,
	[ApprovalOrder] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Remarks] [text] NULL,
	[EntryTime] [datetime] NOT NULL,
	[StatusTime] [datetime] NULL,
	[ActionUserID] [int] NOT NULL,
	[UpdateTime] [datetime] NULL,
	[IsCurrApprover] [bit] NULL,
 CONSTRAINT [PK_ReqWorkflow] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Roles]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](50) NOT NULL,
    [IsActive]    BIT          DEFAULT ((1)) NOT NULL,
    [CreatedBy]   INT          NOT NULL,
    [CreatedOn]   DATETIME     DEFAULT (getdate()) NOT NULL,
    [Modifiedby]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SemesterAcademicTranscript]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SemesterAcademicTranscript](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NULL,
	[ChallanNo] [varchar](50) NULL,
 CONSTRAINT [PK_SemesterAcademicTranscript] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SemesterRejoinData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SemesterRejoinData](
	[RequestID] [int] NOT NULL,
	[withDrawApplicationNo] [varchar](50) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SemesterRejoinData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatusTypes]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatusTypes](
	[StatusTypeID] [int] NOT NULL,
	[StatusType] [varchar](20) NOT NULL,
 CONSTRAINT [PK_StatusTypes] PRIMARY KEY CLUSTERED 
(
	[StatusTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserRoleID] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[IsApproverIdInUserID] [bit] NOT NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Login] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Designation] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[isActive] [bit] NULL,
	[SignatureName] [varchar](50) NULL,
	[StdFatherName] [varchar](100) NULL,
	[Section] [varchar](25) NULL,
	[IsContributor] [bit] NULL,
	[IsOldCampus] [bit] NOT NULL,
 CONSTRAINT [PK_Users_1] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VehicalTokenData]    Script Date: 7/19/2017 6:26:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VehicalTokenData](
	[RequestID] [int] NOT NULL,
	[VehicalRegNo] [varchar](50) NOT NULL,
	[Model] [varchar](10) NOT NULL,
	[Manufacturer] [varchar](50) NOT NULL,
	[ownerName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_VehicalTokenData] PRIMARY KEY CLUSTERED 
(
	[VehicalRegNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[ActivityLogTable] ADD  CONSTRAINT [DF__ActivityL__IsPri__2739D489]  DEFAULT ((0)) FOR [IsPrintable]
GO
ALTER TABLE [dbo].[ActivityLogTable] ADD  DEFAULT ((0)) FOR [ShowActionPanel]
GO
ALTER TABLE [dbo].[Approvers] ADD  CONSTRAINT [DF_Approvers_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[EmailRequests] ADD  CONSTRAINT [DF__EmailRequ__Entry__656C112C]  DEFAULT (getdate()) FOR [EntryTime]
GO
ALTER TABLE [dbo].[FormCategories] ADD  CONSTRAINT [DF__FormCateg__IsPar__29221CFB]  DEFAULT ((0)) FOR [IsParalApprovalAllowed]
GO
ALTER TABLE [dbo].[FormCategories] ADD  CONSTRAINT [DF__FormCateg__IsRec__2A164134]  DEFAULT ((0)) FOR [IsRecievingAllowed]
GO
ALTER TABLE [dbo].[RequestMainData] ADD  DEFAULT ((0)) FOR [IsRecievingDone]
GO
ALTER TABLE [dbo].[RequestMainData] ADD  DEFAULT ((0)) FOR [CanStudentEdit]
GO
ALTER TABLE [dbo].[ReqWorkflow] ADD  CONSTRAINT [DF__ReqWorkfl__IsCur__4B7734FF]  DEFAULT ((0)) FOR [IsCurrApprover]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF__Users__IsContrib__44CA3770]  DEFAULT ((0)) FOR [IsContributor]
GO
ALTER TABLE [dbo].[Attachments]  WITH CHECK ADD  CONSTRAINT [FK_Attachments_AttachmentTypes1] FOREIGN KEY([AttachmentTypeID])
REFERENCES [dbo].[AttachmentTypes] ([AttachmentTypeID])
GO
ALTER TABLE [dbo].[Attachments] CHECK CONSTRAINT [FK_Attachments_AttachmentTypes1]
GO





SET IDENTITY_INSERT dbo.users ON


insert into dbo.Users(UserId, Login, Password, Name, Designation, Email, isActive, SignatureName, StdFatherName, Section, IsContributor, IsOldCampus)
Select '7','BITF13M001','123','Amina Ameen','','abc@yahoo.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','0','1' UNION ALL
Select '8','test1','123','Mehwish Khurshid','Student Affairs Coordinator','bitf13m003@pucit.edu.pk','1','bfb541e6-f191-4f04-961c-f1881a3aaee4.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1010','test2','123','Dr. Syed Masoor Sarwar','Principal','bsef13m556@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1015','test3','123','Amir Raza','Program Coordinator','bitf13m003@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1016','Asim Rasul','123','Asim Rasul','Exam Coordinator','bitf13m040@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1017','Shakeel','123','Shakeel','Admin Officer','bitf13m041@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1018','Adnan','123','Adnan','Assistant Treasurer','bitf13m028@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1019','Librarian','123','librarian','Librarian','abc@yahoo.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1020','BITF13M077','123','Sabah','','abc@yahoo.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','0','1' UNION ALL
Select '1021','BITF13M005','123','Maryam','Student','maryambashir005@gmail.com','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','0','1' UNION ALL
Select '1022','Secretary','123','Secretary DC','Secretary DC','bitf13m005@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1' UNION ALL
Select '1023','Rizwan','123','Rizwan','Network Admin','bitf13m003@pucit.edu.pk','1','d662d30f-949b-4525-96bb-337d1218891d.jpg','ABC','BSIT (MORNING)','1','1'

SET IDENTITY_INSERT dbo.users OFF

GO

insert into dbo.FormCategories(CategoryID, Category, IsParalApprovalAllowed, IsRecievingAllowed, Instructions)
Select '1','Clearance Form','1','0','In order to apply for the clearance form it is necessary that your dues are paid and that you are clear of any charges from the accounts office or library.' UNION ALL
Select '2','Leave Application Form','0','0','You must have a legitimate reason when applying for the leave application form. In case there is a medical issue you must attach medical certificate as proof which should be verified by PU Medical Officer.
Leave on medical ground will be governed as PUCIT statues and regulations.
Leave will not be counted as presence towards attendance requirements.' UNION ALL
Select '3','Option for Bsc Degree','0','0','This is only available for students who have completed at least 2 years of their bachelor’s degree.' UNION ALL
Select '4','Final Academic Transcript','0','1','Student must attach copy of Clearance form, the final academic transcript will be issued on completion of degree.' UNION ALL
Select '5','College ID Card Form ','0','1','The college id card will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form.' UNION ALL
Select '6','Vehical Token Form','0','1','You need to attach a copy  of your college id card, a copy of the vehicle’s registration and a photograph.' UNION ALL
Select '7','Reciept of Orignal Documents ','0','1','' UNION ALL
Select '8','Bonafide Character Certificate ','0','1','If you are applying for the bonafide certificate form before completion of your degree then you need to deposit Rs 250/- otherwise you dont have to pay any fee.' UNION ALL
Select '9','Semester Freeze/Withdraw Form','0','0','' UNION ALL
Select '10','Semester Rejoin Form','0','0','' UNION ALL
Select '11','Semester Academic Transcript','0','0','The semester (s) academic transcript will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form' UNION ALL
Select '12','Course Withdraw Form','0','0','Maximum 50% courses of a semester can be withdrawn' UNION ALL
Select '13','General Request Form','0','0','Please write a suitable title for your request. In case there are any attachments, name them precisely.' 

GO


SET IDENTITY_INSERT dbo.Approvers ON

Insert into dbo.Approvers(ApproverID, Designation, UserID, IsActive)

Select '1','Student Affairs Coordinator',8,'1' UNION ALL
Select '2','Principal',1010,'1' UNION ALL
Select '3','Program Coordinator',1015,'1' UNION ALL
Select '4','Exam Coordinator',1016,'1' UNION ALL
Select '5','Admin Officer',1017,'1' UNION ALL
Select '6','Assistant Treasurer',1018,'1' UNION ALL
Select '7','Librarian',1019,'1' UNION ALL
Select '8','Secretary DC',1022,'1' UNION ALL
Select '9','Network Admin',1023,'1' UNION ALL
Select '10','Teacher',8,'1'


SET IDENTITY_INSERT dbo.Approvers OFF


GO


SET IDENTITY_INSERT dbo.ApproverHierarchy ON

insert into dbo.ApproverHierarchy(ID, FormID, ApproverID, ApprovalOrder, IsForNewCampus, IsForOldCampus)
Select '1','1','1','7','0','1' UNION ALL
Select '2','1','3','6','0','1' UNION ALL
Select '3','1','4','5','0','1' UNION ALL
Select '4','1','6','2','0','1' UNION ALL
Select '5','1','7','3','0','1' UNION ALL
Select '6','1','8','1','0','1' UNION ALL
Select '7','1','9','4','0','1' UNION ALL
Select '8','2','1','1','1','1' UNION ALL
Select '9','2','2','2','0','1' UNION ALL
Select '10','3','1','2','0','1' UNION ALL
Select '11','3','4','1','0','1' UNION ALL
Select '12','4','1','1','0','1' UNION ALL
Select '13','4','2','2','0','1' UNION ALL
Select '14','5','1','1','0','1' UNION ALL
Select '15','5','5','2','0','1' UNION ALL
Select '16','6','1','1','0','1' UNION ALL
Select '17','6','5','2','0','1' UNION ALL
Select '18','7','5','2','0','1' UNION ALL
Select '19','7','6','1','0','1' UNION ALL
Select '20','7','7','3','0','1' UNION ALL
Select '21','8','1','1','0','1' UNION ALL
Select '22','8','4','2','0','1' UNION ALL
Select '23','8','5','3','0','1' UNION ALL
Select '24','9','1','3','0','1' UNION ALL
Select '25','9','2','4','0','1' UNION ALL
Select '26','9','6','1','0','1' UNION ALL
Select '27','9','7','2','0','1' UNION ALL
Select '28','10','1','1','0','1' UNION ALL
Select '29','10','1','3','0','1' UNION ALL
Select '30','10','2','2','0','1' UNION ALL
Select '31','11','4','1','0','1' UNION ALL
Select '32','12','1','1','0','1' UNION ALL
Select '33','13','1','1','0','1' UNION ALL
Select '34','13','3','2','0','1' UNION ALL
Select '35','2','3','2','1','0' 

SET IDENTITY_INSERT dbo.ApproverHierarchy OFF


GO



SET IDENTITY_INSERT dbo.AttachmentTypes ON

Insert into dbo.AttachmentTypes(AttachmentTypeID, typeName)
Select '1','College ID Card' UNION ALL
Select '2','Challan Form' UNION ALL
Select '3','Medical' UNION ALL
Select '4','Bonafide' UNION ALL
Select '5','Applicant CNIC' UNION ALL
Select '6','Clearance Form' UNION ALL
Select '7','Motor Cycle Registration' UNION ALL
Select '8','Photograph' UNION ALL
Select '9','Other' UNION ALL
Select '10','Father''s CNIC'

SET IDENTITY_INSERT dbo.AttachmentTypes OFF


GO


SET IDENTITY_INSERT dbo.Permissions ON

Insert into dbo.Permissions(Id, Name, Description)
Select '1','canWriteApplication','can write application' UNION ALL
Select '2','canEditApplication','can edit application before submission' UNION ALL
Select '3','canApproveApplication','can approve application' UNION ALL
Select '4','canRejectApplication','can reject application' UNION ALL
Select '5','canAddContributor','can add contributor' UNION ALL
Select '6','canPrintApplication','can print application' UNION ALL
Select '7','canGiveRemarks','can give remarks/comments on application' UNION ALL
Select '8','perCanProvideSignature','A user can upload signture file if he has this per' UNION ALL
Select '9','perCanForwardApplication','A user can use "forward" button to send/forward ap' UNION ALL
Select '10','perCanAccessAttachedDocs','A user can access the documents attached with an a' UNION ALL
Select '11','perAccessToAppsOtherThanSelfAssigned','A user can access applications which are neither c' UNION ALL
Select '13','perAccessToAssignedApps','A user can access applications assigned to him' UNION ALL
Select '15','perAccessToSelfCreatedApps','A user can access applications created by himself' UNION ALL
Select '16','PerCanHandleRecieving','Can do reciecing activity' UNION ALL
Select '17','PerCanAllowApplicationEditing','PerCanAllowApplicationEditing' UNION ALL
Select '18','PerCanRouteBack','PerCanRouteBack' UNION ALL
Select '19','PerUpdateBonaFiedCGPA','PerUpdateBonaFiedCGPA'

SET IDENTITY_INSERT dbo.Permissions OFF

GO

SET IDENTITY_INSERT dbo.Roles ON

INSERT INTO dbo.Roles(Id, Name, Description,CreatedBy,CreatedOn)
Select '1','Student','who submits application',1,getdate() UNION ALL
Select '3','contributor','who takes action on application',1,getdate() UNION ALL
Select '4','Teacher','ddd',1,getdate()

SET IDENTITY_INSERT dbo.Roles OFF


GO


SET IDENTITY_INSERT [dbo].[PermissionsMapping] ON

INSERT INTO [dbo].[PermissionsMapping](Id, RoleId, PermissionId)
Select '1','1','1' UNION ALL
Select '2','1','2' UNION ALL
Select '3','1','6' UNION ALL
Select '4','3','3' UNION ALL
Select '5','3','4' UNION ALL
Select '6','3','5' UNION ALL
Select '7','3','6' UNION ALL
Select '8','3','7' UNION ALL
Select '9','3','8' UNION ALL
Select '10','3','9' UNION ALL
Select '11','3','10' UNION ALL
Select '12','3','13' UNION ALL
Select '13','1','15' UNION ALL
Select '14','3','16' UNION ALL
Select '15','3','17' UNION ALL
Select '16','3','18' UNION ALL
Select '17','3','19' UNION ALL
Select '18','4','3' UNION ALL
Select '19','4','4' UNION ALL
Select '20','4','5' UNION ALL
Select '21','4','6' UNION ALL
Select '22','4','7' UNION ALL
Select '23','4','8' UNION ALL
Select '24','4','9' UNION ALL
Select '25','4','10' UNION ALL
Select '26','4','13' UNION ALL
Select '27','4','16'


SET IDENTITY_INSERT [dbo].[PermissionsMapping] OFF






GO

INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (1, N'Not Assigned yet')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (2, N'Pending')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (3, N'Accepted')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (4, N'Rejected')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (5, N'N/A')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (6, N'New Application')



GO


SET IDENTITY_INSERT [dbo].UserRoles ON

Insert into [dbo].[UserRoles](UserRoleID, UserId, RoleId, IsApproverIdInUserID)
Select '1','7','1','0' UNION ALL
Select '2','1020','1','0' UNION ALL
Select '3','1021','1','0' UNION ALL
Select '4','1','3','1' UNION ALL
Select '5','2','3','1' UNION ALL
Select '6','3','3','1' UNION ALL
Select '7','4','3','1' UNION ALL
Select '8','5','3','1' UNION ALL
Select '9','6','3','1' UNION ALL
Select '10','7','3','1' UNION ALL
Select '11','8','3','1' UNION ALL
Select '12','9','3','1' UNION ALL
Select '13','10','4','1' 

SET IDENTITY_INSERT [dbo].UserRoles OFF


GO
---------------------------------

CREATE PROCEDURE [dbo].[AddContributers]
      @FormID int,
      @ApproverID int,
      @AltApproverID int,
      @ApprovalOrder int,
      @IsForNewCampus bit,
      @IsForOldCampus bit
AS
BEGIN
	INSERT INTO dbo.ApproverHierarchy(
      [FormID] ,
      [ApproverID] ,
      [AltApproverID] ,
      [ApprovalOrder] ,
      [IsForNewCampus] ,
      [IsForOldCampus] )
	VALUES(@FormID,@ApproverID,NULL,@ApprovalOrder,@IsForNewCampus,@IsForOldCampus)
	select @FormID=scope_identity()
	select @FormID
END

GO

CREATE PROCEDURE [dbo].[AddDesignation]
		@UserID int,
		@Designation varchar(100),
		@IsActive bit
AS
BEGIN
	INSERT INTO dbo.Approvers(UserID,Designation,IsActive)
	VALUES(@UserID,@Designation,@IsActive)
	select @UserID=scope_identity()
	select @UserID
END

GO

CREATE PROCEDURE [dbo].[DeletePermission]-- Add the parameters for the stored procedure here
    @Id int,
	@Name varchar(50),
	@Description varchar(50)
AS
BEGIN
	
	delete dbo.Permissions
	WHERE Id = @Id

	
	select @Id
END

GO

CREATE PROCEDURE [dbo].[SavePermission]

	@Id int,
	@Name varchar(50),
	@Description varchar(50)
AS
BEGIN
	
	if (@Id > 0)
	BEGIN

		Update dbo.Permissions
			SET 
			Name = @Name, 
			Description = @Description
			where Id=@Id

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Permissions(Name ,Description)
		VALUES( @Name ,@Description)
		
		Select @Id = SCOPE_IDENTITY()
	END

	Select @Id
END

GO

CREATE PROCEDURE [dbo].[SaveRoles]
	@RoleId int,
	@Name varchar(50),
	@Description varchar(50),
	@IsActive bit,
	@Id int
AS
BEGIN
	
	if (@RoleId > 0)
	BEGIN

		Update dbo.Roles
			SET 
			Name = @Name, 
			Description = @Description,
			ModifiedBy=@Id,
			ModifiedOn=CURRENT_TIMESTAMP,
			IsActive=@IsActive

		WHERE Id = @RoleId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Roles(Name ,Description,CreatedBy,CreatedOn)
		VALUES( @Name ,@Description,@Id,CURRENT_TIMESTAMP)
		
		Select @RoleId = SCOPE_IDENTITY()
	END

	Select @RoleId
END

GO

CREATE PROCEDURE [dbo].[DeleteUsers]
		@UserId int,
	    @ModifiedBy varchar(100),
	    @ModifiedOn DateTime
AS
BEGIN
	
	Update dbo.Users
		SET 
		IsActive = 0
		
	WHERE UserId = @UserId

	
	select @UserId
END

GO

CREATE PROCEDURE [dbo].[SaveUsers]
		@UserId int,
	   @Login varchar(50)
	  ,@Password varchar(50)
      ,@Name varchar(100)
      ,@Designation varchar(100)
      ,@Email varchar(100)
      ,@SignatureName varchar(50)
      ,@StdFatherName varchar(100)
      ,@Section varchar(100)
      ,@IsContributor bit
      ,@IsOldCampus bit
      ,@isActive bit
AS
BEGIN
	
	if (@UserId > 0)
	BEGIN

		Update dbo.Users
			SET 
			Login = @Login, 
			Password = @Password, 
			Name = @Name, 
			Designation=@Designation, 
			Email=@Email, 
			SignatureName = @SignatureName,
			StdFatherName = @StdFatherName,
			Section=@Section, 
			IsContributor=@IsContributor, 
			isActive=@isActive,
			IsOldCampus = @IsOldCampus
		
		WHERE UserId = @UserId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Users(Login , Password , Name ,Designation,Email, SignatureName ,StdFatherName ,Section, IsContributor,isActive,IsOldCampus)
		VALUES(@Login , @Password , @Name ,@Designation,@Email, @SignatureName ,@StdFatherName ,@Section, @IsContributor,@isActive,@IsOldCampus)
		
		Select @UserId = SCOPE_IDENTITY()
	END

	Select @UserId
END


GO

CREATE Procedure [dbo].[SearchUsers]

	@name varchar(50),
	@designation varchar(50),
	@email varchar(100)
	
AS 
BEGIN
	
		SELECT * from [dbo].[Users] rmd 
		where rmd.Name like @name OR rmd.Designation like @designation OR rmd.Email like @email
END

GO

CREATE Procedure [dbo].[ValidateUserSPByAdmin]
	@Login varchar(50),
	@CurrTime datetime,
	@MachineIP varchar(20)
AS 
BEGIN
	Declare @UserId int = 0
	Declare @iscontributor bit =0

	SELECT @UserId=UserId, @iscontributor=IsContributor from dbo.Users u where Login = @Login and isActive = 1

	Select * from dbo.Users where UserID = @UserId

	if @UserId > 0
	BEGIN
		
		
		

		if @iscontributor = 1
		begin

			Declare @approvers table (ApproverID int,Designation varchar(50),UserID int,IsActive bit)

			insert into @approvers select * from dbo.Approvers where UserID = @UserId

			select * from @approvers

			Declare @approverid int
			select top 1 @approverid = ApproverId from @approvers

			select @approverid

			Select distinct r.* from dbo.Roles r INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @approverid and ur.IsApproverIdInUserID = 1

			Select distinct p.*,pm.RoleId from dbo.Permissions p 
			INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
			INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @approverid and ur.IsApproverIdInUserID = 1

		end
		else 
		begin
			Select distinct r.* from dbo.Roles r INNER JOIN dbo.UserRoles ur on r.ID = ur.RoleId and ur.UserId = @UserId

			Select distinct p.*,pm.RoleId from dbo.Permissions p 
			INNER JOIN [dbo].[PermissionsMapping] pm on p.Id = pm.PermissionId
			INNER JOIN dbo.UserRoles ur on pm.RoleId = ur.RoleId and ur.UserId = @UserId
		end
	
		INSERT INTO dbo.LoginHistory(UserID, LoginID, MachineIP, LoginTime)
		Select @UserId,@Login,@MachineIP,@CurrTime
	END

END

/*
declare @date datetime = getdate()
execute dbo.ValidateUserSPByAdmin 'BITF13M005',@date,'123'
select * from dbo.LoginHistory

*/

GO