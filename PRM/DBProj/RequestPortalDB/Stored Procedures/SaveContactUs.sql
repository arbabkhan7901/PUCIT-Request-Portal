
CREATE procedure [dbo].[SaveContactUs]
	@ID bigint,
	@Name varchar(100),
	@Email varchar(100),
	@MachineIP varchar(20),
	@Description varchar(500),
	@CreationDate datetime
AS
Begin
	Declare @return bigint=1
	Insert into dbo.ContactUs(Name,Email,MachineIP, Description,EntryTime)
	values( @Name,@Email,@MachineIP,@Description,@CreationDate)
	select @return
End








