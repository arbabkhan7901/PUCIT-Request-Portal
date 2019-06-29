CREATE TABLE [dbo].[SemesterAcademicTranscript] (
    [id]        INT          IDENTITY (1, 1) NOT NULL,
    [RequestID] INT          NULL,
    [ChallanNo] VARCHAR (50) NULL,
    CONSTRAINT [PK_SemesterAcademicTranscript] PRIMARY KEY CLUSTERED ([id] ASC)
);

