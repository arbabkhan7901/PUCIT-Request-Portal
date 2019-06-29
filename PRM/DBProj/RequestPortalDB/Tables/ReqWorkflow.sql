CREATE TABLE [dbo].[ReqWorkflow] (
    [ID]             INT      IDENTITY (1, 1) NOT NULL,
    [RequestID]      INT      NOT NULL,
    [ApproverID]     INT      NOT NULL,
    [UserID]         INT      NOT NULL,
    [AltApproverID]  INT      NULL,
    [ApprovalOrder]  INT      NOT NULL,
    [Status]         INT      NOT NULL,
    [Remarks]        TEXT     NULL,
    [EntryTime]      DATETIME NOT NULL,
    [StatusTime]     DATETIME NULL,
    [ActionUserID]   INT      NOT NULL,
    [UpdateTime]     DATETIME NULL,
    [IsCurrApprover] BIT      CONSTRAINT [DF__ReqWorkfl__IsCur__4B7734FF] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ReqWorkflow] PRIMARY KEY CLUSTERED ([ID] ASC)
);

