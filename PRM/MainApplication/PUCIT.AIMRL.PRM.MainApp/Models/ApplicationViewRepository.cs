using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Configuration;
using System.Collections;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities.Enum;
using PUCIT.AIMRL.PRM.MainApp.Security;
using iTextSharp.text.pdf;
using iTextSharp.text;
using System.Net.Http;
using System.Net;
using System.Net.Http.Headers;
using iTextSharp.text.pdf.draw;
using PUCIT.AIMRL.Common;


namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class ApplicationViewRepository
    {
        private PRMDataService _dataService;
        public ApplicationViewRepository()
        {

        }

        private PRMDataService DataService
        {
            get
            {
                if (_dataService == null)
                    _dataService = new PRMDataService();

                return _dataService;
            }
        }


        public List<CustomAttachments> getAttachments(int requestID,String reqUniqueId)
        {
            List<CustomAttachments> Attach = new List<CustomAttachments>();
            Attach = DataService.GetAttachment(requestID, reqUniqueId);
            return Attach;
        }
        public ResponseResult GetAttachment(int requestID, String reqUniqueId)
        {
            try
            {
                var Attach = getAttachments(requestID, reqUniqueId);
                var data = new
                {
                    AttachmentList = Attach
                };

                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public FormData GetFormMainData(int RequestId,String requestUniqueId, out List<String> docs)
        {
            docs = new List<string>();

            FormData formdata = new FormData();
            formdata.MainData = DataService.GetRequestMainDataByID(RequestId, requestUniqueId);
            if (formdata.MainData == null)
            {
                return null;
            }
              if (formdata.MainData.CategoryID == 1) {
                formdata.ClearanceFormData = DataService.getClearance(RequestId);               
            }
            if (formdata.MainData.CategoryID == 2)
            {
                formdata.LeaveApplication = DataService.getLeave(RequestId);
            }

            if (formdata.MainData.CategoryID == 3)
            {
                formdata.OptionForBsc = DataService.getOptionForBsc(RequestId);
            }
            

            if (formdata.MainData.CategoryID == 4)
            {
                formdata.FinalTranscript = DataService.getFinalTranscript(RequestId);

            }

            if (formdata.MainData.CategoryID == 5)
            {
                formdata.CollegeIdCard = DataService.getCollegeIdCard(RequestId);
            }

            if (formdata.MainData.CategoryID == 6)
            {
                formdata.VehicalToken = DataService.getVehicalToken(RequestId);
            }

            if (formdata.MainData.CategoryID == 7)
            {
                docs = DataService.getDocuments(RequestId);
                //docs = DataService.getReceiptOfOriginal(RequestId);
            }

            if (formdata.MainData.CategoryID == 8)
            {
                formdata.BonafideCertificate = DataService.getBonafideCertificate(RequestId);
            }
            //condition 9 will be satisfied by just FormData.MainData

            if (formdata.MainData.CategoryID == 10)
            {
                formdata.SemesterRejoin = DataService.getSmesterRejoin(RequestId);
            }
            if (formdata.MainData.CategoryID == 11)
            {
                formdata.SemesterAcadamicTranscript = DataService.getSemesterAcadamicTranscript(RequestId);
            }
            if (formdata.MainData.CategoryID == 12)
            {
                formdata.CourseWithdrawdata = DataService.getCourseWithdrawData(RequestId);
            }
            if (formdata.MainData.CategoryID == 14)
            {
                formdata.ItemDemandForm = DataService.getItemDemandFormData(RequestId);
            }
            if (formdata.MainData.CategoryID == 15) {
                formdata.HardwareFormItems = DataService.getHardwareFormItems(RequestId);
            }
            if (formdata.MainData.CategoryID== 16)
            {
                formdata.DemandVoucherItems = DataService.getDemandVoucher(RequestId);
            }
            if (formdata.MainData.CategoryID == 17) {
                formdata.StoreDemandVoucher = DataService.getStoreDemandVoucher(RequestId);
            }
            if (formdata.MainData.CategoryID== 18)
            {
                formdata.LabReservation = DataService.getLabReservationFormData(RequestId);   
            }
            if (formdata.MainData.CategoryID == 19)
            {
                formdata.RoomReservation = DataService.getRoomReservationData(RequestId);
            }
            
            return formdata;
        }
        public ResponseResult GetFormData(int RequestId, String requestUniqueId)
        {
            try
            {
                List<string> docs = new List<string>();
                var formdata = GetFormMainData(RequestId, requestUniqueId, out docs);
                if (formdata == null) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    StudentList = formdata,
                    StudentName = formdata.MainData.ApplicantName,
                    courses = formdata.CourseWithdrawdata,
                    items = formdata.ItemDemandForm,
                    hardItems = formdata.HardwareFormItems,
                    demandItems= formdata.DemandVoucherItems,
                    storeDemand = formdata.StoreDemandVoucher,
                    DocumentList = docs,
                    docList = docs.Select(p => new { Name = p }).ToList(),
                    //CurrentUserReqWFStatus = status,
                    //RecFlag = recievedFlag,
                    //EditFlag = editFlag,
                    //RB = showRouteBack
                };
                return ResponseResult.GetSuccessObject(data,"");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }


        public ResponseResult GetFormApprovers(int pApplicationId, String reqUniqueId)
        {
            try
            {

                var approvers = DataService.GetFormApprovers(pApplicationId, reqUniqueId);

                if (approvers.Count == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    ContributorList = approvers.Select(p => new { p.WFID, p.ApproverID, p.Designation, p.Name, p.WorkFlowStatus }).ToList(),
                    //ApplicantName = SessionManager.CurrentUser.UserFullName,
                    //ApplicantUserId = SessionManager.CurrentUser.UserId
                };
                return ResponseResult.GetSuccessObject(data,"");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }


        public ResponseResult ApproveRequest(ReqWorkflow ApproveRequestData)
        {
            
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    ApproveRequestData.Remarks += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                ApproveRequestData.ApproverID = SessionManager.CurrentUser.CurrentApproverID;
                ApproveRequestData.Status = (int)ApplicationStatus.Approved;

                if (ApproveRequestData.Remarks == null)
                {
                    ApproveRequestData.Remarks = "";
                }
                var result = DataService.ApproveRejectRequest(ApproveRequestData);
                if (result == 0)
                {
                    return ResponseResult.GetErrorObject("Invalid Try");
                }
                return ResponseResult.GetSuccessObject(result,"");
            }


            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }


        }

        //Reject 
        public ResponseResult RejectRequest(ReqWorkflow RequestData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    RequestData.Remarks += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";

                }
                RequestData.ApproverID = SessionManager.CurrentUser.CurrentApproverID;
                RequestData.Status = (int)ApplicationStatus.Rejected;
                
                if (RequestData.Remarks == null)
                {
                    RequestData.Remarks = "";
                }
                var result = DataService.ApproveRejectRequest(RequestData);

                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }

                return ResponseResult.GetSuccessObject(result,"");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult RouteBack(ReqWorkflow data)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    data.Remarks += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                data.ApproverID = SessionManager.CurrentUser.CurrentApproverID;
                if (data.Remarks == null)
                {
                    data.Remarks = "";
                }
                var result = DataService.RouteBack(data);

                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Attempt");
                }
                var retdata = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(retdata, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public Object insertNewFlow(ChangeContributors obj)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return (new
                {
                    success = false,
                    error = "You Are Not Allowed"
                });
            }
            try
            {
                obj.CurrentUserId = SessionManager.CurrentUser.CurrentApproverID;

                var result = DataService.insertNewFlowSP(obj);

                return (new
                {
                    data = new
                    {
                        data = result
                    },
                    success = true,
                    error = ""
                });
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        public Object SearchContributor(string key)
        {
            try
            {
                if (PermissionManager.PerCanAddContributer || PermissionManager.perManageWorkFlows)
                {
                    var list = DataService.SearchContributor(key);

                    var result = (from p in list
                                  select new
                                  {
                                      ID = p.ApproverID,
                                      NME = p.Name,
                                      Desg = p.Designation
                                  }).ToList();
                    return result;
                }
                else
                {
                    return (new
                    {
                        success = false,
                        error = "Invalid Request"
                    });
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        public List<ActivityLogTable> GetLogData(int RequestId, String reqUniqueId)
        {
            var user = SessionManager.CurrentUser;

            var userId = user.UserId;

            if (user.AppAccessType == ApplicationAccessType.Assigned)
                userId = user.CurrentApproverID;

            var result = DataService.GetActivityLogData(RequestId, reqUniqueId, user.AppAccessType, userId);
            return result;
        }

        public Object GetLogList(int requestId, String reqUniqueId)
        {
            try
            {
                var result = GetLogData(requestId, reqUniqueId);
                var data = new
                {
                    LogList = result,
                    CommentsForPrint = result.Where(p => p.IsPrintable == true).OrderBy(p => p.Id).ToList()
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        public Object SaveRemarks(ActivityLogTable data)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    data.Comments += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                data.UserId = SessionManager.CurrentUser.CurrentApproverID;
                data.ActivityTime = DateTime.UtcNow;
                var result = DataService.SaveRemarks(data);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var retdata = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(retdata,"");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public Object SaveReview(ActivityLogTable data)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    data.Comments += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                data.UserId = SessionManager.CurrentUser.UserId;
                data.VisibleToUserID = 0;
                data.IsPrintable = false;
                data.CanReplyUserID = 0;
                data.ActivityTime = DateTime.UtcNow;
                var result = DataService.SaveReview(data);
                if (result == 0)
                {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var retdata = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(retdata, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult HandleRecieving(ActivityLogTable dataToSend)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    dataToSend.Comments += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                dataToSend.UserId = SessionManager.CurrentUser.CurrentApproverID;
                dataToSend.ActivityTime = DateTime.UtcNow;
                var result = DataService.HandleRecieving(dataToSend);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Inavlid Access");
                }
                var retdata = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(retdata, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public Object searchApplications(SearchEntity pSearchParam)
        {
            try
            {
                InboxRepository repo = new InboxRepository();
                pSearchParam.Status = (int)ApplicationStatus.Pending;

                var data = repo.SearchApplications(pSearchParam);
                return data;
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        //public Boolean IsRequestIDValid(int requestId)
        //{
        //    var obj = DataService.GetApplicationAccessData(requestId, SessionManager.CurrentUser.AppAccessType, SessionManager.CurrentUser.UserId, true);
        //    if (obj != null && obj.IsValidAccess)
        //        return true;
        //    else
        //        return false;
        //}
        public ApplicationAccessData GetApplicationAccessData(int requestId)
        {
            try
            {
                var user = SessionManager.CurrentUser;

                var userId = user.UserId;

                if (user.AppAccessType == ApplicationAccessType.Assigned)
                    userId = user.CurrentApproverID;

                return DataService.GetApplicationAccessData(requestId, user.AppAccessType, userId, false);
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return null;
            }

        }
        public ResponseResult ValidateRequestAccess(int requestId)
        {
            ApplicationAccessData data = null;

            if (requestId > 0)
            {
                ApplicationViewRepository repo = new ApplicationViewRepository();
                data = repo.GetApplicationAccessData(requestId);

                if (data != null && data.IsValidAccess == false)
                {
                    return ResponseResult.GetErrorObject("Invalid Request ID");
                }
                else
                {
                    return ResponseResult.GetSuccessObject();
                }
            }
            else
            {
                return ResponseResult.GetErrorObject("Invalid Request ID");
            }
        }


        public Object SaveActivityLogConverstation(ActivityLogConversation data)
        {
            
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    data.Message += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }
                var user = SessionManager.CurrentUser;

                data.UserID = user.UserId;
                data.MessageTime = DateTime.UtcNow;
                var result = DataService.SaveActivityLogConverstation(data, user.AppAccessType, user.CurrentApproverID);
                data.ConversationID = result;
                data.UserName = SessionManager.CurrentUser.UserFullName;
                data.MessageTime = DataService.ConvertfromUTC(data.MessageTime);
                if (result > 0)
                {
                    return ResponseResult.GetSuccessObject(data, "");
                }
                else
                {
                    return ResponseResult.GetErrorObject("Invalid Request");
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public Object GetActivityLogConverstations(int requestId, long activityLogId,String ReqUniqueId)
        {
            try
            {
                var user = SessionManager.CurrentUser;

                var result = DataService.GetActivityLogConverstations(requestId, ReqUniqueId, activityLogId, user.AppAccessType, user.UserId, user.CurrentApproverID);
                //if (result.Count == 0)
                //{
                //    return ResponseResult.GetErrorObject("Invalid Access");
                //}

                var data = new
                {
                    ConversationList = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult EnableDisableRequestEdit(int requestId,String ReqUniqueId, Boolean CanStudentEdit, String pRemarks)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == true)
                {
                    pRemarks += " ---------[By " + SessionManager.ActualUserLoginID + " on behalf of]";
                }

                if (PermissionManager.PerCanAllowApplicationEditing == false)
                {
                    return ResponseResult.GetErrorObject("Invalid Request");
                }

                var result = DataService.EnableDisableRequestEdit(requestId,ReqUniqueId, DateTime.UtcNow, SessionManager.CurrentUser.CurrentApproverID, CanStudentEdit, pRemarks);

                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UpdateActivityLogActionItem(int requestId, String ReqUniqueId, int actId, int type, int value)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var user = SessionManager.CurrentUser;

                if (user.AppAccessType != ApplicationAccessType.Assigned)
                {
                    return ResponseResult.GetErrorObject("Invalid Request");
                }

                var result = DataService.UpdateActivityLogActionItem(requestId,ReqUniqueId, actId, DateTime.UtcNow, user.CurrentApproverID, type, value);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Try");
                }
                var data = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UpdateCGPA(int requestId, String ReqUniqueId, double cgpa)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var user = SessionManager.CurrentUser;
                cgpa = Convert.ToDouble(cgpa);

                if (user.AppAccessType != ApplicationAccessType.Assigned || PermissionManager.PerUpdateBonaFiedCGPA == false)
                {
                    return ResponseResult.GetErrorObject("Invalid Request");
                }


                var result = DataService.UpdateCGPA(requestId,ReqUniqueId, cgpa, DateTime.UtcNow, user.CurrentApproverID, SessionManager.ActualUserLoginID);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }


        public ResponseResult RemoveContributor(int requestId,String ReqUniqueId, int wfId, int approverIdToRemove)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You are not allowed to Perform this action");
            }
            try
            {
                var user = SessionManager.CurrentUser;


                var result = DataService.RemoveContributor(requestId, ReqUniqueId, wfId, approverIdToRemove, DateTime.UtcNow, user.CurrentApproverID, SessionManager.ActualUserLoginID);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult AddContributor(int requestId,String ReqUniqueId, int approverIdToAdd)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You are not allowed to Perform this action");
            }
            try
            {
                var user = SessionManager.CurrentUser;


                var result = DataService.AddContributor(requestId, ReqUniqueId, approverIdToAdd, DateTime.UtcNow, user.CurrentApproverID, SessionManager.ActualUserLoginID);
                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Access");
                }
                var data = result;
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UpdateContributorsOrder(int requestId,String ReqUniqueId, List<ReqWorkFlowShort> pReqWorkFlowList)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You are not allowed to Perform this action");
            }
            try
            {
                var user = SessionManager.CurrentUser;

                var result = DataService.UpdateContributorsOrder(requestId,ReqUniqueId, pReqWorkFlowList, DateTime.UtcNow, user.CurrentApproverID, SessionManager.ActualUserLoginID);

                if (result == 0) {
                    return ResponseResult.GetErrorObject("Invalid Try!");
                }
                var data = new
                {
                    data = result
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult SwapContributor(int requestId,String ReqUniqueId, int approverIdTo, String remarks)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true && PUCIT.AIMRL.PRM.UI.Common.SessionManager.CanDecideOnBehalfOfOther == false)
            {
                return ResponseResult.GetErrorObject("You are not allowed to perform this action");
            }

            try
            {
                var user = SessionManager.CurrentUser;
                return DataService.SwapContributor(requestId, ReqUniqueId, user.CurrentApproverID, approverIdTo, DateTime.UtcNow, remarks);

            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }

        public ResponseResult UpdateItems(CustomUpdateItems reqData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                var a = DataService.UpdateItems(reqData);

                if (a == 0)
                {
                    return ResponseResult.GetErrorObject("Quantity You Want to Issue is exceeding Stock limit. Please Check again");
                }
                else
                {
                    return ResponseResult.GetSuccessObject();
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }

        public ResponseResult UpdateIssuedQty(CustomUpdateIssuedQty reqData)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return ResponseResult.GetErrorObject("You Are Not Allowed");
            }
            try
            {
                DataService.UpdateIssuedQty(reqData);
                return ResponseResult.GetSuccessObject();
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }

        }

        public Object GenerateReqeuestPDF(int requestId, String reqUniqueId, bool auto = false)
        {
            //Check If User has access on this Request ID?
            if (PermissionManager.PerCanPrintApplication == false || ValidateRequestAccess(requestId).success == false)
            {
                //var r = new HttpResponseMessage(HttpStatusCode.Forbidden);
                var r = new HttpResponseMessage(HttpStatusCode.Redirect);

                //Redirect user to home page
                r.Headers.Add("Location", VirtualPathUtility.ToAbsolute("~") + "?error=Invalid");
                return r;
            }

            try
            {
                List<string> docs = new List<string>();
                FormData formdata = this.GetFormMainData(requestId, reqUniqueId, out docs);
                List<ActivityLogTable> list = this.GetLogData(requestId, reqUniqueId);
                List<CustomAttachments> attach = this.getAttachments(requestId, reqUniqueId);

                if (formdata == null || list == null) {
                    var r = new HttpResponseMessage(HttpStatusCode.Redirect);

                    //Redirect user to home page
                    r.Headers.Add("Location", VirtualPathUtility.ToAbsolute("~") + "?error=Invalid");
                    return r;
                }

                var appPhysicalPath = System.Web.HttpContext.Current.Server.MapPath("~/TempFiles");

                var fileName = Guid.NewGuid().ToString() + ".pdf";
                var filePath = appPhysicalPath + "\\" + fileName;


                var doc1 = new Document(iTextSharp.text.PageSize.A4);
                using (var streamObj = new System.IO.FileStream(filePath, System.IO.FileMode.CreateNew))
                {
                    PdfWriter writer = PdfWriter.GetInstance(doc1, streamObj);
                    doc1.Open();
                    writer.PageEvent = new Footer();

                    if (formdata.MainData.RequestStatus == 3)
                    {
                        GenerateQRCode(doc1, formdata.MainData.RequestToken);
                    }

                    GeneateFileHeader(doc1);
                    iTextSharp.text.Font labelFont = new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                    iTextSharp.text.Font contentFont = new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);



                    if (formdata.MainData.CategoryID == 1)
                    {
                        GenerateFormHeader(doc1, "Clearance Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        clearanceFormForPDF(doc1, formdata, attach, list, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 2)
                    {
                        GenerateFormHeader(doc1, "Leave Application Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        leaveApplicationForPDF(doc1, formdata, list, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 3)
                    {
                        GenerateFormHeader(doc1, "Option For Bsc Degree Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        optionForBscForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 4)
                    {
                        GenerateFormHeader(doc1, "Final Academic Transcript Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        finalTranscriptForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 5)
                    {
                        GenerateFormHeader(doc1, "College ID Card Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        College_IDForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 6)
                    {
                        GenerateFormHeader(doc1, "Vehicle Token Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        VehicalTokenForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 7)
                    {
                        GenerateFormHeader(doc1, "Receipt of Original Documents Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        originalDocumentForPDF(doc1, formdata, list, docs, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 8)
                    {
                        GenerateFormHeader(doc1, "Bonafied Certificate Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        bonafiedForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 9)
                    {
                        GenerateFormHeader(doc1, "Semester Freeze/Withdrawl Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        semesterFreezeForPDF(doc1, formdata, list, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 10)
                    {
                        GenerateFormHeader(doc1, "Semester Rejoin Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        semesterRejoinForPDF(doc1, formdata, list, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 11)
                    {
                        GenerateFormHeader(doc1, "Semester Academic Transcript Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        academicTranscriptForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 12)
                    {
                        GenerateFormHeader(doc1, "Course Withdraw Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        coureseWithdrawForPDF(doc1, formdata, list, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 13)
                    {
                        GenerateFormHeader(doc1, "General Request Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        generalRequestForPDF(doc1, formdata, list, attach, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 14)
                    {
                        GenerateFormHeader(doc1, "Item Demand Requisition Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        ItemDemandRequestForPDF(doc1, formdata, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 15)
                    {
                        GenerateFormHeader(doc1, "Hardware Request Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        HardwareRequestForPDF(doc1, formdata, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 16)
                    {
                        GenerateFormHeader(doc1, "Demand Voucher Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        DemandVoucherForPDF(doc1, formdata, labelFont, contentFont);
                    }

                    else if (formdata.MainData.CategoryID == 17)
                    {
                        GenerateFormHeader(doc1, "Store Demand Voucher Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        StoreDemandForPDF(doc1, formdata, labelFont, contentFont);
                    }
                    else if (formdata.MainData.CategoryID == 18) {
                        GenerateFormHeader(doc1, "Lab Reservation Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        LabReservationForPDF(doc1, formdata, labelFont, contentFont);

                    }
                    else if (formdata.MainData.CategoryID == 19)
                    {
                        GenerateFormHeader(doc1, "Room Reservation Form");
                        AddPersonalInformation(formdata, doc1, labelFont, contentFont);
                        RoomReservationForPDF(doc1, formdata, labelFont, contentFont);
                    }
                    
                    AddRemarks(formdata, doc1, list);
                    doc1.Close();
                }

                String fileDownloadableName = String.Format("Acad/{0}-{1}-{2}.pdf", formdata.MainData.RequestID, formdata.MainData.RollNo, DateTime.Now.ToString("dd/MM/yyyy hh:mm tt"));
                var response = DownloadPdfFile(fileName, appPhysicalPath, fileDownloadableName);
                if (auto == true) {
                    response.Content.Headers.ContentDisposition.FileName = fileName;
                }
                return response;
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                var r = new HttpResponseMessage(HttpStatusCode.Redirect);
                r.Headers.Add("Location", VirtualPathUtility.ToAbsolute("~") + "?error=Invalid");
                return r;
            }

        }

        #region PDF Helper Methods

        private void HardwareRequestForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            PdfPTable table1 = new PdfPTable(3);
            PdfPCell name = new PdfPCell(new Phrase("Item Name", labelFont));
            PdfPCell quantity = new PdfPCell(new Phrase("Quantity", labelFont));
            PdfPCell issuedQuantity = new PdfPCell(new Phrase("Issued Quantity", labelFont));
            table1.WidthPercentage = 50;
            name.Padding = 5;
            name.PaddingTop = 3;
            name.PaddingBottom = 5;
            table1.AddCell(name);
            quantity.Padding = 5;
            quantity.PaddingTop = 3;
            quantity.PaddingBottom = 5;
            table1.AddCell(quantity);
            issuedQuantity.Padding = 5;
            issuedQuantity.PaddingTop = 3;
            issuedQuantity.PaddingBottom = 5;
            table1.AddCell(issuedQuantity);

            for (int i = 0; i < formdata.HardwareFormItems.Count(); i++)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase(formdata.HardwareFormItems[i].ItemName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table1.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase(formdata.HardwareFormItems[i].Quantity.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell2);
                PdfPCell cell3 = new PdfPCell(new Phrase(formdata.HardwareFormItems[i].IssuedQty.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell3);
            
                table1.SpacingBefore = 10f;
            }
            doc1.Add(table1);
        }

        private void DemandVoucherForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Budget:    ",
                    Content = formdata.DemandVoucherItems[0].Budget
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            PdfPTable table1 = new PdfPTable(2);
            PdfPCell name = new PdfPCell(new Phrase("Item Name", labelFont));
            PdfPCell quantity = new PdfPCell(new Phrase("Quantity", labelFont));
            table1.WidthPercentage = 50;
            name.Padding = 5;
            name.PaddingTop = 3;
            name.PaddingBottom = 5;
            table1.AddCell(name);
            quantity.Padding = 5;
            quantity.PaddingTop = 3;
            quantity.PaddingBottom = 5;
            table1.AddCell(quantity);

            for (int i = 0; i < formdata.DemandVoucherItems.Count(); i++)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase(formdata.DemandVoucherItems[i].ItemName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table1.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase(formdata.DemandVoucherItems[i].Quantity.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell2);

                table1.SpacingBefore = 10f;
            }
            doc1.Add(table1);
        }

        private void LabReservationForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            if (formdata.LabReservation.IsTemporary == true)
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Date for Lab:    ",
                        Content = formdata.LabReservation.TempDateFromStr.ToString() + " - " + formdata.LabReservation.TempDateToStr.ToString()
                    },
                    RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Time:    ",
                        Content = formdata.LabReservation.TempTimeFromStr.ToString() + " - " + formdata.LabReservation.TempTimeToStr.ToString()
                    },
                });

                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Suggested Lab:    ",
                        Content = formdata.LabReservation.SuggestedLab
                    },
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "No of computer:    ",
                        Content = formdata.LabReservation.noOfComputer.ToString()
                    },
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Lab Type:    ",
                        Content = "Temporary"
                    },
                });
                CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            }
            else if (formdata.LabReservation.IsPermanent == true) {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Day:    ",
                        Content = formdata.LabReservation.Day
                    },
                    RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Time:    ",
                        Content = formdata.LabReservation.PerTimeFromStr.ToString() + " - " + formdata.LabReservation.PerTimeToStr.ToString()
                    },

                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Suggested Lab:    ",
                        Content = formdata.LabReservation.SuggestedLab
                    },
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "No of computer:    ",
                        Content = formdata.LabReservation.noOfComputer.ToString()
                    },
                });
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Lab Type:    ",
                        Content = "Permanent"
                    },
                });
                CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            }
           
        }

        private void StoreDemandForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Budget:    ",
                    Content = formdata.StoreDemandVoucher[0].Budget
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            PdfPTable table1 = new PdfPTable(2);
            PdfPCell name = new PdfPCell(new Phrase("Item Name", labelFont));
            PdfPCell quantity = new PdfPCell(new Phrase("Quantity", labelFont));
            table1.WidthPercentage = 50;
            name.Padding = 5;
            name.PaddingTop = 3;
            name.PaddingBottom = 5;
            table1.AddCell(name);
            quantity.Padding = 5;
            quantity.PaddingTop = 3;
            quantity.PaddingBottom = 5;
            table1.AddCell(quantity);

            for (int i = 0; i < formdata.StoreDemandVoucher.Count(); i++)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase(formdata.StoreDemandVoucher[i].ItemName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table1.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase(formdata.StoreDemandVoucher[i].Quantity.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell2);

                table1.SpacingBefore = 10f;
            }
            doc1.Add(table1);
        }
        private void RoomReservationForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Reservation Date:    ",
                    Content = formdata.RoomReservation.RoomResDateStr
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)

            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Time:    ",
                    Content = formdata.RoomReservation.TimeFromStr.ToString() + " - " + formdata.RoomReservation.TimeToStr.ToString()
                },
                RightContent = new PhraseHelper()
                {
                    Label = "Total Students:  ",
                    Content = formdata.RoomReservation.TotalStudents.ToString()
                }
            });
            if (formdata.RoomReservation.isMultimediaRequired == true) {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Multimedia Required:    ",
                        Content ="Yes"
                    }
                });
            }
            else
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Multimedia Required:    ",
                        Content = "No"
                    }
                });
            }
            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
        }
        private void ItemDemandRequestForPDF(Document doc1, FormData formdata, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            PdfPTable table1 = new PdfPTable(3);
            PdfPCell name = new PdfPCell(new Phrase("Item Name", labelFont));
            PdfPCell quantity = new PdfPCell(new Phrase("Quantity", labelFont));
            PdfPCell issuedQuantity = new PdfPCell(new Phrase("Issued Quantity", labelFont));

            table1.WidthPercentage = 50;
            name.Padding = 5;
            name.PaddingTop = 3;
            name.PaddingBottom = 5;
            table1.AddCell(name);
            quantity.Padding = 5;
            quantity.PaddingTop = 3;
            quantity.PaddingBottom = 5;
            table1.AddCell(quantity);
            issuedQuantity.Padding = 5;
            issuedQuantity.PaddingTop = 3;
            issuedQuantity.PaddingBottom = 5;
            table1.AddCell(issuedQuantity);


            for (int i = 0; i < formdata.ItemDemandForm.Count(); i++)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase(formdata.ItemDemandForm[i].ItemName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table1.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase(formdata.ItemDemandForm[i].Quantity.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell2);
                PdfPCell cell3 = new PdfPCell(new Phrase(formdata.ItemDemandForm[i].IssuedQty.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell3);

                table1.SpacingBefore = 10f;
            }
            doc1.Add(table1);
        }
        private void leaveApplicationForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Father Name:",
                    Content = formdata.MainData.FatherName
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = null
            });
            String leaveStr = String.Format("{0} to {1}", formdata.LeaveApplication.startDateStr, formdata.LeaveApplication.endDateStr.ToString());
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Leave Required from: ",
                    Content = leaveStr
                },
                RightContent = null
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
        }

        private void clearanceFormForPDF(Document doc1, FormData formdata, List<CustomAttachments> attach, List<ActivityLogTable> list, Font labelFont, Font contentFont)
        {
            String status = GetStatusTextByID(formdata.MainData.RequestStatus);

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Final Result Date:    ",
                    Content = formdata.MainData.TargetDateStr
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Library ID:    ",
                    Content = formdata.ClearanceFormData.LibraryID
                },
              
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);
        }

        private void optionForBscForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetFatherNamePhrase(formdata.MainData.FatherName)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "CNIC:    ",
                    Content = formdata.OptionForBsc.CNIC
                },
            });

            if (formdata.OptionForBsc.PUreg != "")
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "PU Registration No.:    ",
                        Content = formdata.OptionForBsc.PUreg
                    },
                });
            }

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Date of Birth:    ",
                    Content = HelperMethods.ConvertOnlyDateToStr(formdata.OptionForBsc.dateOfBirth)
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Note:    ",
                    Content = "I undertake to opt for an exit after completion of study of the first two years" +
                "of my BS (Hons Degree). I have no objection for eward of 2 years Bachelor degree to me."
                },
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);

        }

        private void finalTranscriptForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {


            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetFatherNamePhrase(formdata.MainData.FatherName),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Final Project Title: ",
                    Content = formdata.FinalTranscript.FYPtitle
                },
            });
            if (formdata.FinalTranscript.PUreg != "")
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "PU Registration No.:    ",
                        Content = formdata.FinalTranscript.PUreg
                    },
                });
            }

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);
        }

        private void College_IDForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Challan No.: ",
                    Content = formdata.CollegeIdCard.ChallanForm
                },
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);
        }

        private void VehicalTokenForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });
            
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Vehicle Specifications :",
                    Content = ""
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Owner Name: ",
                    Content = formdata.VehicalToken.ownerName
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Model: ",
                    Content = formdata.VehicalToken.Model
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Manufacturer: ",
                    Content = formdata.VehicalToken.manufacturer
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Registration No: ",
                    Content = formdata.VehicalToken.VehicalRegNo
                },
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);

        }

        private void bonafiedForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetFatherNamePhrase(formdata.MainData.FatherName),
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "CGPA:    ",
                    Content = formdata.BonafideCertificate.CGPA.ToString()
                },
            });


            if (formdata.BonafideCertificate.PUreg != "")
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "PU Registration No.:    ",
                        Content = formdata.BonafideCertificate.PUreg
                    },
                });
            }
            

            if (formdata.BonafideCertificate.ChallanForm != "")
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Challan No.: ",
                        Content = formdata.BonafideCertificate.ChallanForm
                    },
                });
            }
            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);

        }

        private void semesterFreezeForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper(){
                    Label = "Semester to Freeze/Withdraw:    ",
                    Content = formdata.MainData.TargetSemester.ToString()
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata)
            });
            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
        }

        private void semesterRejoinForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Semester to Rejoin:    ",
                    Content = formdata.MainData.TargetSemester.ToString()
                },
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });
            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
        }

        private void academicTranscriptForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetFatherNamePhrase(formdata.MainData.FatherName),
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Challan No.: ",
                    Content = formdata.SemesterAcadamicTranscript.ChallanNo 
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Transcript Required of Semester: ",
                    Content = formdata.MainData.TargetSemester.ToString()
                },
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);
        }

        private void coureseWithdrawForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            PdfPTable table1 = new PdfPTable(4);
            Phrase phrase = new Phrase("Courses to Withdraw:", labelFont);
            PdfPCell cell = new PdfPCell(phrase);
            cell.Colspan = 4;
            cell.HorizontalAlignment = 1;
            cell.VerticalAlignment = 1;
            cell.Padding = 5;
            cell.PaddingTop = 3;
            cell.PaddingBottom = 5;
            table1.AddCell(cell);

            PdfPCell id = new PdfPCell(new Phrase("Courses ID", labelFont));
            PdfPCell title = new PdfPCell(new Phrase("Courses Title", labelFont));
            PdfPCell hours = new PdfPCell(new Phrase("Credit Hours", labelFont));
            PdfPCell teacher = new PdfPCell(new Phrase("Teacher", labelFont));
            id.Padding = 5;
            id.PaddingTop = 3;
            id.PaddingBottom = 5;
            table1.AddCell(id);
            title.Padding = 5;
            title.PaddingTop = 3;
            title.PaddingBottom = 5;
            table1.AddCell(title);
            hours.Padding = 5;
            hours.PaddingTop = 3;
            hours.PaddingBottom = 5;
            table1.AddCell(hours);
            teacher.Padding = 5;
            teacher.PaddingTop = 3;
            teacher.PaddingBottom = 5;
            table1.AddCell(teacher);

            for (int i = 0; i < formdata.CourseWithdrawdata.Count(); i++)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase(formdata.CourseWithdrawdata[i].CourseID, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table1.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase(formdata.CourseWithdrawdata[i].CourseTitle, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell2.Padding = 5;
                cell2.PaddingTop = 3;
                cell2.PaddingBottom = 5;
                table1.AddCell(cell2);
                PdfPCell cell3 = new PdfPCell(new Phrase(formdata.CourseWithdrawdata[i].CreditHours.ToString(), new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell3.Padding = 5;
                cell3.PaddingTop = 3;
                cell3.PaddingBottom = 5;
                table1.AddCell(cell3);
                PdfPCell cell4 = new PdfPCell(new Phrase(formdata.CourseWithdrawdata[i].TeacherName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL)));
                cell4.Padding = 5;
                cell4.PaddingTop = 3;
                cell4.PaddingBottom = 5;
                table1.AddCell(cell4);
                table1.SpacingBefore = 10f;
            }
            doc1.Add(table1);


        }

        private void generalRequestForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Subject: ",
                    Content = formdata.MainData.Subject
                },
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);
            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);
        }

        private void originalDocumentForPDF(Document doc1, FormData formdata, List<ActivityLogTable> list, List<string> docs, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSemesterPhrase(formdata),
                RightContent = GetStatusPhrase(formdata.MainData.RequestStatus)
            });

            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetSectionPhrase(formdata.MainData.Section)
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Subject: ",
                    Content = formdata.MainData.Subject
                },
            });
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = GetFatherNamePhrase(formdata.MainData.FatherName)
            });

            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

            GenerateAttachmentArea(doc1, attach, labelFont, contentFont);

            Chunk doc_CL = new Chunk("I want to receive the following documents:    ", labelFont);
            Chunk doc_C = new Chunk("\n" + docs[0], contentFont);
            for (int i = 1; i < docs.Count(); i++)
            {
                doc_C.Append("\n" + docs[i]);
            }

            Phrase ph5 = new Phrase();
            ph5.Add(doc_CL);
            ph5.Add(doc_C);

            Paragraph p5 = new Paragraph();
            p5.Add(ph5);
            doc1.Add(p5);

        }

        public void AddRemarks(FormData formdata, Document doc1, List<ActivityLogTable> list)
        {
            iTextSharp.text.Font font = new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
            iTextSharp.text.Font font1 = new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10f, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);

            if (formdata.MainData.Reason != "")
            {
                List<CustomRowHelper> contentList = new List<CustomRowHelper>();
                String reason = formdata.MainData.Reason;
                if (reason.Contains("<b>"))
                {
                    reason = reason.Replace("<b>","");
                    reason = reason.Replace("</b>", "");

                }
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Reason:    ",
                        Content = reason
                    },
                });
                CreateParagraphsAndAdd(doc1, contentList, font, font1);

                //AddLineBreak(doc1, 2);
            }

            Chunk remarks_CL = new Chunk("Remarks:    ", font);
            Phrase remarks_ph = new Phrase();
            remarks_ph.Add(remarks_CL);
            Paragraph remarks_p = new Paragraph();
            remarks_p.Add(remarks_ph);
            remarks_p.SpacingAfter = 10;
            doc1.Add(remarks_p);

            PdfPTable table = new PdfPTable(1);
            table.WidthPercentage = 90;

            if (formdata.MainData.CategoryID == (int)ApplicationCategoryEnum.CLEARANCE_FORM)
            {
                PdfPCell cell1 = new PdfPCell(new Phrase("Main Library New Campus Verification:", font));
                cell1.Padding = 5;
                cell1.PaddingTop = 3;
                cell1.PaddingBottom = 5;
                table.AddCell(cell1);
                PdfPCell cell2 = new PdfPCell(new Phrase("\n   ", font1));
                cell2.Padding = 20;
                cell2.PaddingTop = 20;
                cell2.PaddingBottom = 20;
                table.AddCell(cell2);
            }
            else
            {
                doc1.Add(new Paragraph("\n"));
            }


            for (int i = list.Count() - 1; i >= 0; i--)
            {
                if (list[i].IsPrintable == true && list[i].Activity.Contains("approved") || list[i].Activity.Contains("rejected"))
                {
                    PdfPCell cell1 = new PdfPCell(new Phrase(list[i].Activity + " - " + list[i].ActivityTimeStr, font));
                    cell1.Padding = 5;
                    cell1.PaddingTop = 3;
                    cell1.PaddingBottom = 5;
                    table.AddCell(cell1);
                    PdfPCell cell2 = new PdfPCell(new Phrase(list[i].Comments, font1));
                    cell2.Padding = 5;
                    cell2.PaddingTop = 3;
                    cell2.PaddingBottom = 5;
                    table.AddCell(cell2);
                }
            }
            doc1.Add(table);
        }

        private void AddLineBreak(Document doc1, int fontSize)
        {
            doc1.Add(new Paragraph("\n", new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, fontSize)));
        }

        
        private void AddPersonalInformation(FormData formdata, Document doc1, Font labelFont, Font contentFont)
        {
            List<CustomRowHelper> contentList = new List<CustomRowHelper>();
            contentList.Add(new CustomRowHelper()
            {
                LeftContent = new PhraseHelper()
                {
                    Label = "Name:    ",
                    Content = formdata.MainData.ApplicantName
                },
                RightContent = new PhraseHelper()
                {
                    Label = "Diary No.:    ",
                    Content = "Acad/" + formdata.MainData.RequestID
                }
            });
            if (formdata.MainData.Title != "Student")
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Designation:    ",
                        Content = formdata.MainData.Title
                    },
                    RightContent = new PhraseHelper()
                    {
                        Label = "Date:    ",
                        Content = formdata.MainData.DateStr
                    }
                });
            }
            else
            {
                contentList.Add(new CustomRowHelper()
                {
                    LeftContent = new PhraseHelper()
                    {
                        Label = "Roll No.:    ",
                        Content = formdata.MainData.RollNo
                    },
                    RightContent = new PhraseHelper()
                    {
                        Label = "Date:    ",
                        Content = formdata.MainData.DateStr
                    }
                });
            }
            CreateParagraphsAndAdd(doc1, contentList, labelFont, contentFont);

        }



        private void GenerateQRCode(Document doc1, String pRequestToken)
        {
            // var barcode = PUCIT.AIMRL.Common.BarCodeManager.GenerateBarCode(formdata.MainData.RequestToken);
            //var ext = ".Png";
            //var name = Guid.NewGuid().ToString() + ext;
            //var rootPath = System.Web.HttpContext.Current.Server.MapPath("~/barcodes");
            //var fileSavePath = System.IO.Path.Combine(rootPath, name);
            //barcode.Save(fileSavePath);

            //iTextSharp.text.Image bCode = iTextSharp.text.Image.GetInstance(fileSavePath);
            //bCode.ScaleToFit(300f, 300f);
            //bCode.SetAbsolutePosition(500, 800);
            //doc1.Add(bCode);

            if (!String.IsNullOrEmpty(pRequestToken))
            {
                var qrcode = PUCIT.AIMRL.Common.QRCodeManager.GenerateQRCode(pRequestToken);
                if (qrcode != null)
                {
                    var ext = ".Png";
                    var name = Guid.NewGuid().ToString() + ext;
                    var rootPath = System.Web.HttpContext.Current.Server.MapPath("~/barcodes");
                    var fileSavePath = System.IO.Path.Combine(rootPath, name);
                    qrcode.Save(fileSavePath);


                    iTextSharp.text.Image bCode = iTextSharp.text.Image.GetInstance(fileSavePath);
                    bCode.ScaleToFit(55f, 55f);
                    bCode.SetAbsolutePosition(510, 10);
                    doc1.Add(bCode);
                }
            }
        }

        private void GeneateFileHeader(Document doc1)
        {
            Paragraph heading = new Paragraph("Punjab University College of Information Technology", new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 18f, iTextSharp.text.Font.BOLD, BaseColor.BLACK));
            heading.SpacingBefore = 8;
            heading.Alignment = Element.ALIGN_CENTER;
            doc1.Add(heading);
            doc1.Add(new Paragraph("\n", new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 10)));
            var imagePhysicalPath = System.Web.HttpContext.Current.Server.MapPath("~/images");
            string imageURL = imagePhysicalPath + "\\pucit\\" + "PUCIT_Logo_new.png";
            iTextSharp.text.Image img = iTextSharp.text.Image.GetInstance(imageURL);

            //Resize image
            img.ScaleToFit(50f, 50f);
            img.SetAbsolutePosition(25, 750);
            doc1.Add(img);
        }

        private void GenerateFormHeader(Document doc1, String formName)
        {
            Paragraph AppName = new Paragraph(formName, new iTextSharp.text.Font(iTextSharp.text.Font.FontFamily.TIMES_ROMAN, 20f, iTextSharp.text.Font.BOLD, BaseColor.BLACK));
            AppName.Alignment = Element.ALIGN_CENTER;
            doc1.Add(AppName);
            doc1.Add(new Paragraph("\n"));
        }

        private PhraseHelper GetStatusPhrase(int pStatusID)
        {
            String status = GetStatusTextByID(pStatusID);
            return new PhraseHelper()
                {
                    Label = "Status:    ",
                    Content = status
                };
        }
        private PhraseHelper GetSemesterPhrase(FormData formData)
        {
            String label = "Semester:    ";
            if (formData.MainData.CategoryID == (int)ApplicationCategoryEnum.LEAVE_APPLICATION_FORM
                || formData.MainData.CategoryID == (int)ApplicationCategoryEnum.OPTION_FOR_BSc_DEGREE
                || formData.MainData.CategoryID == (int)ApplicationCategoryEnum.SEMESTER_FREEZE_WITHDRAWAL_FORM)
            {
                label = "Current Semester:    ";
            }

            return new PhraseHelper()
            {
                Label = label,
                Content = formData.MainData.CurrentSemester.ToString()
            };
        }
        private PhraseHelper GetSectionPhrase(String content)
        {
            return new PhraseHelper()
            {
                Label = "Section: ",
                Content = content
            };
        }
        private PhraseHelper GetFatherNamePhrase(String content)
        {
            return new PhraseHelper()
            {
                Label = "Father Name:    ",
                Content = content
            };
        }
        private String GetStatusTextByID(int pStatusID)
        {

            if (pStatusID == 2)
            {
                return "Pending";
            }
            else if (pStatusID == 3)
            {
                return "Accepted";
            }
            else if (pStatusID == 4)
            {
                return "Rejected";
            }
            else
                return "";

        }

        private void GenerateAttachmentArea(Document doc1, List<CustomAttachments> attach, Font labelFont, Font contentFont)
        {

            if (attach != null && attach.Count > 0)
            {
                Chunk attach_CL = new Chunk("Attachments:  ", labelFont);
                Chunk attach_C = new Chunk(attach[0].type.typeName, contentFont);

                for (int i = 1; i < attach.Count(); i++)
                {
                    attach_C.Append(", " + attach[i].type.typeName);
                }

                Phrase attach_ph = new Phrase();
                attach_ph.Add(attach_CL);
                attach_ph.Add(attach_C);

                Paragraph attach_p = new Paragraph();
                attach_p.Add(attach_ph);
                doc1.Add(attach_p);

            }
        }
        #endregion

        /* To get Mime Type using Extension
        * https://stackoverflow.com/questions/1029740/get-mime-type-from-filename-extension
        * https://github.com/samuelneff/MimeTypeMap
       */


        private HttpResponseMessage DownloadPdfFile(String fileNameWithExt, String rootPhysicalPath, String fileDownloadableName)
        {
            try
            {
                var appPhysicalPath = System.Web.HttpContext.Current.Server.MapPath("~/TempFiles");
                HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.OK);
                var fileFullPath = System.IO.Path.Combine(appPhysicalPath, fileNameWithExt);

                byte[] file = System.IO.File.ReadAllBytes(fileFullPath);
                System.IO.MemoryStream ms = new System.IO.MemoryStream(file);

                response.Content = new ByteArrayContent(file);
                response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment");
                //String mimeType = MimeType.GetMimeType(file); //You may do your hard coding here based on file extension

                response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
                response.Content.Headers.ContentDisposition.FileName = fileDownloadableName;
                return response;
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.NotFound);
                return response;
            }
        }

        private void CreateParagraphsAndAdd(Document doc, List<CustomRowHelper> rows, Font pLabelFont, Font pContentFont)
        {
            Phrase phraseForContent = null;
            Paragraph p2 = null;
            foreach (var item in rows)
            {
                phraseForContent = new Phrase();
                if (item.LeftContent != null)
                {
                    phraseForContent.Add(new Chunk(item.LeftContent.Label, pLabelFont));
                    phraseForContent.Add(new Chunk(item.LeftContent.Content, pContentFont));
                }
                if (item.RightContent != null)
                {
                    phraseForContent.Add(new Chunk(new VerticalPositionMark()));
                    phraseForContent.Add(new Chunk(item.RightContent.Label, pLabelFont));
                    phraseForContent.Add(new Chunk(item.RightContent.Content, pContentFont));
                }

                p2 = new Paragraph();
                p2.SpacingAfter = 2;
                p2.Add(phraseForContent);
                doc.Add(p2);
            }
        }
    }
    public partial class Footer : PdfPageEventHelper
    {
        public override void OnEndPage(PdfWriter writer, Document doc)
        {
            Paragraph footer = new Paragraph(HelperMethods.ChangeDTFormat(DateTime.Now) + "  " + PUCIT.AIMRL.PRM.UI.Common.Resources.GetCompletePath("~"), FontFactory.GetFont(FontFactory.TIMES, 8, iTextSharp.text.Font.NORMAL));
            PdfPTable footerTbl = new PdfPTable(1);
            footerTbl.TotalWidth = 300;
            PdfPCell cell = new PdfPCell(footer);
            cell.Border = 0;
            footerTbl.AddCell(cell);
            footerTbl.WriteSelectedRows(0, -1, 15, 30, writer.DirectContent);
        }
    }

    internal class PhraseHelper
    {
        public String Label { get; set; }
        public String Content { get; set; }
    }
    internal class CustomRowHelper
    {
        public PhraseHelper LeftContent { get; set; }
        public PhraseHelper RightContent { get; set; }
    }
}