MyWebApp.namespace("UI.ForgotPasswordLog");

MyWebApp.UI.ForgotPasswordLog = (function () {
    "use strict";
    var _isInitialized = false;
    var LoginList;
    var current_page = 0;
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
        
            SearchForgotPasswordLog();
        }
    }
    function BindEvents() {
        $("#cmbPageSizeSearch").change(function (e) {
            e.preventDefault();
            SearchForgotPasswordLog();
            return false;
        });
        $("#search").unbind("click").bind("click", function (e) {
            //debugger
            e.preventDefault();
            current_page = 0;
            SearchForgotPasswordLog();
            return false;
        });
    }
    function SearchForgotPasswordLog() {
        if (current_page == 0)
            current_page = 1;

        var searchObject = {
            Login: $("#login").val().trim(),
            SDate: $("#sdate").val(),
            EDate: $("#edate").val(),
            PageSize: $("#cmbPageSizeSearch").val(),
            PageIndex: current_page - 1
        };

        var url = "Reports/SearchForgotPasswordLog";
        var Data = JSON.stringify(searchObject);

        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            if (result.success === true) {
                LoginList = result.data;
                $("#spResultsFound").text("(" + result.data.Count + " Records are found)");
                CreatePages(result.data.Count);
                console.log(result.data);
                displayAllLoginHistory(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            console.log(thrownError);
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting records: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function CreatePages(recordCount) {
        var pageSize = Number($("#cmbPageSizeSearch").val());

        if (isNaN(pageSize) || pageSize <= 0) {
            alert('Invalid Page Size');
            return;
        }
        var pages = Math.ceil(recordCount / pageSize);
        CreateNavButtonForPage(pages);
    }
    function CreateNavButtonForPage(pageNo) {
        $(".pagination").empty();
        for (var i = 1; i <= pageNo; i++) {
            var li = $("<li>").attr("id", "pageNo").attr("pageNo1", i).attr("value", i).attr("style", "color:white");
            if (i == current_page)
                li.addClass("active");
            var i1 = $("<a>").text(i);
            li.append(i1);
            $(".pagination").append(li);
        }

        $(".pagination #pageNo").unbind("click").bind("click", function (e) {
            var pgNo = $(this).closest("li").attr("pageNo1");
            if (current_page != pgNo) {
                current_page = pgNo;
                SearchForgotPasswordLog();
            }

            return false;
        });
    }
    

    function displayAllLoginHistory(LoginHistoryList) {

        $("#simple-table6").html("");

        if (!LoginHistoryList)
            return;

        try {
            var source = $("#ForgotPasswordLogTemplate").html();
            var template = Handlebars.compile(source);
            var html = template(LoginHistoryList);
        } catch (e) {
            debugger;
        }

        $("#simple-table6").append(html);
    }

    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
());