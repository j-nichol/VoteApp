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
                  
                  var yellowHammer = new Hammer($('#yellowHelp'));
                  var userpassHammer = new Hammer($('#userpassHelp'));
                  var loginHammer = new Hammer($('#loginHelp'));
                  var securelyHammer = new Hammer($('#securelyHelp'));
                  var verificationCodeHammer = new Hammer($('#verificationCodeHelp'));
                  var spoilBallotHammer = new Hammer($('#spoilBallotHelp'));
                  var checkVerificationCodeHammer = new Hammer($('#checkVerificationCodeHelp'));
                  
                  yellowHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  userpassHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  loginHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  securelyHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  verificationCodeHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  spoilBallotHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  checkVerificationCodeHammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
                  
                  yellowHammer.on('swipedown', function(ev) {
                                  console.log(ev);
                                  });
                  userpassHammer.on('swipedown', function(ev) {
                                    console.log(ev);
                                    });
                  loginHammer.on('swipedown', function(ev) {
                                 console.log(ev);
                                 });
                  securelyHammer.on('swipedown', function(ev) {
                                    console.log(ev);
                                    });
                  verificationCodeHammer.on('swipedown', function(ev) {
                                            console.log(ev);
                                            });
                  spoilBallotHammer.on('swipedown', function(ev) {
                                       console.log(ev);
                                       });
                  checkVerificationCodeHammer.on('swipedown', function(ev) {
                                                 console.log(ev);
                                                 });
});

