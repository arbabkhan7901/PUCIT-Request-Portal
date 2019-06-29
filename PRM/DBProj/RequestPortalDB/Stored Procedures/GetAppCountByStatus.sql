


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













