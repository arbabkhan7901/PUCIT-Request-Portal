CREATE Procedure [dbo].[IsValidResetToken]
@reset_token varchar(50)
AS
BEGIN
	IF (Select count(*) from dbo.users Where ResetToken = @reset_token and IsActive = 1) = 1
	BEGIN
		Select cast(1 as bit)
		RETURN;
	END

	Select cast(0 as bit)

END








