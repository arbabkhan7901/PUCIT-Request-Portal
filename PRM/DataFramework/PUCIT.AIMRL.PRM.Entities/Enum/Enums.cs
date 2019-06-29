using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.Enum
{
    public enum ApplicationAccessType
    {
        None = 0,
        SelfCreated = 1,
        Assigned = 2,
        OtherThanSelfAndAssigned = 3,
        All = 4,
       
    }

    public enum ApplicationStatus
    {
        None = 0,
        NotAssigned = 1,
        Pending = 2,
        Approved = 3,
        Rejected = 4,
        NewApplication =6
    }
    public enum RequestWorkFlowStatus
    {
        None = 0,
        NotAssigned = 1,
        Pending = 2,
        Accepted =3,
        Rejected =4,
        RejectedBeforeAssignment =5
    }
    public enum ApplicationCategoryEnum
    {
        CLEARANCE_FORM = 1,
        LEAVE_APPLICATION_FORM = 2,
        OPTION_FOR_BSc_DEGREE = 3,
        FINAL_ACADAEMIC_TRANSCRIPT_FORM = 4,
        COLLEGE_IDCARD_FORM = 5,
        MOTORCYCLE_TOKEN_FORM = 6,
        RECEIPT_OF_ORIG_EDU_DOCS_FORM = 7,
        BONAFIDE_CHARACTER_CERTIFICATE_FORM = 8,
        SEMESTER_FREEZE_WITHDRAWAL_FORM = 9,
        SEMESTER_REJOIN_FORM = 10,
        SEMESTER_ACADAEMIC_TRANSCRIPT_FORM = 11,
        COURSE_WITHDRAWAL_FORM = 12,
        GENERAL_REQUEST_FORM = 13,
    }

    public enum EmailRequestStatus
    {
        None = 0,
        Pending = 1,
        Processed = 2
    }
    public enum LoginType
    {
        Normal = 1,
        LoginAs = 2,
        LoginBack=3,
        GoogleLogin=4,
        GAccessToken =5
    }
}
