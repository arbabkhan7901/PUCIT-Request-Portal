

CREATE Procedure [dbo].[GetActivityLogDataForReport]
	@UserID int,
	@accessType int,
	@pageSize int,
	@pageIndex int
As 
Begin
		Declare @contributors table (userid int)
		Declare @creatorId int = 0
		if @accessType = 0 OR @accessType = 1
		begin
		Select count(*) 
		from [dbo].ActivityLogTable a where a.RequestId IN (Select distinct(RequestId) from [dbo].[RequestMainData] where UserId = @UserID)
		
	
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
		where a.RequestId IN (Select distinct(RequestId) from [dbo].[RequestMainData] where UserId = @UserID)
		order by a.ActivityTime Desc, a.Id Desc
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
		end
		if @accessType = 2
		begin
		
		Select count(*) 
		from [dbo].ActivityLogTable a where a.RequestId IN (Select distinct(RequestId) from [dbo].[ReqWorkflow] where ApproverID = @UserID And Status <> 1)
		
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
		where a.RequestId IN (Select distinct(RequestId) from [dbo].[ReqWorkflow] where ApproverID = @UserID And Status <> 1)
		order by a.ActivityTime Desc, a.Id Desc
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
		end
		if @accessType = 4
		begin
		Select count(*) 
		from [dbo].[ActivityLogTable]

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
		order by a.ActivityTime Desc, a.Id Desc
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
		end
End





	






