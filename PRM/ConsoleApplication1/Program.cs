using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace ConsoleApplication1
{
    class Program
    {
        public static Boolean IsCompleted = true;

        static void Main(string[] args)
        {
            Timer timer = new Timer();
            timer.Elapsed += timer_Elapsed;
            timer.Interval = 10000;
            timer.Enabled = true;
            timer_Elapsed(null, null);

            System.Console.ReadKey();
        }
        private static void timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            if (IsCompleted) {
                IsCompleted = false;
                PUCIT.PRM.TaskManagement.ScheduleHandler.LoadAndProcess();
                IsCompleted = true;
            }
        }
    }
}
