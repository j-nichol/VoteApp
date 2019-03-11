$(document).ready(function(){
                  $('#copyVerificationCode').click(function(){
                                                   $('#verificationCode').select();
                                                   document.execCommand("copy");
                                                   toastr.options = {"closeButton": true,"preventDuplicates": true};
                                                   toastr.success("has been copied to your clipboard.", "Verification Code");
                                                   });
                  $('#emailVerificationCode').click(function(){
                                                   //send email
                                                   toastr.options = {"closeButton": true,"preventDuplicates": true};
                                                   toastr.success("has been sent to your Email Inbox.", "Verification Code");
                                                   });
                  $('.backButton').click(function(){
                                         window.history.back();
                                         });
                  
                  $('#orangeHelp').on('swipedown',function (e,data){
                                      $("#orangeHelp").slideUp("slow");
                                      stopBodyScrolling(false);
                                      });
                  
                  $('#orangeHelpButton').click(function(){
                                               $("#orangeHelp").slideDown("slow");
                                               stopBodyScrolling(true);
                                               });
                  
                  $('#orangeHelp .helpDismiss').click(function(){
                                                      $("#orangeHelp").slideUp("slow");
                                                      stopBodyScrolling(false);
                                                      });
                  
                  function stopBodyScrolling (bool) {
                    if (bool === true) {
                        document.body.addEventListener("touchmove", function(e) { e.preventDefault(); }, false);
                      } else {
                  document.body.removeEventListener("touchmove", function(e) { e.preventDefault(); }, false);
                    }
                  }
});

