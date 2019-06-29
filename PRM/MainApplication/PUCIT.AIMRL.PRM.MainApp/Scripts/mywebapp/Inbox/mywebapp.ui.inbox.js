MyWebApp.namespace("UI.Inbox");

MyWebApp.UI.Inbox = (function () {
    "use strict";
    var _isInitialized = false;
    var ApplicationType;
    var IsStudent;

    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;           
            ApplicationType = $("#ApplicationsType").text();
            if (ApplicationType > 0) {
                $("#item_select1").val(ApplicationType);
            }
            FillDropDown();
            BindEvents();
            $("#search").trigger("click");
            IsStudent = $("#IsStudent").text();
            if (IsStudent == "False") {
                $("#rollNumberDiv").show();
                $("#nameDiv").show();
            }
        }
    }

    //Bind events
    function BindEvents() {

        $("#search").click(function (e) {

            e.preventDefault();

            var searchObject = {
                RollNO: $("#rollNumber").val(),
                Name: $("#name").val(),
                SDate: $("#sdate").val(),
                EDate: $("#edate").val(),
                Type: $("#item2_select").val(),
                Status: $("#item_select1").val(),
            };

            var url = "Inbox/searchApplications";
            var Data = JSON.stringify(searchObject);

            MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
                if (result.success === true) {
                    var len = result.data.ApplicationList.length;
                    if (len == 1)
                        $("#spResultsFound").text("(1 Application is found)");
                    else
                        $("#spResultsFound").text("(" + result.data.ApplicationList.length + " Applications are found)");

                    displayApplications(result.data);
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxOptions, thrownError) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred while getting applications: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
            });

            return false;
        });

    }//End of Bind Events
    function FillDropDown() {
        debugger;
        var url = "Inbox/FillDropDown";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                debugger;
                var forms = document.getElementById("item2_select");
                for (var i = 0; i < result.data.length; i++) {
                    var option = document.createElement("OPTION");
                    option.innerHTML = result.data[i].Category;
                    option.value = result.data[i].CategoryID;
                    option.setAttribute("id", result.data[i].CategoryID);
                    forms.options.add(option);
                }
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    //function for displaying applications
    function displayApplications(Applications) {

        $("#applications").html("");

        if (!Applications)
            return;

        try {
            var source = $("#inboxtemplate").html();
            var template = Handlebars.compile(source);
            var html = template(Applications);
            $("#applications").append(html);
        } catch (e) {
        }
    }

    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
    ());