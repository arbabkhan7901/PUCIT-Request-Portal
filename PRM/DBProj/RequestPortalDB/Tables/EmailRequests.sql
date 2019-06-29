CREATE TABLE [dbo].[EmailRequests] (
    [EmailRequestID]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [Subject]            VARCHAR (150) NOT NULL,
    [MessageBody]        VARCHAR (500) NOT NULL,
    [MessageParameters]  VARCHAR (500) NULL,
    [EmailTo]            VARCHAR (200) NOT NULL,
    [EmailCC]            VARCHAR (200) NULL,
    [EmailBCC]           VARCHAR (200) NULL,
    [EmailTemplate]      VARCHAR (50)  NULL,
    [ScheduleType]       INT           NOT NULL,
    [ScheduleTime]       DATETIME      NULL,
    [EmailRequestStatus] INT           NOT NULL,
    [EntryTime]          DATETIME      CONSTRAINT [DF__EmailRequ__Entry__656C112C] DEFAULT (getdate()) NULL,
    [UniqueID]           VARCHAR (40)  NULL,
    [RequestID]          INT           NULL,
    [EmailDetails] VARCHAR(500) NULL, 
    CONSTRAINT [PK_EmailRequests] PRIMARY KEY CLUSTERED ([EmailRequestID] ASC)
);

