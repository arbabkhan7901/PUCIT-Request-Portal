CREATE TABLE [dbo].[RoomReservation] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [RequestID]            INT          NOT NULL,
    [TotalStudents]        INT          NOT NULL,
    [TimeFrom]             DATETIME     NOT NULL,
    [TimeTo]               DATETIME     NOT NULL,
    [Purpose]              VARCHAR (50) NOT NULL,
    [isMultimediaRequired] BIT          NOT NULL,
    [Date]                 DATETIME     NULL
);

