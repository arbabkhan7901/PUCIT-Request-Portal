USE [master]
GO
/****** Object:  Database [RMS1]    Script Date: 9/29/2017 10:49:49 PM ******/
CREATE DATABASE [RMS1]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RMS1', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\RMS1.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'RMS1_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\RMS1_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [RMS1] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RMS1].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RMS1] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RMS1] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RMS1] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RMS1] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RMS1] SET ARITHABORT OFF 
GO
ALTER DATABASE [RMS1] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RMS1] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [RMS1] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RMS1] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RMS1] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RMS1] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RMS1] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RMS1] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RMS1] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RMS1] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RMS1] SET  DISABLE_BROKER 
GO
ALTER DATABASE [RMS1] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RMS1] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RMS1] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RMS1] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RMS1] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RMS1] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RMS1] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RMS1] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [RMS1] SET  MULTI_USER 
GO
ALTER DATABASE [RMS1] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RMS1] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RMS1] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RMS1] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [RMS1]
GO
/****** Object:  UserDefinedTableType [dbo].[ArrayInt]    Script Date: 9/29/2017 10:49:49 PM ******/
CREATE TYPE [dbo].[ArrayInt] AS TABLE(
	[ID] [int] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[AddContributers]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[AddDesignation]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[AddRemarks]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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
/****** Object:  StoredProcedure [dbo].[ApproveRequest]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteUsers]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[EnableDisablePermission]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EnableDisablePermission]
    @PermissionId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Permissions SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where ID = @PermissionId
	
	Select @PermissionId
END

GO
/****** Object:  StoredProcedure [dbo].[EnableDisableRequestEdit]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[EnableDisableRole]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EnableDisableRole]
    @RoleId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Roles SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where ID = @RoleId
	
	Select @RoleId
END

GO
/****** Object:  StoredProcedure [dbo].[EnableDisableUser]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EnableDisableUser]
    @UserId int,
	@IsActive bit,
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	UPDATE dbo.Users SET IsActive = @IsActive, ModifiedOn = @ActivityTime, Modifiedby = @ActivityBy
	Where UserID = @UserId
	
	Select @UserId
END


GO
/****** Object:  StoredProcedure [dbo].[Find_Text_In_SP]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetActivityLogConversationData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetActivityLogData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAllPermissions]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetAllPermissions]
AS 
BEGIN
		-- User Permissions
		Select distinct p.* from dbo.Permissions p
END


GO
/****** Object:  StoredProcedure [dbo].[GetAppCountByStatus]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetApproversByRequestId]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEmailRequestsByUniqueID]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetRequestAccessParams]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[GetRolePermissionById]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[HandleRecieving]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[IsRequestIDValid]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[RemoveAttachment]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[RouteBack]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaveAttachment]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaveLogConversation]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SavePermission]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SavePermission]
	@Id int,
	@Name varchar(50),
	@Description varchar(50),
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	if (@Id > 0)
	BEGIN
		Update dbo.Permissions
			SET 
			Name = @Name, 
			Description = @Description,
			ModifiedOn = @ActivityTime,
			Modifiedby = @ActivityBy
			where Id=@Id
	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Permissions(Name ,Description,CreatedOn,CreatedBy,IsActive)
		VALUES( @Name ,@Description,@ActivityTime,@ActivityBy,1)
		
		Select @Id = SCOPE_IDENTITY()
	END

	Select @Id
END


GO
/****** Object:  StoredProcedure [dbo].[SaveRequest]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SaveRolePermissionMapping]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SaveRolePermissionMapping]
@pRoleID int,
@pList ArrayInt READONLY --Here ArrayInt is user defined type
AS
BEGIN

	--Declare @pRoleID int = 2
	--Declare @pList ArrayInt
	--insert into @pList Select 1
	--insert into @pList Select 3

	Delete from [dbo].[PermissionsMapping] Where RoleId = @pRoleID and PermissionId NOT IN (select ID from @pList)

	Insert into [dbo].[PermissionsMapping](RoleId,PermissionId)
	select @pRoleID, ID from @pList 
	where ID not IN (select PermissionID from [dbo].[PermissionsMapping] Where RoleId = @pRoleID)

	Select @pRoleID

END

GO
/****** Object:  StoredProcedure [dbo].[SaveRoles]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveRoles]
	@RoleId int,
	@Name varchar(50),
	@Description varchar(50),
	@ActivityTime datetime,
	@ActivityBy int
AS
BEGIN
	
	if (@RoleId > 0)
	BEGIN
		Update dbo.Roles
			SET 
			Name = @Name, 
			Description = @Description,
			ModifiedBy=@ActivityBy,
			ModifiedOn=@ActivityTime
		WHERE Id = @RoleId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Roles(Name ,Description,CreatedBy,CreatedOn,IsActive)
		VALUES( @Name ,@Description,@ActivityBy,@ActivityTime,1)
		
		Select @RoleId = SCOPE_IDENTITY()
	END

	Select @RoleId
END


GO
/****** Object:  StoredProcedure [dbo].[SaveUserRoleMapping]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SaveUserRoleMapping]
@pUserID int,
@pList ArrayInt READONLY --Here ArrayInt is user defined type
AS
BEGIN

	--Declare @pUserID int = 2
	--Declare @pList ArrayInt
	--insert into @pList Select 1
	--insert into @pList Select 3

	Delete from [dbo].[UserRoles] Where RoleId = @pUserID and RoleId NOT IN (select ID from @pList)

	Insert into [dbo].[UserRoles](UserId,RoleId)
	select @pUserID, ID from @pList 
	where ID not IN (select RoleId from [dbo].[UserRoles] Where RoleId = @pUserID)

	Select @pUserID

END

GO
/****** Object:  StoredProcedure [dbo].[SaveUsers]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SaveUsers]
		@UserId int,
	   @Login varchar(50)
	  ,@Password varchar(50)
      ,@Name varchar(100)
      ,@Email varchar(100),
	  @ActivityTime datetime,
	  @ActivityBy int
      ,@Designation varchar(100)
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
			Email=@Email, 
			ModifiedOn = @ActivityTime,
			Modifiedby = @ActivityBy,
		Designation=@Designation, 
			StdFatherName = @StdFatherName,
			Section=@Section, 
			IsContributor=@IsContributor, 
			isActive=@isActive,
			IsOldCampus = @IsOldCampus
		WHERE UserId = @UserId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.Users(Login , Password , Name ,Email, CreatedOn,CreatedBy,IsActive,Designation, 
			StdFatherName ,
			Section, 
			IsContributor, 
			IsOldCampus)
		VALUES(@Login , @Password , @Name ,@Email,@ActivityTime,@ActivityBy,1,@Designation,@StdFatherName,@Section,@IsContributor,@IsOldCampus)
		
		Select @UserId = SCOPE_IDENTITY()
	END

	Select @UserId
END


GO
/****** Object:  StoredProcedure [dbo].[SearchApplications]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SearchApprover]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SearchUserForAutoComplete]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[SearchUserForAutoComplete]
@key varchar(20)
As 
Begin
	
	Select UserId, Login, Name
	from dbo.Users
	where Login like '%' +@key+ '%' 
	OR Name like '%' +@key+ '%' 
End


GO
/****** Object:  StoredProcedure [dbo].[SearchUsers]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[UpdateActivityLogActionItem]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateAttachment]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCGPA]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateWorkFlow]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  StoredProcedure [dbo].[UspFetchEmployeeRecords]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[UspFetchEmployeeRecords] 
  @PageNumber INT =3,
  @PageSize   INT = 6
AS
BEGIN
  SET NOCOUNT ON;
 
 select *
 from Users
 ORDER BY Users.UserId
 OFFSET @PageSize * (@PageNumber - 1) ROWS
 FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
/****** Object:  StoredProcedure [dbo].[ValidateUser]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- execute [dbo].[ValidateUser] 'Sharmeen',123,'1-1-2017','',false,''

CREATE Procedure [dbo].[ValidateUser]
	@Login varchar(50),
	@Password varchar(50),
	@CurrTime datetime,
	@MachineIP varchar(20),
	@IgnorePassword bit,
	@LoggerLoginID varchar(50)
AS 
BEGIN

	--DECLARE @Login varchar(50) = ''
	--DECLARE @Password varchar(50) = '123'
	--DECLARE @CurrTime datetime = getdate()
	--DECLARE @MachineIP varchar(20) = ''
	--DECLARE @IgnorePassword bit = 0
	--DECLARE @LoggerLoginID varchar(50) = ''

	Declare @UserId int = 0
	Declare @iscontributor bit =0
	Declare @isActive bit =0

	if(@IgnorePassword = 0)
	BEGIN
		SELECT @UserId=UserId, @iscontributor=IsContributor, @isActive = IsActive  
		from dbo.Users u where Login = @Login and Password = @Password 
	END
	else
	BEGIN
		SELECT @UserId=UserId, @iscontributor=IsContributor, @isActive = IsActive  
		from dbo.Users u where Login = @Login  
	END

	Select * from dbo.Users where UserID = @UserId

	if @UserId > 0  AND @isActive = 1
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
		
		IF @LoggerLoginID != ''
			SET @Login = @Login + '_By_' + @LoggerLoginID

		INSERT INTO dbo.LoginHistory(UserID, LoginID, MachineIP, LoginTime)
		Select @UserId,@Login,@MachineIP,@CurrTime
	END
END



GO
/****** Object:  StoredProcedure [dbo].[ValidateUserSPByAdmin]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  UserDefinedFunction [dbo].[IsValidLogId]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[Split1]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[ActivityLogConversations]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[ActivityLogTable]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[ApproverHierarchy]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[Approvers]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[Attachments]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[AttachmentTypes]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[BonafideCertificateData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[CollegeIDCardData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[CourseWithdrawal]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CourseWithdrawal](
	[RequestID] [int] NOT NULL,
	[CourseID] [varchar](50) NOT NULL,
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
/****** Object:  Table [dbo].[EmailRequests]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[FinalTranscriptData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[FormCategories]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[LeaveApplicationForm]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[LoginHistory]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[OptionForBscDegree]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[Permissions]    Script Date: 9/29/2017 10:49:49 PM ******/
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
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[Modifiedby] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PermissionsMapping]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[ReceiptOfOrignalEducationalDocuments]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[RequestMainData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[ReqWorkflow]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 9/29/2017 10:49:49 PM ******/
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
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[Modifiedby] [int] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SemesterAcademicTranscript]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[SemesterRejoinData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[StatusTypes]    Script Date: 9/29/2017 10:49:49 PM ******/
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
/****** Object:  Table [dbo].[UserRoles]    Script Date: 9/29/2017 10:49:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserRoleID] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[IsApproverIdInUserID] [bit] NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 9/29/2017 10:49:49 PM ******/
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
	[SignatureName] [varchar](50) NULL,
	[StdFatherName] [varchar](100) NULL,
	[Section] [varchar](25) NULL,
	[IsContributor] [bit] NULL,
	[IsOldCampus] [bit] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[Modifiedby] [int] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Users_1] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[VehicalTokenData]    Script Date: 9/29/2017 10:49:49 PM ******/
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
SET IDENTITY_INSERT [dbo].[ApproverHierarchy] ON 

INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (1, 1, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (2, 1, 3, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (8, 2, 1, NULL, 1, 1, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (9, 2, 2, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (10, 3, 1, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (11, 3, 4, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (12, 4, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (13, 4, 2, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (14, 5, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (15, 5, 5, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (16, 6, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (17, 6, 5, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (18, 7, 5, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (19, 7, 6, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (20, 7, 7, NULL, 3, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (21, 8, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (22, 8, 4, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (23, 8, 5, NULL, 3, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (24, 9, 1, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (25, 9, 2, NULL, 4, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (26, 9, 6, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (27, 9, 7, NULL, 3, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (28, 10, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (29, 10, 1, NULL, 3, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (30, 10, 2, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (31, 11, 4, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (32, 12, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (33, 13, 1, NULL, 1, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (34, 13, 3, NULL, 2, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (35, 2, 3, NULL, 3, 1, 0)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (36, 5, 2, NULL, 3, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (38, 1, 13, NULL, 3, 1, 0)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (39, 2, 4, NULL, 4, 0, 1)
INSERT [dbo].[ApproverHierarchy] ([ID], [FormID], [ApproverID], [AltApproverID], [ApprovalOrder], [IsForNewCampus], [IsForOldCampus]) VALUES (40, 2, 8, NULL, 5, 0, 1)
SET IDENTITY_INSERT [dbo].[ApproverHierarchy] OFF
SET IDENTITY_INSERT [dbo].[Approvers] ON 

INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (1, N'Student Affairs Coordinator', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (2, N'Principal', 1010, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (3, N'Program Coordinator', 1015, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (4, N'Exam Coordinator', 1016, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (5, N'Admin Officer', 1017, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (6, N'Assistant Treasurer', 1018, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (7, N'Librarian', 1019, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (8, N'Secretary DC', 1022, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (9, N'Network Admin', 1023, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (10, N'Teacher', 8, 1)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (11, N'kgkhj', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (12, N'qw', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (13, N'qw', 1010, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (14, N'werer', 1015, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (15, N'wererwer', 1022, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (16, N'wer', 1022, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (17, N'd', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (18, N'wewd', 0, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (19, N'w', 0, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (20, N'sd', 0, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (21, N'hmggch', 0, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (22, N'', 1015, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (23, N'hv', 1023, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (24, N'mn', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (25, N'mnbmnb', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (26, N'', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (27, N'nb', 1010, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (28, N'', 1018, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (29, N'nmm,', 1019, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (30, N'mmm', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (31, N'nvb', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (32, N'bnnb', 1019, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (33, N'nvnbv', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (34, N'', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (35, N'mb', 8, 0)
INSERT [dbo].[Approvers] ([ApproverID], [Designation], [UserID], [IsActive]) VALUES (36, N'sd', 1022, 1)
SET IDENTITY_INSERT [dbo].[Approvers] OFF
SET IDENTITY_INSERT [dbo].[AttachmentTypes] ON 

INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (1, N'College ID Card', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (2, N'Challan Form', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (3, N'Medical', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (4, N'Bonafide', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (5, N'Applicant CNIC', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (6, N'Clearance Form', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (7, N'Motor Cycle Registration', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (8, N'Photograph', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (9, N'Other', NULL)
INSERT [dbo].[AttachmentTypes] ([AttachmentTypeID], [typeName], [description]) VALUES (10, N'Father''s CNIC', NULL)
SET IDENTITY_INSERT [dbo].[AttachmentTypes] OFF
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (1, N'Clearance Form', 1, 0, N'In order to apply for the clearance form it is necessary that your dues are paid and that you are clear of any charges from the accounts office or library.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (2, N'Leave Application Form', 0, 0, N'You must have a legitimate reason when applying for the leave application form. In case there is a medical issue you must attach medical certificate as proof which should be verified by PU Medical Officer.
Leave on medical ground will be governed as PUCIT statues and regulations.
Leave will not be counted as presence towards attendance requirements.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (3, N'Option for Bsc Degree', 0, 0, N'This is only available for students who have completed at least 2 years of their bachelor’s degree.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (4, N'Final Academic Transcript', 0, 1, N'Student must attach copy of Clearance form, the final academic transcript will be issued on completion of degree.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (5, N'College ID Card Form', 0, 1, N'The college id card will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (6, N'Vehical Token Form', 0, 1, N'You need to attach a copy  of your college id card, a copy of the vehicle’s registration and a photograph.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (7, N'Reciept of Orignal Documents', 0, 1, N'')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (8, N'Bonafide Character Certificate ', 0, 1, N'If you are applying for the bonafide certificate form before completion of your degree then you need to deposit Rs 250/- otherwise you dont have to pay any fee.')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (9, N'Semester Freeze/Withdraw Form', 0, 0, N'')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (10, N'Semester Rejoin Form', 0, 0, N'')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (11, N'Semester Academic Transcript', 0, 0, N'The semester (s) academic transcript will be issued by paying prescribed fee of Rs.250/-. Add original receipt of challan form')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (12, N'Course Withdraw Form', 0, 0, N'Maximum 50% courses of a semester can be withdrawn')
INSERT [dbo].[FormCategories] ([CategoryID], [Category], [IsParalApprovalAllowed], [IsRecievingAllowed], [Instructions]) VALUES (13, N'General Request Form', 0, 0, N'Please write a suitable title for your request. In case there are any attachments, name them precisely.')
SET IDENTITY_INSERT [dbo].[LoginHistory] ON 

INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (1, 1023, N'Rizwan', N'::1', CAST(0x0000A7FC0074EEB1 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (2, 1025, N'teeba', N'::1', CAST(0x0000A7FC00754257 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (3, 1025, N'teeba', N'::1', CAST(0x0000A7FC0127E30E AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (4, 1025, N'teeba', N'::1', CAST(0x0000A7FC012D61F0 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (5, 1025, N'teeba', N'::1', CAST(0x0000A7FC0135A061 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (6, 1025, N'teeba', N'::1', CAST(0x0000A7FD00459E4A AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (7, 1025, N'teeba', N'::1', CAST(0x0000A7FD004BD5B3 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (8, 1025, N'teeba', N'::1', CAST(0x0000A7FD004F5948 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (9, 1025, N'teeba', N'::1', CAST(0x0000A7FD005302C1 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (10, 1025, N'teeba', N'::1', CAST(0x0000A7FD005A35C7 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (11, 1025, N'teeba', N'::1', CAST(0x0000A7FD005B4480 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (12, 1025, N'teeba', N'::1', CAST(0x0000A7FD005CD199 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (13, 1025, N'teeba', N'::1', CAST(0x0000A7FD005DB607 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (14, 1025, N'teeba', N'::1', CAST(0x0000A7FD005EBFC5 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (15, 1025, N'teeba', N'::1', CAST(0x0000A7FD00664FA3 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (16, 1025, N'teeba', N'::1', CAST(0x0000A7FD006C7680 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (17, 1025, N'teeba', N'::1', CAST(0x0000A7FD006D8986 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (18, 1025, N'TEEBA', N'::1', CAST(0x0000A7FD006E99DB AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (19, 1025, N'teeba', N'::1', CAST(0x0000A7FD0076B4CD AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (20, 1025, N'teeba', N'::1', CAST(0x0000A7FD00772478 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (21, 1025, N'teeba', N'::1', CAST(0x0000A7FD0077E272 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (22, 1025, N'teeba', N'::1', CAST(0x0000A7FD007D3914 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (23, 1025, N'teeba', N'::1', CAST(0x0000A7FD007EE851 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (24, 1025, N'teeba', N'::1', CAST(0x0000A7FD0086DEB3 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (25, 1025, N'teeba', N'::1', CAST(0x0000A7FD008B453D AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (26, 1025, N'teeba', N'::1', CAST(0x0000A7FD008D26DE AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (27, 1025, N'teeba', N'::1', CAST(0x0000A7FD00A747AC AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (28, 1025, N'teeba', N'::1', CAST(0x0000A7FD00AAABDE AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (29, 1025, N'teeba', N'::1', CAST(0x0000A7FD00AD68F8 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (30, 1025, N'teeba', N'::1', CAST(0x0000A7FD00B4873C AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (31, 1025, N'teeba', N'::1', CAST(0x0000A7FD00BC6F82 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (32, 1025, N'teeba', N'::1', CAST(0x0000A7FD00C3FA42 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (33, 1025, N'teeba', N'::1', CAST(0x0000A7FD00C4F55B AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (34, 1025, N'teeba', N'::1', CAST(0x0000A7FD00C7A0E1 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (35, 1025, N'teeba', N'::1', CAST(0x0000A7FD01195ADE AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (36, 1025, N'teeba', N'::1', CAST(0x0000A7FD011E45AE AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (37, 1025, N'teeba', N'::1', CAST(0x0000A7FD0123D2F3 AS DateTime))
INSERT [dbo].[LoginHistory] ([LoginHistoryID], [UserID], [LoginID], [MachineIP], [LoginTime]) VALUES (38, 1025, N'teeba', N'::1', CAST(0x0000A7FD0123DBEF AS DateTime))
SET IDENTITY_INSERT [dbo].[LoginHistory] OFF
SET IDENTITY_INSERT [dbo].[Permissions] ON 

INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1, N'canWriteApplication', N'can write application', 1, CAST(0x0000A7FC00738A56 AS DateTime), 1025, CAST(0x0000A7FC013834FD AS DateTime), 0)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (2, N'canEditApplication', N'can edit application before submission', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (3, N'canApproveApplication', N'can approve application', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (4, N'canRejectApplication', N'can reject application', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (5, N'canAddContributor', N'can add contributor', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (6, N'canPrintApplication', N'can print application', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (7, N'canGiveRemarks', N'can give remarks/comments on application', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (8, N'perCanProvideSignature', N'A user can upload signture file if he has this per', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (9, N'perCanForwardApplication', N'A user can use "forward" button to send/forward ap', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (10, N'perCanAccessAttachedDocs', N'A user can access the documents attached with an a', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (11, N'perAccessToAppsOtherThanSelfAssigned', N'A user can access applications which are neither c', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (13, N'perAccessToAssignedApps', N'A user can access applications assigned to him', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (15, N'perAccessToSelfCreatedApps', N'A user can access applications created by himself', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (16, N'PerCanHandleRecieving', N'Can do reciecing activity', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (17, N'PerCanAllowApplicationEditing', N'PerCanAllowApplicationEditing', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (18, N'PerCanRouteBack', N'PerCanRouteBack', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (19, N'PerUpdateBonaFiedCGPA', N'PerUpdateBonaFiedCGPA', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (26, N'perAccessToAllApps', N'Admin can access all apps', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (27, N'perCanAccessAdminViews', N'Admin can access its views', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (28, N'perCanLoginAsOtherUser', N'Admin can login as other user', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (29, N'perManageSecurityUsers', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (30, N'perManageSecurityRoles', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (31, N'perManageSecurityPermissions', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (32, N'perViewLoginHistoryReport', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (33, N'perManageWorkFlows', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Permissions] ([Id], [Name], [Description], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (34, N'perViewApplicationCountStatuswise', N'', 1, CAST(0x0000A7FC00738A56 AS DateTime), NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[Permissions] OFF
SET IDENTITY_INSERT [dbo].[PermissionsMapping] ON 

INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (1, 1, 1)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (2, 1, 2)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (3, 1, 6)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (4, 3, 3)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (5, 3, 4)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (6, 3, 5)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (7, 3, 6)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (8, 3, 7)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (9, 3, 8)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (10, 3, 9)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (11, 3, 10)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (12, 3, 13)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (13, 1, 15)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (14, 3, 16)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (15, 3, 17)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (16, 3, 18)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (17, 3, 19)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (18, 4, 3)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (19, 4, 4)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (20, 4, 5)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (21, 4, 6)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (22, 4, 7)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (23, 4, 8)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (24, 4, 9)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (25, 4, 10)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (26, 4, 13)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (27, 4, 16)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (206, 17, 26)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (207, 17, 27)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (208, 17, 28)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (209, 17, 29)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (210, 17, 30)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (211, 17, 31)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (212, 17, 32)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (213, 17, 33)
INSERT [dbo].[PermissionsMapping] ([Id], [RoleId], [PermissionId]) VALUES (214, 17, 34)
SET IDENTITY_INSERT [dbo].[PermissionsMapping] OFF
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([Id], [Name], [Description], [IsActive], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn]) VALUES (1, N'Student', N'who submits application', 1, 1, CAST(0x0000A7FC00738A57 AS DateTime), 1025, CAST(0x0000A7FC0128F1ED AS DateTime))
INSERT [dbo].[Roles] ([Id], [Name], [Description], [IsActive], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn]) VALUES (3, N'contributor', N'who takes action on application', 1, 1, CAST(0x0000A7FC00738A57 AS DateTime), NULL, NULL)
INSERT [dbo].[Roles] ([Id], [Name], [Description], [IsActive], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn]) VALUES (4, N'Teacher', N'ddd', 0, 1, CAST(0x0000A7FC00738A57 AS DateTime), 1025, CAST(0x0000A7FD0089FBF1 AS DateTime))
INSERT [dbo].[Roles] ([Id], [Name], [Description], [IsActive], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn]) VALUES (17, N'Admin', N'', 1, 1, CAST(0x0000A7FC00738A57 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Roles] OFF
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (1, N'Not Assigned yet')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (2, N'Pending')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (3, N'Accepted')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (4, N'Rejected')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (5, N'N/A')
INSERT [dbo].[StatusTypes] ([StatusTypeID], [StatusType]) VALUES (6, N'New Application')
SET IDENTITY_INSERT [dbo].[UserRoles] ON 

INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (1, 7, 1, 0)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (2, 1020, 1, 0)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (3, 1021, 1, 0)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (4, 1, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (5, 2, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (6, 3, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (8, 5, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (9, 6, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (11, 8, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (12, 9, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (13, 10, 4, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (14, 4, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (15, 7, 3, 1)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (19, 1025, 17, 0)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (20, 8, 3, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (21, 8, 17, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (22, 8, 1, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (23, 8, 3, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (24, 8, 17, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (25, 1016, 3, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (26, 1015, 3, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (27, 7, 1, NULL)
INSERT [dbo].[UserRoles] ([UserRoleID], [UserId], [RoleId], [IsApproverIdInUserID]) VALUES (28, 7, 3, NULL)
SET IDENTITY_INSERT [dbo].[UserRoles] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (7, N'BITF13M001', N'123', N'Amina Ameen2', N'sTUDENT', N'abc@yahoo.com', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 0, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD011AC632 AS DateTime), 0)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (8, N'test1', N'123', N'Mehwish Khurshid', N'Student Affairs Coordinator', N'bitf13m003@pucit.edu.pk', N'bfb541e6-f191-4f04-961c-f1881a3aaee4.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD00AAC55B AS DateTime), 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1010, N'test2', N'123', N'Dr. Syed Masoor Sarwar', N'Principal', N'bsef13m556@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD00A7A021 AS DateTime), 0)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1015, N'test3', N'123', N'Amir Raza', N'Program Coordinator', N'bitf13m003@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD004AA922 AS DateTime), 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1016, N'Asim Rasul', N'123', N'Asim Rasul', N'Exam Coordinator', N'bitf13m040@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FC012A21AF AS DateTime), 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1017, N'Shakeel', N'123', N'Shakeel', N'Admin Officer', N'bitf13m041@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1018, N'Adnan', N'123', N'Adnan', N'Assistant Treasurer', N'bitf13m028@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1019, N'Librarian', N'123', N'librarian', N'Librarian', N'abc@yahoo.com', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD004DDA18 AS DateTime), 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1020, N'BITF13M077', N'123', N'Sabah', N'Student', N'abc@yahoo.com', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 0, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD008952AB AS DateTime), 0)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1021, N'BITF13M005', N'123', N'Maryam', N'Student', N'maryambashir005@gmail.com', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 0, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), 1025, CAST(0x0000A7FD008B5F91 AS DateTime), 0)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1022, N'Secretary', N'123', N'Secretary DC', N'Secretary DC', N'bitf13m005@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1023, N'Rizwan', N'123', N'Rizwan', N'Network Admin', N'bitf13m003@pucit.edu.pk', N'd662d30f-949b-4525-96bb-337d1218891d.jpg', N'ABC', N'BSIT (MORNING)', 1, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), NULL, NULL, 1)
INSERT [dbo].[Users] ([UserId], [Login], [Password], [Name], [Designation], [Email], [SignatureName], [StdFatherName], [Section], [IsContributor], [IsOldCampus], [CreatedBy], [CreatedOn], [Modifiedby], [ModifiedOn], [IsActive]) VALUES (1025, N'teeba', N'123', N'teeba', N'Admin', N'shameenrana199@gmail.com', N'c59e908a-bffc-43c0-a865-6bd59e8c21f7.png', N'ABC', N'BSSE (AFTERNOON)', 0, 1, 1, CAST(0x0000A7FC00738A39 AS DateTime), NULL, NULL, 1)
SET IDENTITY_INSERT [dbo].[Users] OFF
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
ALTER TABLE [dbo].[Permissions] ADD  DEFAULT ((1)) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[Permissions] ADD  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Permissions] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RequestMainData] ADD  DEFAULT ((0)) FOR [IsRecievingDone]
GO
ALTER TABLE [dbo].[RequestMainData] ADD  DEFAULT ((0)) FOR [CanStudentEdit]
GO
ALTER TABLE [dbo].[ReqWorkflow] ADD  CONSTRAINT [DF__ReqWorkfl__IsCur__4B7734FF]  DEFAULT ((0)) FOR [IsCurrApprover]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Roles] ADD  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF__Users__IsContrib__44CA3770]  DEFAULT ((0)) FOR [IsContributor]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Attachments]  WITH CHECK ADD  CONSTRAINT [FK_Attachments_AttachmentTypes1] FOREIGN KEY([AttachmentTypeID])
REFERENCES [dbo].[AttachmentTypes] ([AttachmentTypeID])
GO
ALTER TABLE [dbo].[Attachments] CHECK CONSTRAINT [FK_Attachments_AttachmentTypes1]
GO
USE [master]
GO
ALTER DATABASE [RMS1] SET  READ_WRITE 
GO
