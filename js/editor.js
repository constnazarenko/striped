jQuery(function($) {
    var wait = $(document.createElement("div")).addClass("wait").text(translate_wait),
    xButton = $(document.createElement("div")).addClass("overclose").append($(document.createElement("span")).text("close")).click(function(){$.fn.destroyOverlay();}),
    overlay = $(document.createElement("div")).addClass("overlay").click(function(){$.fn.destroyOverlay();}),
    iframe = $(document.createElement("iframe")).addClass("overframe"),
    $reloadAfter = false,
    $frameChanged = false; 

    $.fn.generateOverlay = function(href, id){
        if (id) {
            href += 'edit/'+id;
        }
        $("body").keyup(function(event) {if (event.which==27) $.fn.destroyOverlay();}).append(overlay.clone(true));
        $(".overlay").after(iframe.clone(true).load(function(){$(this).contents().find('body').keyup(function(event) { if (event.which==27) $.fn.destroyOverlay();});}).attr('src', href)).after(xButton.clone(true));
    };

    $.fn.destroyOverlay = function(){
        if (!$frameChanged || confirm(translate_are_you_sure_want+' '+translate_close_unsaved)) {
            $(".overlay, .overframe, .overclose").remove();
            $.fn.setFrameChanged(false);
            if ($reloadAfter) {
                location.reload();
            }
        }
    };
    
    $.fn.setReloadAfter = function(value){
        $reloadAfter = value;
    };
    $.fn.setFrameChanged = function(value){
        $frameChanged = value;
    };

    $.each($('.link-add, .link-add-blue, .link-custom, .link-edit, .link-delete, .edit-button, .link-down, .link-up'),function(){
        $(this).attr('title', $(this).find('span').text());
    });

    //
    if($.cookies.get('admin_switch') == 'on' || $('.showeditlinks a').length == 0) {
        $('.edit-links, .edit-button, .hide-for-edit').show();
        $('.showeditlinks a').attr('style', 'color: red');
    } else {
        $('.edit-links, .edit-button, .hide-for-edit').hide();
        $('.showeditlinks a').removeAttr('style');
    }
    $('.showeditlinks a').click(function(){
        if($.cookies.get('admin_switch') == 'on') {
            $('.edit-links, .edit-button, .hide-for-edit').hide();
            $('.showeditlinks a').removeAttr('style');
            $.cookies.del('admin_switch');
        } else {
            $('.edit-links, .edit-button, .hide-for-edit').show();
            $('.showeditlinks a').attr('style', 'color: red');
            $.cookies.set('admin_switch', 'on');
        }
        return false;
    });
    $('.nohide').show();

    //
    $(".overeditor").click(function(){
        $.fn.generateOverlay($(this).attr('href'), $(this).attr('id'));
        return false;
    });
    $(".overlink").click(function(){
        $.fn.generateOverlay($(this).attr('href'));
        return false;
    });
    $(".overkill").click(function(){
        var me = $(this);
        if (confirm(delete_confirm)) {
            $("body").prepend($(wait).clone(true));
            $.getJSON(me.attr('href'), function(data){
                if (data.status=='ok') {
                    $(".wait").css('background-color', '#efe').css('border-color', '#0a0').css('color', '#0a0').text(data.message);
                    me.closest(".killme").animate({opacity: 0}, 500, function() {$(this).remove();});
                    if (me.hasClass('n-redirect')) {
                        $(".wait").oneTime(150, function(){location.href = me.attr('rel');});
                    }
                } else {
                    $(".wait").css('background-color', '#fdd').css('border-color', '#d77').css('color', '#d00').text(data.message);
                }
                $(".wait").oneTime(1500, function(){$(this).remove();});
            });

        }
        return false;
    });
    $(".kill").click(function(){
        if (!confirm(delete_confirm)) {
            return false;
        }
    });
    $(".overajax").click(function(){
        var me = $(this);
        $("body").prepend($(wait).clone(true));
        $.getJSON(me.attr('href'), function(data){
            if (data.ok) {
                $(".wait").css('background-color', '#efe').css('border-color', '#0a0').css('color', '#0a0').text(data.ok).delay(2500).remove();
            } else {
                $(".wait").css('background-color', '#fdd').css('border-color', '#d77').css('color', '#d00').text(data.error).delay(2500).remove();
            }
        });
        return false;
    });

    $(".ask-confirm").click(function(){
        if (!confirm(translate_are_you_sure_want+" "+$(this).attr('title')+"?")) {
            return false;
        }
    });
});
