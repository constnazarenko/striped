$(document).ready(function(){
    /* MULTFILES */
    var MFCounter = new Array();
    var killMFButton = $(document.createElement("a")).text('remove').addClass("multifilekill");
    $(".control").on('click', '.multifilekill', function(){
        $(this).closest("div").animate({opacity: 0 }, 500, function() {$(this).remove();});
    });

    $(".multifile").css('cursor', 'pointer').unbind('click').click(function(){
        var newinput = $(this).closest('div').find('.file-input.hiddenfield').append(killMFButton).clone(true);
        var name = $(newinput).find('input').attr('name');
        if (!MFCounter[name]) {
            MFCounter[name] = 0;
        }
        if ($(newinput).hasClass('with-names')) {
            $(newinput).find('input[type="text"]').attr('name', name+'['+(MFCounter[name])+'_title]');
        }
        $(newinput).find('input[type="file"]').each(function(){
            $(this).attr('name', $(this).attr('name')+'['+(MFCounter[name])+']');
        });
        $(newinput).insertBefore(this).show().removeClass('hiddenfield');
        MFCounter[name]++;
        return false;
    });
    
    $(".multifield").css('cursor', 'pointer').unbind('click').click(function(){
        var newinput = $(this).closest('div').find('.inputer.hiddenfield').append(killMFButton).clone(true);
        var name = $(newinput).find('input').attr('name');
        $(newinput).find('input[type="text"]').attr('name', name+'[]');
        $(newinput).insertBefore(this).show().removeClass('hiddenfield');
        return false;
    });


    $(".multiamountselect").css('cursor', 'pointer').unbind('click').click(function(){
        var newinput = $(this).closest('div').find('.amount-select.hiddenfield').append(killMFButton).clone(true);
        var name = $(newinput).find('input').attr('name');
        var cnt = $(this).closest('.control').find('input').length - 1;
            
        $(newinput).find('input[type="text"]').attr('name', name+'['+(cnt)+'][amount]');
        $(newinput).find('select').each(function(){
            $(this).attr('name', $(this).attr('name')+'['+(cnt)+'][value]');
        });
        $(newinput).insertBefore(this).show().removeClass('hiddenfield');
        MFCounter[name]++;
        return false;
    });
});