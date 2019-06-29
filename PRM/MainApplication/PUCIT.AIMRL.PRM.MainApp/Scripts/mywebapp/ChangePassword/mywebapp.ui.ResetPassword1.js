MyWebApp.namespace("UI.ResetPassword1");

MyWebApp.UI.ResetPassword1 = (function () {
    "use strict";
    var _isInitialized = false;

    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
        }
    }

    function BindEvents() {

        $(document).ready(function () {
            $('#SaveButton').click(function (e) {
                e.preventDefault();
                changePassword();
                return false;
            });//end of click
        });//end of ready

    }//End of Bind Events


    function changePassword() {

        if ($('#form-field-pass2').val() != $('#form-field-pass3').val()) {
            //alert("The two password fields doesn't match ");
            MyWebApp.UI.showRoasterMessage("New Password & Confirm Password are not same.", Enums.MessageType.Error);
        }
        else {
            var data = {
                NewPassword: $('#form-field-pass2').val(),
                Token: $("#txtData").val()
            }
            var dataToSend = JSON.stringify(data);
            var url = "UserInfoData/resetPassword";
            
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success == true) {
                    MyWebApp.UI.ShowLastMsgAndRedirect("Password is Reset Succesfully", MyWebApp.Resources.Views.LoginURL);
                } else {
                    MyWebApp.UI.showRoasterMessage("It seems token is not valid, Try with new token", Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage("Some problem has occurred", Enums.MessageType.Error);
            });
        }
    }
    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
    ());