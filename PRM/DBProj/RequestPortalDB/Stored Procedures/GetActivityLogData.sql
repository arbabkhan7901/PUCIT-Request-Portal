
CREATE Procedure [dbo].[GetActivityLogData]
	@RequestID int,
	@UserID int,
	@accessType int,
	@ReqUniqueId varchar (40)
As 
Begin

		--declare @RequestID int = 8
		--declare	@UserID int = 1
		--declare @accessType int =2

		Declare @tempReqId int = 0
		Select @tempReqId = rmd.RequestId 
		from RequestMainData rmd 
		where rmd.ReqUniqueId= @ReqUniqueId

		IF (@tempReqId <> @RequestID)
		BEGIN
			Set @RequestID = -1;
		END

	
		Declare @contributors table (userid int)
		Declare @creatorId int = 0

		if @accessType = 1
		begin
			select @creatorId = UserId from dbo.RequestMainData where RequestID = @RequestID
		end
		else if @accessType = 2
		begin
			insert into @contributors
			Select distinct ApproverID from dbo.ReqWorkflow where RequestID = @RequestID
		end
		else
		begin
			insert into @contributors
			select @UserID
		end


		Select a.Id, a.RequestId, a.UserId, a.Comments, a.Activity, a.ActivityTime, a.IsPrintable, isnull(a.VisibleToUserID,0) as VisibleToUserID, isnull(a.CanReplyUserID,0) as CanReplyUserID,
				cast(case when a.UserId = @UserID then a.ShowActionPanel else 0 end as bit) as ShowActionPanel,
				'' as SignatureName, 
		cast(
			 (case  when a.ShowActionPanel = 0 then 0 else
					(case when a.UserID = @UserID then 1 else
							(case when isnull(a.CanReplyUserID,0) = 0 then 0 
							  when isnull(a.CanReplyUserID,0) = -1 AND @UserID IN (select userid from @contributors) then 1 
							  when isnull(a.CanReplyUserID,0) = -2  AND @UserID = @creatorId then 1 
							  when isnull(a.CanReplyUserID,0) = -3  AND (@UserID IN (select userid from @contributors) OR @UserID = @creatorId) then 1
							   when isnull(a.CanReplyUserID,0) > 0 AND isnull(a.CanReplyUserID,0) = @UserID  then 1
							  else 0 end) 
					 end ) 
			  end
			  
			  ) as bit) as CanReplyFlag
		from [dbo].[ActivityLogTable] a 
		Where a.RequestId = @RequestID 
		and (a.UserID = @UserID 
			OR ( isnull(a.VisibleToUserID,0) = 0  AND (@UserID IN (select userid from @contributors) OR @UserID = @creatorId))
			OR ( isnull(a.VisibleToUserID,0) = -1 AND @UserID IN (select userid from @contributors))
			OR ( isnull(a.VisibleToUserID,0) = -2 AND @UserID = @creatorId)
			OR ( isnull(a.VisibleToUserID,0) > 0 AND isnull(a.VisibleToUserID,0) = @UserID)
			)
		order by a.ActivityTime Desc, a.Id Desc
End





