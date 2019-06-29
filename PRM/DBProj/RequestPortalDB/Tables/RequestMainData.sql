CREATE TABLE [dbo].[RequestMainData] (
    [RequestID]       INT           IDENTITY (1, 1) NOT NULL,
    [CategoryID]      INT           NOT NULL,
    [UserId]          INT           NOT NULL,
    [RollNo]          VARCHAR (20)  NOT NULL,
    [CreationDate]    DATETIME      NULL,
    [TargetSemester]  INT           NULL,
    [Reason]          VARCHAR (200) NULL,
    [TargetDate]      DATE          NULL,
    [CurrentSemester] INT           NULL,
    [RequestStatus]   INT           NOT NULL,
    [Subject]         VARCHAR (50)  NULL,
    [LastModifiedOn]  DATETIME      NULL,
    [IsRecievingDone] BIT           DEFAULT ((0)) NULL,
    [CanStudentEdit]  BIT           DEFAULT ((0)) NULL,
    [RequestToken]    VARCHAR (40)  NULL,
    [ReqUniqueId]     VARCHAR (40)  NOT NULL,
    [ActionDate]      DATETIME      NULL,
    CONSTRAINT [PK_RequestMainData] PRIMARY KEY CLUSTERED ([RequestID] ASC)
);



