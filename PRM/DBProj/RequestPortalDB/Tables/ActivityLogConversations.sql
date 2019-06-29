CREATE TABLE [dbo].[ActivityLogConversations] (
    [ConversationID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ActivityLogID]  INT           NOT NULL,
    [UserID]         INT           NOT NULL,
    [Message]        VARCHAR (200) NOT NULL,
    [MessageTime]    DATETIME      NOT NULL,
    CONSTRAINT [PK_ActivityLogConversations] PRIMARY KEY CLUSTERED ([ConversationID] ASC)
);

