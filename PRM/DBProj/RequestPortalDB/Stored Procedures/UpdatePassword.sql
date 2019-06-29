

CREATE Procedure [dbo].[UpdatePassword]
@Token_Login varchar(50),
@CurrPassword varchar(50),
@NewPassword varchar(50),
@CurrTime datetime,
@ModifiedBy int,
@IsChangePassword bit
AS
BEGIN
	
	IF @IsChangePassword = 1 -- Change Password
	BEGIN
		IF  (SELECT count(*) FrOM dbo.Users
			Where Login =@Token_Login AND Password = @CurrPassword and IsActive = 1 and IsDisabledForLogin =0) = 1
		BEGIN
			Update dbo.Users set Password = @NewPassword, ModifiedBy =@ModifiedBy, ModifiedOn = @CurrTime 
			Where Login =@Token_Login AND Password = @CurrPassword and IsActive = 1 and IsDisabledForLogin =0
			Select cast(1 as bit)
			RETURN;
		END
	END
	ELSE  -- RESET Password
	BEGIN
		IF (Select count(*) from dbo.users Where ResetToken =@Token_Login  and IsActive = 1) = 1
		BEGIN
			Update dbo.Users set Password = @NewPassword, ModifiedBy =@ModifiedBy, ModifiedOn = @CurrTime, ResetToken=null 
			Where ResetToken =@Token_Login  and IsActive = 1

			Update dbo.ForgotPasswordLog SET IsUsed = 1,UpdatedOn = @CurrTime Where Token = @Token_Login

			Select cast(1 as bit)
			RETURN;
		END
	END

	Select cast(0 as bit)

END










