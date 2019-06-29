USE [TrainingDB]
GO
/****** Object:  StoredProcedure [dbo].[DeactivateStudent]    Script Date: 8/21/2015 10:29:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeactivateStudent]
	@StudentId int,
	@ModifiedBy varchar(100),
	@ModifiedOn DateTime
AS
BEGIN
	

	Update dbo.SampleStudents
		SET 
		ModifiedBy = @ModifiedBy,
		ModifiedOn = @ModifiedOn,
		IsActive = 0
		
	WHERE StudentId = @StudentId

	
	select @StudentId

END

GO
/****** Object:  StoredProcedure [dbo].[SaveStudent]    Script Date: 8/21/2015 10:29:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveStudent]
	@StudentId int,
	@FirstName varchar(100),
	@LastName varchar(100),
	@DateOfBirth Date,
	@Gender char(1),
	@Education int,
	@CreatedBy varchar(100),
	@CreatedOn DateTime
AS
BEGIN
	
	if (@StudentId > 0)
	BEGIN

		Update dbo.SampleStudents
			SET FirstName = @FirstName, 
			LastName = @LastName, 
			DateOfBirth = @DateOfBirth, 
			Gender=@Gender, 
			Education=@Education, 
			ModifiedBy = @CreatedBy,
			ModifiedOn = @CreatedOn
		
		WHERE StudentId = @StudentId

	END
	ELSE
	BEGIN
		
		INSERT INTO dbo.SampleStudents(FirstName, LastName, DateOfBirth, Gender, Education, IsActive, CreatedBy, CreatedOn)
		VALUES(@FirstName,@LastName,@DateOfBirth,@Gender,@Education,1,@CreatedBy,@CreatedOn)

		Select @StudentId = SCOPE_IDENTITY()
	END

	Select @StudentId
END

GO
/****** Object:  StoredProcedure [dbo].[SearchStudents]    Script Date: 8/21/2015 10:29:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SearchStudents]
	@pNameToSearch varchar(100)
AS
BEGIN
	
	Select StudentId, FirstName, LastName, DateOfBirth, Gender, 
	Education, IsActive, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn

	From [dbo].[SampleStudents] 
	Where FirstName Like '%' +@pNameToSearch + '%'
	OR LastName Like '%' +@pNameToSearch + '%'
		
END

GO
/****** Object:  Table [dbo].[SampleStudents]    Script Date: 8/21/2015 10:29:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SampleStudents](
	[StudentId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[Gender] [char](1) NOT NULL,
	[Education] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](100) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
