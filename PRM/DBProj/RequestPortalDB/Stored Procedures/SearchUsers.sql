-- execute [dbo].[SearchUsers] '','','',-1,-1,-1,10,1

CREATE Procedure [dbo].[SearchUsers]
	@textToSearch varchar(20),
	@isoldcampus int,
	@iscontributor int,
	@isactive int,
	@pageSize int,
	@pageIndex int
	
AS 
BEGIN
		Select count(*) 
		from [dbo].[Users] rmd 
		where (rmd.Name like '%'+ @textToSearch + '%'
			  OR rmd.email like '%'+ @textToSearch + '%'
			  OR rmd.section like '%'+ @textToSearch + '%'
			  OR rmd.Login like '%'+ @textToSearch + '%')
			  And rmd.IsActive = case when @isactive = -1 then rmd.IsActive else @isactive end
			  And rmd.IsContributor = case when @iscontributor = -1 then rmd.IsContributor else @iscontributor end
			  And rmd.IsOldCampus = case when @isoldcampus = -1 then rmd.IsOldCampus else @isoldcampus end
			 And rmd.UserId > 2

		SELECT UserId, Login, Name, Title, Email, SignatureName, StdFatherName, 
		Section, IsContributor, IsOldCampus, IsActive
		 from [dbo].[Users] rmd 
		where (rmd.Name like '%'+ @textToSearch + '%'
			  OR rmd.email like '%'+ @textToSearch + '%'
			  OR rmd.section like '%'+ @textToSearch + '%'
			  OR rmd.Login like '%'+ @textToSearch + '%')
			  And rmd.IsActive = case when @isactive = -1 then rmd.IsActive else @isactive end
			  And rmd.IsContributor = case when @iscontributor = -1 then rmd.IsContributor else @iscontributor end
			  And rmd.IsOldCampus = case when @isoldcampus = -1 then rmd.IsOldCampus else @isoldcampus end
			   And rmd.UserId > 2
		Order by rmd.UserId
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
END













