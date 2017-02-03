$(document).ready(function(){
    var cwait = $(document.createElement("div")).addClass("wait").text(translate_wait);
    
    $.fn.reloadComment = function(id, comments_text) {
        $('.comment'+id+' .comment-text').html(comments_text);
        $('.overclose').trigger('click');
    };
    
    $.fn.moveFormHere = function(obj) {
        var form = $('.form-hider .comments-add-form').clone(true).hide();
        $(obj).after(form);
        $(".comments-form").hide(500);
        $(".comments-form").oneTime(500, function(){$(this).remove();});
        $(obj).next('.comments-add-form').addClass('comments-form').show(500);
        $(obj).next('.comments-add-form').find('form').ajaxForm({
            dataType: "json",
            beforeSubmit: function(){
                $(form).find("input[type=submit]").attr("disabled", true);
                $("body").prepend($(cwait).clone(true));
            },
            success: function(j){
                if (j != null) {
                    if (j.status == 'error') {
                        $(".wait").css('background-color', '#fdd').css('border-color', '#d77').css('color', '#d00');
                    } else if(j.status == 'ok') {
                        $(".wait").css('background-color', '#efe').css('border-color', '#0a0').css('color', '#0a0');
                        
                        //creating new comment
                        if (j.comment) {
                            $("a.comments-show-form:not(.additional)").click();
                            var new_comment = $(".comments-myself div.comment").clone(true);
                            $(new_comment).find('.comment-text').html(j.comment);
                            $(new_comment).find('.comm-ident-here').removeClass('comm-ident-here').addClass('comment'+j.id);
                            if (j.system) {
                                $(new_comment).find('.comment-body').addClass('system');
                            }
                            //buttons
                            $(new_comment).find('.stars').attr('rel', j.id);
                            $(new_comment).find('.showcomm, .hidecomm').attr('rel', 'comment'+j.id);
                            $(new_comment).find('.buttons a.to-this').attr('href', $(new_comment).find('.buttons a.to-this').attr('href')+j.id).attr('name', 'comment'+j.id);
                            $(new_comment).find('.buttons a.scroll-up').remove();
                            $(new_comment).find('.buttons a.link-edit').attr('href', $(new_comment).find('.buttons a.link-edit').attr('href')+j.id);
                            $(new_comment).find('.buttons a.comment-delete').attr('href', $(new_comment).find('.buttons a.comment-delete').attr('href')+j.id);
                            
                            //reply
                            $(new_comment).find('.comments-reply').attr('href', j.id).attr('rel', j.keyword);
                            
                            if ($(obj).hasClass('comments-show-form')) {
                                $(obj).closest('.comments').find('.empty').remove();
                                $(obj).before(new_comment);
                                $(obj).prev('.new-comment').removeClass('.new-comment');
                            } else {
                                $(obj).closest('.comment').append(new_comment);
                                $(obj).closest('.comment').find('.new-comment').removeClass('.new-comment');
                            }
                        }
                    }
                    $.each(j.messages, function(){
                        $(".wait").text(this.message);
                    });
                } else {
                    $(".wait").css('background-color', '#efe').css('border-color', '#0a0').css('color', '#0a0').text('ok');
                }
                $(".wait").oneTime(500, function(){$(this).remove();});
                $(form).find("input[type=submit]").attr("disabled", false);
            },
            error: function(j){
                $(".wait").css('background-color', '#fdd').css('border-color', '#d77').css('color', '#d00').text('error while sending');
                $(".wait").oneTime(2000, function(){$(this).remove();});
                $(form).find("input[type=submit]").attr("disabled", false);
            }
        });
    };
    
    $("a.comments-show-form").click(function(e, scrollup){
        $.fn.moveFormHere(this);
        $(this).next('.comments-add-form').find('input[name=keyword\\[main\\]]').attr('value', $(this).attr('rel'));
        if (scrollup) {
            $(this).next('.comments-add-form').find('textarea[name=text\\[main\\]]').focus();
            $("body").scrollTop(0);
        }
        return false;
    });
    
    $("a.comments-show-form:not(.additional)").trigger('click', [true]);
    
    $("a.threads-reply").click(function(){
        var position = $(".comments-show-form.additional").click().focus().position();
        $('html, body').animate({scrollTop: position.top - 50}, 500);
        return false;
    });
    
    $("a.comments-reply").click(function(){
        $.fn.moveFormHere(this);
        $(this).next('.comments-add-form').find('input[name=parent\\[main\\]]').attr('value', $(this).attr('href'));
        $(this).next('.comments-add-form').find('input[name=keyword\\[main\\]]').attr('value', $(this).attr('rel'));
        $(this).next('.comments-add-form').find('textarea[name=text\\[main\\]]').focus();
        return false;
    });
    
    $("a.scroll-up").click(function(){
        if (!$(this).attr('cooldown')) {
            var down = $(document.createElement("a")).text('↓').addClass("scroll-down").attr('href', '#'+$(this).prevAll('a.to-this').attr('name')).attr('title', translate_scroll_down);
            down.click(function(){
                $(this).remove();
                $('html, body').animate({
                    scrollTop: $($(this).attr('href')).offset().top
                }, 500);
                $($(this).attr('href')).next('.scroll-up').removeAttr('cooldown');
                return false;
            });
            $($(this).attr('href')).closest(".buttons").find(".scroll-down").remove();
            $($(this).attr('href')).after(down);
            $('html, body').animate({
                scrollTop: $(this).attr('href')
            }, 500);
            $(this).attr('disabled', true);
            var me = $(this);
            $(".wait").oneTime(1000, function(){me.removeAttr('cooldown');});
        }
        return false;
    });
    
    $(".comment-ajax").on('click', function(){
        var me = $(this);
        if (me.attr('href') != '#') {
            var href = me.attr('href');
            me.attr('href', '#');
            $.getJSON(href, function(data) {
                if (data.status == 'error') {
                    $("body").prepend($(cwait).clone(true));
                    $(".wait").css('background-color', '#fdd').css('border-color', '#d77').css('color', '#d00').text(data.message);
                    $(".wait").oneTime(3000, function(){$(this).remove();});
                }
                if (data.status == 'ok') {
                    if (href.match(/restore/)) {
                        var new_href = href.replace('restore', 'delete');
                        var new_title = translate_comments_delete;
                    } else {
                        var new_href = href.replace('delete', 'restore');
                        var new_title = translate_comments_restore;
                    }
                    me.toggleClass('comment-restore').toggleClass('comment-delete').attr('href', new_href).attr('title', new_title);
                    me.closest('.comment').find('.comment-text:first').html(data.message);
                }
            });
        }
        return false;
    });

    if (comment = document.location.hash.match('#comment([0-9]*)')) {
        $('.comments .comment .comments-reply[href="'+comment[1]+'"]').trigger('click');
    }
    
    //hider
    $(".showcomm").click(function(event){
        var me = $(this);
        comment = me.attr('rel').match('comment([0-9]*)');
        if (comment[1]) {
            $.ajax({
                url: 'comments/hider',
                type: "POST",
                data: ({id: comment[1], hide: 0}),
                success: function(data) {
                    me.closest('.comment').removeClass('hiddencomm').children('.comment-body').removeClass('hiddencomm-body');

                    var subcomments = me.closest('.comment').find('.comment:not(.hiddencomm .comment)');
                    subcomments.add(me.closest('.comment')).show().filter(':not(.hiddencomm)').find('>.comment-body').find('.comment-text, .toolbar .edit-links-no-hide, .comments-reply').show();

                    me.hide().siblings('.hidecomm').show().siblings('.subcomm, .caption').remove();
                }
            });
        }
        return false;
    });
    //
    $.fn.hideCThread = function(me) {
        //me == .comment-body
        me.find('.hidecomm, .comment-text, .toolbar .edit-links-no-hide, .comments-reply').hide();
        me.find('.showcomm').show();
        me.addClass('hiddencomm-body');
        
        var subcomm = me.closest('.comment').addClass('hiddencomm').find('.comment').length;
        if (subcomm) {
            var newcomm = '';
            var unread = me.closest('.comment').find('.comment .unread').length;
            if (unread) {
                newcomm = '<span class="subcomm-new"> + ' + unread + ' new</span>'
                subcomm = subcomm - unread;
            }
            me.find('.buttons').append('<span class="subcomm">subcomments: ' + subcomm + newcomm + "</span>");
        }
        me.find('.buttons').append("<span class='caption' title='"+me.closest('.comment').children('.comment-body').children('.comment-text').text()+"'>"+me.closest('.comment').children('.comment-body').children('.comment-text').text().split("\n")[0].substr(0,80)+"...</span>");
        
        me.closest('.comment').find('.comment').hide();
    }
    $(".hidecomm").click(function(event){
        var me = $(this);
        comment = me.attr('rel').match('comment([0-9]*)');
        if (comment[1]) {
            $.ajax({
                url: 'comments/hider',
                type: "POST",
                data: ({id: comment[1], hide: 1}),
                success: function(data) {
                    $.fn.hideCThread(me.closest('.comment-body'));
                }
            });
        }

        return false;
    });
    $(".comments .comment-body:not(.hiddencomm-body) .showcomm").hide();
    $('.comments .comment-body.hiddencomm-body').each(function(index) {
        $.fn.hideCThread($(this));
    });

    //stars
    $(".comments .stars").click(function(event){
        var me = $(this);
        $.ajax({
            url: 'comments/star',
            type: "POST",
            data: ({id: me.attr('rel'), star: (me.hasClass('starred') ? 0 : 1)}),
            success: function(data) {
                me.toggleClass('starred');
            }
        });
        
        return false;
    });
    
});
