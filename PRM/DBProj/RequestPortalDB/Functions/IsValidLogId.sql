
CREATE FUNCTION [dbo].[IsValidLogId]
(
	@RequestID int,
	@ActivityLogID bigint,
	@UserID int,
	@accessType int,
	@ReqUniqueId varchar(40)
)
RETURNS bit
AS
BEGIN
	
	Declare @output bit = 0

	Declare @tempReqId int = 0
	Select @tempReqId = rmd.RequestId 
	from RequestMainData rmd 
	where rmd.ReqUniqueId= @ReqUniqueId

	IF (@tempReqId <> @RequestID)
	BEGIN
		return @output;
	END

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





