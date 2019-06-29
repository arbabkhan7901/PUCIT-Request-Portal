using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using PUCIT.AIMRL.PRM.MainApp.Models;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using PUCIT.AIMRL.PRM.Entities;
using System.Drawing.Imaging;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    public class ApplicationViewController : BaseDataController
    {
        private readonly ApplicationViewRepository _repository;
        public ApplicationViewController()
        {
            _repository = new ApplicationViewRepository();
        }

        private ApplicationViewRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        [HttpGet]
        public Object GetAttachment(int requestId, String reqUniqueId)
        {
            return Repository.GetAttachment(requestId, reqUniqueId);
        }
        [HttpGet]
        public Object GetFormData(int requestId, String requestUniqueId)
        {
            return Repository.GetFormData(requestId, requestUniqueId);
        }

        public Object GetFormApprovers(int pApplicationId,String reqUniqueId)
        {
            return Repository.GetFormApprovers(pApplicationId, reqUniqueId);
        }

        [HttpPost]
        public Object ApproveRequest(ReqWorkflow ApproveRequestData)
        {
            return Repository.ApproveRequest(ApproveRequestData);
        }

        [HttpPost]
        public Object RejectRequest(ReqWorkflow ApproveRequestData)
        {
            return Repository.RejectRequest(ApproveRequestData);
        }



        [HttpPost]
        public Object insertNewFlow(ChangeContributors Cobject)
        {
            return Repository.insertNewFlow(Cobject);
        }

        [HttpGet]
        public Object SearchContributor(string key)
        {

            return Repository.SearchContributor(key);
        }

        [HttpGet]
        public Object GetLogList(int requestId,String reqUniqueId)
        {
            return Repository.GetLogList(requestId, reqUniqueId);
        }

        [HttpPost]
        public Object SaveRemarks(ActivityLogTable dataToSend)
        {
            return Repository.SaveRemarks(dataToSend);
        }

        [HttpPost]
        public Object SaveReview(ActivityLogTable dataToSend)
        {
            return Repository.SaveReview(dataToSend);
        }

        [HttpPost]
        public Object HandleRecieving(ActivityLogTable dataToSend)
        {
            return Repository.HandleRecieving(dataToSend);
        }

        public Object searchApplications(SearchEntity Data)
        {
            return Repository.searchApplications(Data);
        }

        public Object SaveActivityLogConverstation(ActivityLogConversation data)
        {
            return Repository.SaveActivityLogConverstation(data);
        }
        public Object GetActivityLogConverstations(int requestId, long activityLogId,String ReqUniqueId)
        {
            return Repository.GetActivityLogConverstations(requestId, activityLogId, ReqUniqueId);
        }

        public Object EnableDisableRequestEdit(EnableDisableData obj)
        {
            return Repository.EnableDisableRequestEdit(obj.RequestId,obj.ReqUniqueId, obj.CanStudentEdit, obj.Remarks);
        }

        [HttpPost]
        public Object RouteBack(ReqWorkflow data)
        {
            return Repository.RouteBack(data);
        }


        [HttpPost]
        public Object UpdateActivityLogActionItem(ActLogActionPanelData data)
        {
            return Repository.UpdateActivityLogActionItem(data.RequestId, data.ReqUniqueId, data.ActLogId, data.type, data.value);
        }

        [HttpPost]
        public Object UpdateCGPA(CGPAData data)
        {
            return Repository.UpdateCGPA(data.RequestId,data.ReqUniqueId, data.CGPA);
        }
        [HttpPost]
        public Object RemoveContributor(RemContributorObj data)
        {
            return Repository.RemoveContributor(data.RequestId,data.ReqUniqueId, data.WFID, data.ApproverIDToRemove);
        }
        [HttpPost]
        public Object AddContributor(RemContributorObj data)
        {
            return Repository.AddContributor(data.RequestId,data.ReqUniqueId, data.ApproverIDToAdd); //Here ApproverID is to Add
        }
        [HttpPost]
        public Object UpdateContributorsOrder(UpdateContrShort data)
        {
            return Repository.UpdateContributorsOrder(data.RequestId,data.ReqUniqueId, data.ReqWorkFlowList); //Here ApproverID is to Add
        }

        [HttpPost]
        public ResponseResult SwapContributor(SwapContributorData data)
        {
            return Repository.SwapContributor(data.RequestId,data.ReqUniqueId, data.ToApproverID, data.Remarks);
        }

        [HttpGet]
        public Object DownloadRequestPdf(int requestId, String reqUniqueId)
        {
            return Repository.GenerateReqeuestPDF(requestId, reqUniqueId);
        }
        [HttpPost]
        public Object UpdateItems(CustomUpdateItems reqData)
        {
            return Repository.UpdateItems(reqData);
        }

        [HttpPost]
        public void UpdateIssuedQty(CustomUpdateIssuedQty reqData)
        {
            Repository.UpdateIssuedQty(reqData);
        }

    }

    

    public class SwapContributorData
    {
        public int RequestId { get; set; }
        public int ToApproverID { get; set; }
        public String Remarks { get; set; }
        public String ReqUniqueId { get; set; }
    }

    public class ActLogActionPanelData
    {
        public int RequestId {get;set;}
        public String ReqUniqueId { get; set; }
        public int ActLogId { get; set; }
        public int type { get; set; }
        public int value { get; set; }
    }

    public class EnableDisableData
    {
        public int RequestId { get; set; }
        public Boolean CanStudentEdit { get; set; }
        public String ReqUniqueId { get; set; }
        public String Remarks { get; set; }
    }

    public class CGPAData
    {
        public int RequestId { get; set; }
        public String ReqUniqueId { get; set; }
        public double CGPA { get; set; }
    }

    public class RemContributorObj
    {
        public int RequestId { get; set; }
        public String ReqUniqueId { get; set; }
        public int WFID { get; set; }
        public int ApproverIDToRemove { get; set; }
        public int ApproverIDToAdd { get; set; }
    }
    public class UpdateContrShort
    {
        public int RequestId { get; set; }
        public String ReqUniqueId { get; set; }
        public List<ReqWorkFlowShort> ReqWorkFlowList { get; set; }
    }
}