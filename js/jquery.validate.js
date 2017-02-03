jQuery(function($) {
    /* validator */
    jQuery.each($(".form-wrapper.validate form"), function(){
        $(this).validate();
    });
    
    /* ajax send with validation */
    jQuery.each($(".form-wrapper.ajax form, .form-wrapper.textmode form"), function(){
        $(this).validate({
            submitHandler: function(form) {
                $(form).ajaxSubmit({
                    dataType: "json",
                    beforeSubmit: function(){
                        $(form).find("input[type=submit]").attr("disabled", true);
                        $(form).find(".form-response").removeClass("error confirm empty").addClass('empty').html(translate_wait);
                    },
                    success: function(j){
                        $(form).find(".form-response").removeClass("error confirm empty").addClass(j.status).html("").show('fast');
                        $(form).find("input[type=submit]").attr("disabled", false);
    
                        if (j.message){
                            $(form).find(".form-response").html(j.message);
                        } else {
                            $.each(j.messages, function(message){
                                $(form).find(".form-response").append("<div>" + this.message + "</div>");
                            });
                        }
                        if (!j.instant) {
                            var errfield = $(form).find(".form-response");
                            $(errfield).oneTime(1500, function(){$(errfield).hide("fast");});
                        }
    
                        if ($(form).hasClass("reload") && j.status == 'confirm') {
                            location.reload();
                        }
                    }
                });
            }
        });
    });
});