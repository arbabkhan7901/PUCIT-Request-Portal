CREATE TABLE [dbo].[ActivityLogTable] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [RequestId]       INT           NOT NULL,
    [UserId]          INT           NOT NULL,
    [Comments]        VARCHAR (MAX) NULL,
    [Activity]        VARCHAR (MAX) NOT NULL,
    [ActivityTime]    DATETIME      NOT NULL,
    [IsPrintable]     BIT           CONSTRAINT [DF__ActivityL__IsPri__2739D489] DEFAULT ((0)) NULL,
    [VisibleToUserID] INT           NULL,
    [CanReplyUserID]  INT           NULL,
    [ShowActionPanel] BIT           DEFAULT ((0)) NOT NULL,
    [UpdatedTime]     DATETIME      NULL,
    CONSTRAINT [PK_ActivityLogTable] PRIMARY KEY CLUSTERED ([Id] ASC)
);

