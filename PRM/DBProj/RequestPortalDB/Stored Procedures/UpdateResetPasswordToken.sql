
CREATE PROCEDURE [dbo].[UpdateResetPasswordToken]
	@email_login varchar(50),
	@guid varchar(50),
	@ipaddress varchar(20),
	@currTime datetime,
	@url varchar(100)
AS
BEGIN
	Declare @email varchar(50) = ''
	

	IF( Select count(*) FROM dbo.Users where login = @email_login or email = @email_login
		And isactive = 1 and IsDisabledForLogin = 0) = 1
	BEGIN
		Update dbo.Users Set ResetToken=@guid 
		where login = @email_login or email = @email_login
		And isactive = 1 and IsDisabledForLogin = 0

		SELECT @email = email FROM dbo.Users 
		where login = @email_login or email = @email_login
		And isactive = 1 and IsDisabledForLogin = 0

		insert into dbo.ForgotPasswordLog(Login,Token,IPAddress,EntyDate,IsUsed,URL,Found)
		Select @email_login,@guid,@ipaddress,@currTime,0,@url,1
	END
	ELSE
	BEGIN
		insert into dbo.ForgotPasswordLog(Login,Token,IPAddress,EntyDate,IsUsed,URL,Found)
		Select @email_login,@guid,@ipaddress,@currTime,0,'',0
	END
	
	Select @email

END











