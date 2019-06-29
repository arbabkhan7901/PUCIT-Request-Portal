CREATE TABLE [dbo].[Permissions] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50) NOT NULL,
    [Description] VARCHAR (50) NOT NULL,
    [CreatedBy]   INT          DEFAULT ((1)) NOT NULL,
    [CreatedOn]   DATETIME     DEFAULT (getutcdate()) NOT NULL,
    [Modifiedby]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
    [IsActive]    BIT          DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED ([Id] ASC)
);

