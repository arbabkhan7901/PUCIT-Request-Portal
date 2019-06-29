/// <reference path="../../_references.js" />

/*** 
* Used for defining the MyWebApp UI Main
* @module Main
* @namespace MyWebApp.UI
*/

MyWebApp.namespace("UI.Main");

MyWebApp.UI.Main = (function () {
    "use strict";

    function initialisePage() {

        $('#imgUserImage').unbind("click").bind("click", function () {
            $("#overlay").fadeToggle();
        });

        $('#lnkSignOut').live("click", function () {

            SignOut();
        });//end of lnkSignOut
        
    } // End of initialiseControls


    function SignOut() {

        var url = "SignOutData/GetUserSignOut";

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                window.location.href = MyWebApp.Resources.Views.LoginURL;
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('There was a problem in signing out "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }//End of SignOut

    function SetToolTip(block) {
        block.tooltip({
            track: true,
            delay: 0,
            showURL: false,
            showBody: " - "
            //fade: 250
        });
    }//end of SetToolTip

    return {
        readyMain: function () {
            initialisePage();
        }
    };

} ());

