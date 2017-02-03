/**
 * Wrap for jQuery
 *
 * @package Striped 3
 * @subpackage js
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2011
 */
jQuery(function($) {
    //wrap menu
    var wrapout = $(document.createElement("a")).text('↓').addClass("wrap-out").attr('href', 'javascript:void(0);').attr('title', 'expand');
    var wrapin = $(document.createElement("a")).text('↑').addClass("wrap-in").attr('href', 'javascript:void(0);').attr('title', 'collapse');

    $(".wrap-level").before(wrapin);

    $.each($(".wrap-level"), function() {
        if ($.cookies.get($(this).attr('id')) == 'wrapped') {
            var n_wrapout = wrapout.clone();
            if ($(this).find('.active').length == 0) {
                $(this).hide();
                $(this).prev('.wrap-in').after(n_wrapout).remove();
            }
        }
    });

    $(".wrap-in").on('click', function(){
        var n_wrapout = wrapout.clone();
        var ul = $(this).next('.wrap-level');
        ul.hide(500).before(n_wrapout);
        $.cookies.set(ul.attr('id'), 'wrapped');
        $(this).remove();
    });
    $(".wrap-out").on('click', function(){
        var n_wrapin = wrapin.clone();
        var ul = $(this).next('.wrap-level');
        ul.show(500).before(n_wrapin);
        $.cookies.del(ul.attr('id'));
        $(this).remove();
    });
    
    
});