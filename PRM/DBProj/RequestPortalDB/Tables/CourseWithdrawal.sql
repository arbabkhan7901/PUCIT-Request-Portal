CREATE TABLE [dbo].[CourseWithdrawal] (
    [RequestID]   INT           NOT NULL,
    [CourseID]    VARCHAR (50)  NOT NULL,
    [CourseTitle] VARCHAR (100) NOT NULL,
    [CreditHours] INT           NOT NULL,
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [TeacherName] VARCHAR (50)  NULL,
    [ApproverID]  INT           NOT NULL,
    CONSTRAINT [PK_CourseWithdrawal] PRIMARY KEY CLUSTERED ([ID] ASC)
);



