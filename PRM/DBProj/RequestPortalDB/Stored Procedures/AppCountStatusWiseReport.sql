


CREATE Procedure [dbo].[AppCountStatusWiseReport]
@login varchar(50),
@status int,
@isapprover int,
	@startDate date,
	@endDate date	
AS 
BEGIN
	
	if @status=0
	begin
	-- Find data for non-contributors 
	Select u.Login,u.Name,'Not Approver' As IsContributor, u.Title,u.Email,t.*
	FROM dbo.Users  u INNER JOIN 

		(select UserId, isnull( Sum(1),0) as 'All',
		isnull(Sum(case when RequestStatus = 2 OR RequestStatus = 6  then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when RequestStatus = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when RequestStatus = 4 then 1 else 0 end),0) 'Rejected',
		0 as 'NotAssigned'
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and u.IsContributor = 0
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%'))  and (@isapprover=0 or @isapprover=2)

	UNION ALL
	-- Find data for contributors
	SELECT d.Login,d.Name,'Approver',d.Designation,d.Email, t.* 
	from dbo.vwApproverWithDesig d INNER JOIN

		(select ApproverID, isnull(sum(case when rwf.Status = 5 then 0 else 1 end),0) as 'All',
		isnull(Sum(case when rwf.Status = 2 then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when rwf.Status = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when rwf.Status = 4 then 1 else 0 end),0) 'Rejected',
		isnull(Sum(case when rwf.Status = 1 then 1 else 0 end),0) 'NotAssigned'
		from [dbo].[RequestMainData] rmd 
		INNER JOIN [dbo].[ReqWorkflow] rwf on  rwf.RequestID = rmd.RequestID
		where  cast(rmd.CreationDate as date) Between @startDate and @endDate
		Group by ApproverID) as t

	ON d.ApproverID = t.ApproverID 
		where ((d.Login like '%'+@login+'%') or (d.Name like '%'+@login+'%'))   and (@isapprover=0 or @isapprover=1)
	end
	else
	 begin 
	 -- Find data for non-contributors
	 Select u.Login,u.Name,'Not Approver' As IsContributor, u.Title,u.Email,t.*
	FROM dbo.Users  u INNER JOIN 

		(select UserId, isnull( Sum(1),0) as 'All',
		isnull(Sum(case when RequestStatus = 2 OR RequestStatus = 6  then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when RequestStatus = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when RequestStatus = 4 then 1 else 0 end),0) 'Rejected',
		0 as 'NotAssigned'
		from [dbo].[RequestMainData] where  cast(CreationDate as date) Between @startDate and @endDate
		group by UserId) as t 

	ON u.UserId = t.UserId AND u.IsActive = 1 and u.IsContributor = 0 
	where ((u.Login like '%'+@login+'%') or (u.Name like '%'+@login+'%')) and (case when  @status = 4 then t.Rejected when  @status = 2 then t.Pending when  @status = 1 then t.NotAssigned else t.Accepted end)>0  and (@isapprover=0 or @isapprover=2)


	UNION ALL
	-- Find data for contributors
	 SELECT d.Login,d.Name,'Approver',d.Designation, d.Email,t.* 
	from dbo.vwApproverWithDesig d INNER JOIN

		(select ApproverID, isnull(sum(case when rwf.Status = 5 then 0 else 1 end),0) as 'All',
		isnull(Sum(case when rwf.Status = 2 then 1 else 0 end),0) 'Pending',
		isnull(Sum(case when rwf.Status = 3 then 1 else 0 end),0) 'Accepted',
		isnull(Sum(case when rwf.Status = 4 then 1 else 0 end),0) 'Rejected',
		isnull(Sum(case when rwf.Status = 1 then 1 else 0 end),0) 'NotAssigned'
		from [dbo].[RequestMainData] rmd 
		INNER JOIN [dbo].[ReqWorkflow] rwf on  rwf.RequestID = rmd.RequestID
		where  cast(rmd.CreationDate as date) Between @startDate and @endDate
		Group by ApproverID) as t

	ON d.ApproverID = t.ApproverID 
	where ((d.Login like '%'+@login+'%') or (d.Name like '%'+@login+'%')) and (case when  @status = 4 then t.Rejected when  @status = 2 then t.Pending when  @status = 1 then t.NotAssigned else t.Accepted end)>0  and (@isapprover=0 or @isapprover=1)

	end
END








