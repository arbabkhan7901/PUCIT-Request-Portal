CREATE TABLE [dbo].[OptionForBscDegree] (
    [RequestID]   INT          NOT NULL,
    [CNIC]        NCHAR (15)   NOT NULL,
    [dateOfBirth] DATETIME     NOT NULL,
    [PUreg]       VARCHAR (50) NOT NULL,
    [fatherSign]  VARCHAR (50) NOT NULL,
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_OptionForBscDegree] PRIMARY KEY CLUSTERED ([ID] ASC)
);

