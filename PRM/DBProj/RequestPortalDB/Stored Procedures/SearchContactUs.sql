


CREATE PROCEDURE [dbo].[SearchContactUs]
	@Name varchar(100),
	@Email varchar(100),
	@startDate date,
	@endDate date,
	@pageSize int,
	@pageIndex int
AS
	BEGIN
		Select count(*) 
		from dbo.ContactUs rmd
		where (rmd.Name like '%'+@Name + '%'
			  and rmd.Email like '%'+ @Email + '%'
			  and (cast(rmd.EntryTime as date) Between @startDate and @endDate) )
			

	Select ID,Name,Email,Description,EntryTime,MachineIP 
		from dbo.ContactUs rmd
		where (rmd.Name like '%'+@Name + '%'
			  and rmd.Email like '%'+ @Email + '%'
			  and (cast(rmd.EntryTime as date) Between @startDate and @endDate))
		 Order by rmd.ID	  
		OFFSET @pageIndex*@pageSize ROWS
		FETCH NEXT @pageSize ROWS ONLY
END









