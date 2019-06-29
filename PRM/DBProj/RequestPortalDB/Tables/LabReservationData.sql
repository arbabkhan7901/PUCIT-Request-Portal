CREATE TABLE [dbo].[LabReservationData] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [RequestId]    INT          NOT NULL,
    [CourseTitle]  VARCHAR (50) NOT NULL,
    [noOfComputer] INT          NOT NULL,
    [SuggestedLab] VARCHAR (50) NOT NULL,
    [Day]          VARCHAR (50) NULL,
    [PerTimeFrom]  DATETIME     NULL,
    [PerTimeTo]    DATETIME     NULL,
    [TempDateFrom] DATE         NULL,
    [TempDateTo]   DATE         NULL,
    [TempTimeFrom] DATETIME     NULL,
    [TempTimeTo]   DATETIME     NULL,
    [IsPermanent]  BIT          NOT NULL,
    [IsTemporary]  BIT          NOT NULL
);

