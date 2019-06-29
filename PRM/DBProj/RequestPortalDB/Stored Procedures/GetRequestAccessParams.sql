
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
	Declare @ReqUniqueId varchar(40)=''

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
		if(Select count(*) from [dbo].[ReqWorkflow] where RequestID = @requestId) > 0
		BEGIN
			SET @IsValidAccess = 1
		END
	END


	If @OnlyValidateRequest = 0 AND @IsValidAccess = 1
	BEGIN
		--local variables
		Declare @isParallelAllowed bit =0
		Declare @data table(ID int identity(1,1), ReqWFID int, ApproverID int, Status int, IsCurrApprover bit)

		Insert into @data(ReqWFID,ApproverID,Status,IsCurrApprover)
		Select ID,ApproverID,Status,IsCurrApprover from dbo.ReqWorkflow Where RequestID = @RequestId order by ID

		
		-- If Category allows Reciving, Request is approved and Recieving is not done yet
		Select @ReqUniqueId= rm.ReqUniqueId, @RecFlag = case when fc.IsRecievingAllowed = 1 AND rm.IsRecievingDone =0 AND rm.RequestStatus = 3 then 1 else 0 end,
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

	SELECT @IsValidAccess as IsValidAccess, @RecFlag as RecFlag,@RouteBackFlag as RouteBackFlag, @canStdEditFlag as CanStdEditFlag,@IsPendingForCurrUser as IsPendingForCurrUser, @AppStatus as AppStatus, @ReqUniqueId as ReqUniqueId

End





