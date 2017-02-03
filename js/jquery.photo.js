/**
 * Photo-stripe for jQuery
 *
 * @package Striped 3
 * @subpackage js
 * @author C.Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2011-13
 */
var closeButton = $(document.createElement("div")).addClass("overphotoclose").append($(document.createElement("span")).text("close")),
leftButton = $(document.createElement("a")).addClass("overphotoleft").append($(document.createElement("span")).text("previouse")),
rightButton = $(document.createElement("a")).addClass("overphotoright").append($(document.createElement("span")).text("next")),
phototitle = $(document.createElement("div")).addClass("title").hide(),
phoverlay = $(document.createElement("div")).addClass("overlay").css("opacity", 0.8).click(function(){$.fn.destroyPhotoOverlay();}),
overphotos = new Array(),
overphotoscurrent = 0,
lock = false,
startPosition = 0;

$.fn.generatePhotoOverlay = function(id, title){
    $("body").keyup(function(event) { if (event.which==27) $.fn.destroyPhotoOverlay();}).prepend(phoverlay.clone(true));
    $(".overlay").after($(document.createElement("div")).addClass("overphotoframe").clone(true));
    overphotoscurrent = parseInt(id);

    $(".overphotoframe")
        .animate({width: overphotos[id].width, marginLeft: -(overphotos[id].width/2)}, 250)
        .animate({height: overphotos[id].height}, 250, function() {$(this).prepend($(overphotos[id]).clone(true));})
        .prepend(closeButton.click(function(){$.fn.destroyPhotoOverlay();}).clone(true));
    if (overphotos.length > 1) {
        $(".overphotoframe")
            .prepend(leftButton.click(function(){
                                    if (!lock) {
                                        $.fn.photoPosition(-1, this);
                                    }
                               }).clone(true))
            .prepend(rightButton.click(function(){
                                    if (!lock) {
                                        $.fn.photoPosition(1, this);
                                    }
                                }).clone(true));
        $(".overphotoframe").find('a').height(overphotos[id].height);
    }
    $(".overphotoframe").append(phototitle.clone(true));
    if (title != '' && title != undefined && title != 'undefined') {
        if (title.length < 50) {
            var hgt = 35;
        } else if (title.length < 100) {
            var hgt = 45;
        } else if (title.length < 150) {
            var hgt = 55;
        } else if (title.length < 200) {
            var hgt = 65;
        } else {
            var hgt = 75;
        }
        $(".overphotoframe").animate({height: '+='+hgt}, 250, function() {$(this).find('.title').height(hgt).html(title).show('slow');});
    }
    
    startPosition = $(window).scrollTop();
    $('html, body').animate({
        scrollTop: 0
    }, 100);
};

$.fn.photoPosition = function(pos, me){
    lock = true;
    newpos = overphotoscurrent + pos;
    if (newpos >= overphotos.length) {
        newpos = 0;
    } else if (newpos < 0) {
        newpos = overphotos.length - 1;
    }
    
    $(me).closest('.overphotoframe').find('.title').text('').hide();
    $(me).closest('.overphotoframe').find('.photo').remove();
    
    overphotoscurrent = newpos;
    
    $(me).closest('.overphotoframe')
         .animate({width: overphotos[newpos].width, marginLeft: -(overphotos[newpos].width/2)}, 250)
         .animate({height: overphotos[newpos].height}, 250, function() {$(this).prepend($(overphotos[newpos]).clone(true)); lock = false;});
    $(me).closest('.overphotoframe').find('a').height(overphotos[newpos].height);

    if (overphotos[newpos].title != undefined && overphotos[newpos].title != 'undefined' && overphotos[newpos].title != '') {
        if (overphotos[newpos].title.length < 50) {
            var hgt = 35;
        } else if (overphotos[newpos].title.length < 100) {
            var hgt = 45;
        } else if (overphotos[newpos].title.length < 150) {
            var hgt = 55;
        } else if (overphotos[newpos].title.length < 200) {
            var hgt = 65;
        } else {
            var hgt = 75;
        }
        $(me).closest('.overphotoframe').animate({height: '+='+hgt}, 250, function() {$(this).find('.title').height(hgt).html(overphotos[newpos].title).show('slow');});
    }
};

$.fn.destroyPhotoOverlay = function() {
    $(".overlay").remove();
    $(".overclose").remove();
    $(".overphotoframe").remove();

    $('html, body').animate({
        scrollTop: startPosition
    }, 100);
};

$(document).ready(function() {
    var i = 0;
    $.each($(".overphoto"), function() {
        overphotos[i] = new Image();
        overphotos[i].src = $(this).attr('href');
        overphotos[i].alt = $(this).find('img').attr('alt');
        overphotos[i].title = $(this).find('img').attr('title');
        $(overphotos[i]).addClass('photo');
        $(this).attr('rel', i++);
    });

    $(".overphoto").click(function(){
        $.fn.generatePhotoOverlay($(this).attr('rel'), $(this).find('img').attr('title'));
        return false;
    });
});
