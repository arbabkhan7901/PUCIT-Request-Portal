

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












