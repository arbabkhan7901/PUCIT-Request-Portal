CREATE TABLE [dbo].[TypesForContributor]
(
	[TypeID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [TypeName] VARCHAR(50) NOT NULL, 
    [Description] VARCHAR(500) NOT NULL 
)
