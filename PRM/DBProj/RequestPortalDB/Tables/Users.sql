CREATE TABLE [dbo].[Users] (
    [UserId]             INT           IDENTITY (1, 1) NOT NULL,
    [Login]              VARCHAR (50)  NOT NULL,
    [Password]           VARCHAR (100) NOT NULL,
    [Name]               VARCHAR (100) NOT NULL,
    [Title]              VARCHAR (100) NULL,
    [Email]              VARCHAR (100) NULL,
    [SignatureName]      VARCHAR (50)  NULL,
    [StdFatherName]      VARCHAR (100) NULL,
    [Section]            VARCHAR (25)  NULL,
    [IsContributor]      BIT           CONSTRAINT [DF__Users__IsContrib__44CA3770] DEFAULT ((0)) NULL,
    [IsOldCampus]        BIT           NOT NULL,
    [CreatedBy]          INT           DEFAULT ((1)) NOT NULL,
    [CreatedOn]          DATETIME      DEFAULT (getutcdate()) NOT NULL,
    [Modifiedby]         INT           NULL,
    [ModifiedOn]         DATETIME      NULL,
    [IsActive]           BIT           DEFAULT ((1)) NOT NULL,
    [IsDisabledForLogin] BIT           NULL,
    [ResetToken]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_Users_1] PRIMARY KEY CLUSTERED ([UserId] ASC)
);

