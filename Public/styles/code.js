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
                                      $("body").css("overflow", "scroll");
                                      });
                  
                  $('#orangeHelpButton').click(function(){
                                               $("#orangeHelp").slideDown("slow");
                                               $("body").css("overflow", "hidden");
                                               });
                  
                  $('#orangeHelp .helpDismiss').click(function(){
                                                      $("#orangeHelp").slideUp("slow");
                                                      $("body").css("overflow", "scroll");
                                                      });
});

