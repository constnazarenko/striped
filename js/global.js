jQuery(function($) {
    //cookies
    var cookieOption = {
        expiresAt: new Date(2099, 1, 1)
    };
    $.cookies.setOptions(cookieOption);

    //marker
    $(".stopPropagation").click(function(event){
        event.stopPropagation();
    });
    $(".markme").click(function(event){
        if(event.target == this){
            event.stopPropagation();
        }
        $(this).toggleClass('marked');
    });

    //hider
    $(".unhideme").click(function(event){
        $('.' + $(this).attr('rel')).show();
        $('a[rel='+$(this).attr('rel')+'].unhideme').hide();
        $('a[rel='+$(this).attr('rel')+'].hideme').show();
        return false;
    });
    $(".hideme").click(function(event){
        $('.' + $(this).attr('rel')).hide();
        $('a[rel='+$(this).attr('rel')+'].hideme').hide();
        $('a[rel='+$(this).attr('rel')+'].unhideme').show();
        return false;
    });

    $alertOnce = true;
    alertOnce = function(text) {
        if($alertOnce){
            alert(text);
            $alertOnce=false;
        }
    };
    
    // toggleTitle
    $('input.toggleTitle').blur(function() {
        if ($(this).val()=='') {
            $(this).val($(this).attr('title')).css('color', '#666');
        }
    });
    $('input.toggleTitle').focus(function() {
        if ($(this).val()==$(this).attr('title')) {
            $(this).val('');
        }
        $(this).css('color', '');
    });
    //check "empty" form submition
    $('input.toggleTitle').closest('form').submit(function() {
        var ok = true;
        $(this).find('input.toggleTitle').each(function() {
            if ($(this).val() == $(this).attr('title') && $(this).hasClass('required')) {
                $(this).css('color', 'red').fadeTo(200, 0.2).fadeTo(200, 1, function() {$(this).css('color', 'lightgray');});
                ok = false;
            } else if ($(this).val() == $(this).attr('title')) {
                $(this).val('');
            }
        });
        return ok;
    });
    //add caption from title on startup
    window.setTimeout(function(){$('input.toggleTitle').trigger('blur');}, 100);

    $('.subformclick').on('click', function(e){
        $(this).nextAll('.subform').toggle(500);
        $('body').one('click', function(e){$('.subform').toggle();});
        return false;
    });
    $('body').on('click','.subform, .ui-colorpicker', function(e){
        e.stopPropagation();
    });


    /* ***************** */
    /*                   */
    /* FLOATING HEADINGS */
    /*                   */
    /* ***************** */
    var $state = new Array();
    var $offset = new Array();
    var $stoppoint = new Array();
    var $margin = 0;
    $.fn.checkFloatState = function(i, obj){
        if ($state[i] == undefined && $(window).scrollTop() >= obj.offset().top - $margin) {
            $offset[i] = obj.offset().top - $margin ;
            
            if (!$(obj).is('thead')) {
                //do
                obj.width(obj.width()).addClass('fixed floating-table-'+i+'');
                table = $(obj).closest('form').find('table');
            } else {
                table = $(obj).closest('table');
                //do
                newobj = obj.clone(true);
                $.each($(obj).find('th'), function(i, th) {
                    $(newobj.find('th').get(i)).width($(th).width()).find('input').remove();
                });
                table.before($(document.createElement("table")).addClass('fixed floating-table-'+i+' fixed-table tech').width(table.width()).css('top', $margin+'px').append(newobj));
            }
            
            $margin += obj.outerHeight(true);
            $stoppoint[i] = table.offset().top + table.outerHeight(true) - $margin;
            
            $state[i] = 'fixed';
        }
        if ($state[i] == 'fixed' && $(window).scrollTop() < $offset[i]) {
            //unlog state
            delete $state[i], $offset[i], $stoppoint[i];
            $margin -= obj.outerHeight(true);
            
            if (!$(obj).is('thead')) {
                //do
                obj.removeClass('fixed floating-table-'+i).width('').css('margin', '0');
            } else {
                //do
                $('.floating-table-'+i).remove();
            }
        }
        if ($state[i] == 'fixed' && $(window).scrollTop() >= $stoppoint[i]) {
            //log state
            $state[i] = 'absolute';
            $margin -= obj.outerHeight(true);
            
            if (!$(obj).is('thead')) {
                //do
                obj.removeClass('fixed').addClass('absolute').css('top', $stoppoint[i]+'px');
            } else {
                //do
                $('.floating-table-'+i).removeClass('fixed').addClass('absolute').css('top', $stoppoint[i]+'px');
            }
        }
        if ($state[i] == 'absolute' && $(window).scrollTop() < $stoppoint[i]) {
            if (!$(obj).is('thead')) {
                //do
                obj.removeClass('absolute').addClass('fixed').css('top', $margin+'px');
            } else {
                //do
                $('.floating-table-'+i).removeClass('absolute').addClass('fixed').css('top', $margin+'px');
            }
            
            //log state
            $state[i] = 'fixed';
            $margin += obj.outerHeight(true);
        }
        $('.floating-table-'+i+'').css('margin-left', '-'+$(window).scrollLeft()+'px');
    };
    //init floating
    $(window).scroll(function() {
        $('.fixOnScroll, .fixOnScrollTable thead').each(function(i) {
              $.fn.checkFloatState(i, $(this));
        });
    });
    $.fn.assignAction = function(obj, act) {
        $(obj).closest('form').find('input[name=action]').val(act);
    };
    $.fn.assignRedirect = function(obj, act) {
        $(obj).closest('form').find('input[name=redirect]').val(act);
    };
    
    /* CHECK ALL checkbox */
    $('input.check-all').click(function() {
        sw = $(this).is(':checked');
        $(this).closest('table').find('tbody td input[type=checkbox]').prop("checked", sw).closest('tr').toggleClass('marked',sw);
        $(this).closest('table').find('input[type=checkbox].check-all').prop("checked", sw);
    });
    
    //click on TR activates CHECKBOX
    var countbox = $(document.createElement("div")).attr('style','position: fixed; width: 100px; left:0;right:0; margin: 3px auto; z-index: 1000').addClass('warning');
    var countamount = 0;
    var lastchecked = -1;

    $.fn.clickTR = function(event, tr, checked, ckbox) {
        
        if (ckbox) {
            if (checked) {
                tr.removeClass('marked');
                ckbox.prop("checked", false);
            } else {
                tr.addClass('marked');
                ckbox.prop("checked", true);
            }
        }

        if (event.shiftKey && lastchecked >= 0) {
            if (tr.index() > lastchecked) {
                f = lastchecked;
                s = tr.index();
            } else {
                f = tr.index();
                s = lastchecked;
            }
            if (!checked) {
                tr.closest('tbody').find('tr').slice(f, s).addClass('marked').find(':checkbox').prop("checked", true);
            } else {
                tr.closest('tbody').find('tr').slice(f, s).removeClass('marked').find(':checkbox').prop("checked", false);
            }
        } else {
            if (checked) {
                tr.removeClass('marked');
            } else {
                tr.addClass('marked');
            }
        }
        lastchecked = tr.index();
    };
     
    $('.tech tbody').on("click", "tr", function(event) {
        
        ckbox = $(this).find(':checkbox');
        if (ckbox.length > 0) {
            $.fn.clickTR(event, $(this), ckbox.is(':checked'), ckbox);
        } else {
            $(this).toggleClass('marked');
        }
        if ($(this).find('.amount.counts').length > 0) {
            var amount = parseFloat($(this).find('.amount.counts').text());
            if ($(this).hasClass('marked')) {
                countamount += amount;
            } else {
                countamount -= amount;
            }
            $('body').prepend(countbox);
            countbox.text(countamount.toFixed(2) + ' ' + $(this).find('.amount.counts').next('.currency').text());

        }
        document.getSelection().removeAllRanges();
        return false;
    });
    $('.tech a, .tech input:not(:checkbox)').click(function(event){event.stopPropagation();});

    $('.tech tbody input:checkbox').off().click(function(event){
        $.fn.clickTR(event, $(this).closest('tr'), !$(this).is(':checked'));
        event.stopPropagation();
    });

});