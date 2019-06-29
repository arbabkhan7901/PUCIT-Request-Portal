
Create Procedure [dbo].[SearchUserForAutoComplete]
@key varchar(20)
As 
Begin
	
	Select UserId, Login, Name
	from dbo.Users
	where Login like '%' +@key+ '%' 
	OR Name like '%' +@key+ '%' 
End












