CREATE TABLE [dbo].[Roles] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (50) NOT NULL,
    [Description] VARCHAR (50) NOT NULL,
    [IsActive]    BIT          DEFAULT ((1)) NOT NULL,
    [CreatedBy]   INT          NOT NULL,
    [CreatedOn]   DATETIME     DEFAULT (getdate()) NOT NULL,
    [Modifiedby]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([Id] ASC)
);

