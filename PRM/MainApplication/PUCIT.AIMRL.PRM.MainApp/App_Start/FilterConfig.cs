using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}