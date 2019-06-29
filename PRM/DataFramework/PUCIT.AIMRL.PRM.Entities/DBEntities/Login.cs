using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;
namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{

    [Table("dbo.Users")]
    public class User
    {
        [Key]
        public int UserId { get; set; }
        public String Login { get; set; }
        public String Password { get; set; }
        public String Name { get; set; }
        public String Title { get; set; }
        public String Email { get; set; }
        public Boolean IsActive { get; set; }
        public String SignatureName { get; set; }
        public String StdFatherName { get; set; }
        public String Section { get; set; }
        public Boolean IsContributor { get; set; }
        public Boolean IsOldCampus { get; set; }

        public int CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }

        public Boolean IsDisabledForLogin { get; set; }

        [NotMapped]
        public List<ApprDesigDTO> ApprDesignations
        {
            get;
            set;
        }
    }

    public class Approver
    {
        public int WFID { get; set; }
        public int ApproverID { get; set; }
        public String Login { get; set; }
        public String Name { get; set; }
        public String Designation { get; set; }
        public String Email { get; set; }

        public int WorkFlowStatus { get; set; }
    }

    public class UserDTOForAutoComplete
    {
        public int UserId { get; set; }
        public String Login { get; set; }
        public String Name { get; set; }
    }
    public class LoginHistorySearchParam
    {
        public LoginHistorySearchParam()
        {
            SDate = new DateTime(1900, 1, 1);
            EDate = DateTime.MaxValue;
            Login = "";
            MachineIp = "";
            PageSize = 10;
            PageIndex = 0;
        }
        public String Login { get; set; }
        public String MachineIp { get; set; }
        public DateTime SDate { get; set; }
        public DateTime EDate { get; set; }
        public int PageSize { get; set; }
        public int PageIndex { get; set; }
    }

    public class ActivityLogSearchParam
    {
        public ActivityLogSearchParam()
        {
            PageSize = 10;
            PageIndex = 0;
        }
        public int PageSize { get; set; }
        public int PageIndex { get; set; }
    }

    public class AppStatusesSearchParam
    {
        public AppStatusesSearchParam()
        {

            Login = "";
            IsApprover = 0;
            Status = 0;
            SDate = new DateTime(1900, 1, 1);
            EDate = DateTime.MaxValue;
        }
        public String Login { get; set; }
        public int IsApprover { get; set; }
        public int Status { get; set; }    public DateTime SDate { get; set; }
        public DateTime EDate { get; set; }
    }
    public class UserSearchParam
    {
        public String TextToSearch { get; set; }
        public int IsActive { get; set; }
        public int IsContributor { get; set; }
        public int IsOldCampus { get; set; }
        public int PageSize { get; set; }
        public int PageIndex { get; set; }
    }

    public class UserSearchResultObj
    {
        public int UserId { get; set; }
        public String Login { get; set; }
        public String Name { get; set; }
        public String Title { get; set; }
        public String Email { get; set; }
        public Boolean IsActive { get; set; }
        public String SignatureName { get; set; }
        public String StdFatherName { get; set; }
        public String Section { get; set; }
        public Boolean IsContributor { get; set; }
        public Boolean IsOldCampus { get; set; }

        [NotMapped]
        public String IsContributorStr
        {
            get
            {
                return (this.IsContributor == true ? "Yes" : "No");

            }
        }

    }

    public class UserSearchResult
    {
        public int ResultCount { get; set; }
        public List<UserSearchResultObj> Result { get; set; }
    }
    public class LoginHistorySearchResult
    {
        public int ResultCount { get; set; }
        public List<LoginHistory> Result { get; set; }
    }


    public class ActivityLogReportSearchResult
    {
        public int ResultCount { get; set; }
        public List<ActivityLogTable> Result { get; set; }
    }


    public class GoogleUserSearchResultObj
    {
        public long ID { get; set; }
        public int UserId { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public Boolean IsUsed { get; set; }

        public DateTime UserCreatedOn { get; set; }

        public DateTime EntryTime { get; set; }

        [NotMapped]
        public String UserCreatedOnStr
        {
            get
            {
                if (this.IsUsed)
                    return HelperMethods.ChangeDTFormat(this.UserCreatedOn);
                else
                    return "";
            }
        }
        [NotMapped]
        public String EntryTimeOnStr
        {
            get
            {
                return HelperMethods.ChangeDTFormat(this.EntryTime);
            }
        }
    }


    public class GoogleUserSearchResult
    {
        public int ResultCount { get; set; }
        public List<GoogleUserSearchResultObj> Result { get; set; }
    }
    public class AppItemSearchParam
    {
        public AppItemSearchParam()
        {

            Login = "";
            Name = "";
            Item = "";
            SDate = new DateTime(1900, 1, 1);
            EDate = DateTime.MaxValue;
            searchType = 0;
        }
        public String Login { get; set; }
        public String Name { get; set; }
        public String Item { get; set; }
        public DateTime SDate { get; set; }
        public DateTime EDate { get; set; }
        public int searchType { get; set; }
    }
}
