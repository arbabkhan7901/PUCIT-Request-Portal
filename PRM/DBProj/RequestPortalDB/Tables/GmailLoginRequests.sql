CREATE TABLE [dbo].[GmailLoginRequests] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [Email]         VARCHAR (100) NULL,
    [Name]          VARCHAR (100) NULL,
    [Gmail_Id]      VARCHAR (50)  NULL,
    [Gmail_Pic]     VARCHAR (200) NULL,
    [EntryTime]     DATETIME      NULL,
    [IsUsed]        BIT           NULL,
    [UserId]        INT           NULL,
    [UserCreatedOn] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

