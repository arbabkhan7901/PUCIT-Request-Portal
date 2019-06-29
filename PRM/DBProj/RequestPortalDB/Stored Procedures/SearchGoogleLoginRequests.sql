CREATE Procedure [dbo].[SearchGoogleLoginRequests]
	@textToSearch varchar(20),
	@isactive int,
	@pageSize int,
	@pageIndex int
	
AS 
BEGIN
		Select count(*) 
		from dbo.GmailLoginRequests  rmd 
		where (rmd.Name like '%'+ @textToSearch + '%'
			  OR rmd.email like '%'+ @textToSearch + '%')
			  And rmd.isused = case when @isactive = -1 then rmd.isused else @isactive end

		SELECT rmd.ID, rmd.Name, rmd.Email,rmd.IsUsed, IsNull(rmd.UserId,0) as UserId, isnull(rmd.UserCreatedOn, '1900-01-01') as UserCreatedOn,rmd.EntryTime
		 from dbo.GmailLoginRequests rmd
		where (rmd.Name like '%'+ @textToSearch + '%'
			  OR rmd.email like '%'+ @textToSearch + '%')
			  And rmd.isused = case when @isactive = -1 then rmd.isused else @isactive end
			  
		Order by rmd.EntryTime Desc
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
END






