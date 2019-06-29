using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
﻿
namespace PUCIT.AIMRL.PRM.MainApp.APIControllers.Signout
{
    public class FormsController : BaseDataController
    {
        //
        // GET: /Forms/
        private readonly FormDataRepository _repository;

        public FormsController()
        {
            _repository = new FormDataRepository();
        }
        private FormDataRepository Repository
        {
            get
            {
                return _repository;
            }
        }
		
        [HttpPost]
        public Object SaveClearanceForm()
        {
            return Repository.SaveClearanceForm();
        }

        [HttpGet]
        public Object getInstructions()
        {
            return Repository.getInstructions();
        }

        [HttpPost]
        public Object SaveLeaveForm(CustomLeaveApplication leaveData)
        {
            return Repository.SaveLeaveForm(leaveData);
        }

        [HttpPost]
        public Object SaveBScForm()
        {
            return Repository.SaveBScForm();
        }
		
        [HttpPost]
        public Object UploadSignature()
        {
            return Repository.UploadSignature();
        }

        [HttpPost]
        public Object SaveFinalAcadTrans()
        {
            return Repository.SaveFinalAcadTrans();
        }

        [HttpPost]
        public Object SaveIdCardForm()
        {
            return Repository.SaveIdCardForm();
        }

        [HttpPost]
        public Object SaveVehicalTokenForm()
        {
            return Repository.SaveVehicalTokenForm();
        }

        [HttpPost]
        public Object receiptOfOriginal()
        {
             return Repository.receiptOfOriginal();
        }

        [HttpPost]
        public Object SaveBonafideForm()
        {
            return Repository.SaveBonafideForm();
        }

        [HttpPost]
        public Object SaveSemesterFreezeForm(RequestMainData request)
        {
            return Repository.SaveSemesterFreezeForm(request);
        }

        [HttpPost]
        public Object SaveSemesterRejoinForm(RequestMainData rejoinData)
        {
            return Repository.SaveSemesterRejoinForm(rejoinData);
        }
		
        [HttpPost]
        public Object SaveSemesterAcadTranscriptForm()
        {
            return Repository.SaveSemesterAcadTranscriptForm();
        }

        [HttpPost]
        public Object SaveWithDraw(customCourseWithdraw course_withdraw)
        {
            return Repository.SaveWithDraw(course_withdraw);
        }

        [HttpPost]
        public Object SaveGeneralRequest()
        {
            return Repository.SaveGeneralRequest();
        }

        [HttpPost]
        public Object SaveLabReservationForm(CustomLabReservationForm labReservation) {
            return Repository.SaveLabReservationForm(labReservation);
        }

        [HttpPost]
        public Object UploadAttachment()
        {
            return Repository.UploadAttachment();
        }

        [HttpPost]
        public Object RemoveAttachment()
        {
            return Repository.RemoveAttachment();
        }

        [HttpPost]
        public Object UpdateAttachment()
        {
            return Repository.UpdateAttachment();
        }

        [HttpGet]
        public Object FillDropDown()
        {
            return Repository.FillDropDown();
        }

        [HttpPost]
        public Object SaveDemandForm(CustomDemandForm reqData)
        {
            return Repository.SaveDemandForm(reqData);

        }

        [HttpPost]
        public Object SaveDemandVoucher(CustomDemandVoucher reqData)
        {
            return Repository.SaveDemandVoucher(reqData);
            
        }

        [HttpPost]
        public Object SaveStoreDemandVoucher(CustomStoreDemandVoucher reqData)
        {
            return Repository.SaveStoreDemandVoucher(reqData);
        }

        [HttpPost]
        public Object SaveHardwareForm(CustomHardwareForm reqData)
        {
            return Repository.SaveHardwareForm(reqData);
        }

        [HttpGet]
        public Object getItemsName()
        {
            return Repository.getItemsName();
        }

        [HttpGet]
        public Object getHardwareItemsName()
        {
            return Repository.getHardwareItemsName();
        }
        [HttpPost]
        public Object SaveRoomReservationForm(CustomRoomReservation roomRes)
        {
            return Repository.SaveRoomReservationForm(roomRes);
        }
        [HttpGet]
        public Object SearchContributor(string key)
        {
            return Repository.SearchContributor(key);
        }
    }
}
