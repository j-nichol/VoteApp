$(document).ready(function(){
  $('copyVerificationCode').click(function(){
    $('verificationCode').select();
    document.execCommand("copy");
    toastr.options = {
    "closeButton": true,"debug": false, "newestOnTop": false,"progressBar": true,"positionClass": "toast-top-full-width","preventDuplicates": true,"onclick": null,"showDuration": "300","hideDuration": "1000","timeOut": "5000","extendedTimeOut": "1000","showEasing": "swing","hideEasing": "linear","showMethod": "slideDown","hideMethod": "slideUp"}
    Command: toastr["success"]("has been copied to your clipboard.", "Verification Code")
  };
};
