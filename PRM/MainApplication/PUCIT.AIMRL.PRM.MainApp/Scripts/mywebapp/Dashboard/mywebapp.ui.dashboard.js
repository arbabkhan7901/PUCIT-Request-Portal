MyWebApp.namespace("UI.Dashboard");

MyWebApp.UI.Dashboard = (function () {
    "use strict";
    var _isInitialized = false;
    var current_page = 0;
    var flag = false;
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;

            var txt = $("#spMessage").text();
            if (txt.length > 0)
                MyWebApp.UI.showRoasterMessage(txt, Enums.MessageType.Error);
            BindEvents();
            getApplicationCount();
            getLatestPending();
            getLogList();
        }
    }

    function BindEvents() {
        $("#show").bind("click", function (e) {
            e.preventDefault();
            getLogList();
        });
    }

    function getApplicationCount() {

        var url = "Dashboard/getCount";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                debugger;
                createJson(result.data);
                displayApplicationCount(result.data);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function displayApplicationCount(data) {

        $("#AllCount").text(data.countList[0]);
        $("#PendingCount").text(data.countList[1]);
        $("#AcceptedCount").text(data.countList[2]);
        $("#RejectedCount").text(data.countList[3]);
        $("#NotAssignedYetCount").text(data.countList[4]);
        //$("#RejectedBeforeAssignment").text(data.countList[5]);
    }

    function getLatestPending() {

        var url = "Dashboard/getLatestPending";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                console.log(result);
                //debugger;
                displayLatestPending(result.data);

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }

    function displayLatestPending(data) {
        //debugger;

        $("#latestPendingTable").html("");

        if (!data)
            return;

        try {
            var source = $("#latestPending").html();
            var template = Handlebars.compile(source);
            var html = template(data);
        } catch (e) {
            //debugger;
        }


        $("#latestPendingTable").append(html);
    }

    function createJson(data) {
        var arr = [];
        for (var i = 0; i < data.countList.length; i++) {
            if (data.namesList[i] == "All") continue;

            //var series = new Array(data.namesList[i], data.countList[i]);
            arr.push({ name: data.namesList[i], y: data.countList[i] });
        }


      //  drawChart(arr);
    }
    function getLogList() {
        var searchObject = {
            PageSize: 10,
            PageIndex: current_page
        };
        var Data = JSON.stringify(searchObject);
        var url = "Reports/GetActivityLogList";
        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            if (result.success === true) {
                displayLogData(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);

        });
    }
    //for Display Activity Logs
    function displayLogData(data) {
        if (data.LogList.length == 0) {
            $("#show").remove();
            return;
        }
         if (!data) 
             return;
         try {
             var source = $("#LogListDisplayTemplate").html();
             var template = Handlebars.compile(source);
             var html = template(data);
             current_page++;
         } catch (e) {
             debugger;
         }

         $("#timeline").append(html);
     }

    //function drawChart(arr) {
    //    $('#chartContainer').highcharts({

    //        chart: {
    //            plotBackgroundColor: null,
    //            plotBorderWidth: 0, //null,
    //            plotShadow: false,
    //            type: 'pie'
    //        },
    //        title: {
    //            text: 'Applications Chart'
    //        },
    //        tooltip: {
    //            pointFormat: '<b>{point.percentage:.1f}%</b>'
    //        },
    //        plotOptions: {
    //            pie: {
    //                allowPointSelect: true,
    //                cursor: 'pointer',
    //                dataLabels: {
    //                    enabled: true,
    //                    format: '<b>{point.percentage:.1f}</b>%',
    //                    style: {
    //                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
    //                    }
    //                },
    //                showInLegend: true
    //            }
    //        },
    //        series: [{
    //            type: 'pie',
    //            name: 'Applications',
    //            data: arr
    //        }]
    //    });
    //}
    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
    ());