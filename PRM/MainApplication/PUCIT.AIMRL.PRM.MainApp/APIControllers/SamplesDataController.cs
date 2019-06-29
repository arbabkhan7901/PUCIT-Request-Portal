using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Script.Services;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{

    public class StudentObj
    {
        public Int32 StudentID { get; set; }
    }

    public class SamplesDataController : BaseDataController
    {
        private readonly SamplesRepository _repository;
        public SamplesDataController()
        {
            _repository = new SamplesRepository();
        }

        private SamplesRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        
        [HttpGet]
        public Object SearchSampleStudents(Int32? pStudentId, string pFirstName, string pLastName, DateTime? pDateOfBirth)
        {
            return Repository.SearchSampleStudents(pStudentId, pFirstName, pLastName, pDateOfBirth);
        }

        [HttpPost]
        public Object SaveSampleStudent(SampleStudent pStudent)
        {
            return Repository.SaveSampleStudent(pStudent);
        }

        [HttpPost]
        public Object DeactivateSampleStudent(StudentObj pStudentID)
        {
            return Repository.DeactivateSampleStudent(pStudentID.StudentID);
        }

        [HttpGet]
        public Object SearchSampleStudentsForAuto(String prefixText)
        {
            return Repository.SearchSampleStudentsForAuto(prefixText);
        }


    }
}
