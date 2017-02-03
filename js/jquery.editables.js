/* editables */
var classEditable = "textmode";
var classEditMode = "editmode";
var clonePrefix = "clone_";

/**
 * copy value from form input to 'cloned' span
 * @param {Object} src - source form input
 */
$.fn.copyValueFromInput = function(src){
    $(this).attr("class", $(src).attr("class"));
    if ($(src).is("select") && ($(src).find("option[value=" + $(src).val() + "]").val() != 'null')) {
        $(this).text($(src).find("option[value=" + $(src).val() + "]").text());
    }
    else {
        $(this).text($(src).val());
    }
    return $(this);
};

//TODO fixup select values
$.fn.copyValueToInput = function(src){
    $(this).attr("class", $(src).attr("class"));
    if ($(this).is("select")) {
        $(this).find("option:first-child = " + $(src).text() + "").attr('selected', true);
    }
    else {
        $(this).val($(src).text());
    }
    return $(this);
};

/**
 * find input for cloned span
 * @param  clonePrefix - cloned span prefix value
 */
$.fn.getOriginal = function(){
    return $(this).closest("form").find("[name=" + $(this).attr("id").replace(clonePrefix, "")+ "]");
};

$(document).ready(function(){
    var inputs = $(
                   "." + classEditable + " form input[type=text], "
                 + "." + classEditable + " form input[type=password], "
                 + "." + classEditable + " form textarea, "
                 + "." + classEditable + " form select, "
                  );

    var multiples =$(
                 "." + classEditable + " form select, "
               + "." + classEditable + " form input[type=radio], "
               + "." + classEditable + " form input[type=checkbox]"
                    );

    var buttons = $(
                    "." + classEditable + " form input[type=submit], "
                  + "." + classEditable + " form input[type=reset]"
                   );

    var labels = $(
                    "." + classEditable + " label"
                  );

    $(buttons).hide();

    jQuery.each($(inputs), function(){
        /* make span that contains input's value and hiding input */
        var clonedSpan = $(document.createElement("span"));
        $(clonedSpan).attr("class", $(this).attr("class")).
        attr("id", clonePrefix + $(this).attr("name"));
        if ($(this).val() == "") {
            $(clonedSpan).text("---");
        }
        else {
            if ($(this).is("select")) {
                $(clonedSpan).text($(this).text());
            }
            else {
                $(clonedSpan).text($(this).val());
            }
        }
            $(this).hide().after($(clonedSpan));
    });

    /**
     * 'onChange' event. Trigger for fields in 'editable' mode
     */
    $(inputs).change(function(){
        var clone = $(this).closest("form").find("#" + clonePrefix + $(this).attr("name"));
        $(clone).copyValueFromInput($(this));
    });

    var buttonEdit = $(document.createElement("a")).addClass("button-edit").text("Изменить");

    $(".form-wrapper.textmode").prepend($(buttonEdit).clone(true));

    /**
     * Switching to 'edit mode'. Showing back all inputs
     * and hiding 'cloned' spans
     */
    $(".button-edit").toggle(
        function(e){
            var container = $(e.target).closest("."+classEditable);
            var clones = jQuery.grep($(container).contents().find("span"), function(clone){
                return ($(clone).attr("id").indexOf(clonePrefix) > -1);
            });
            $(this).text('Просмотр');
            $(container).find(".button-clone, .button-delete").css('display', 'block');
            $(container).removeClass(classEditable).addClass(classEditMode);
            $(container).contents().find("input, textarea, select").show();
            $(clones).hide();
        },
        function(e){
            var container = $(e.target).closest("."+classEditMode);
            var clones = jQuery.grep($(container).contents().find("span"), function(clone){
                return ($(clone).attr("id").indexOf(clonePrefix) > -1);
            });
            $(this).text('Изменить');
            $(container).find(".button-clone, .button-delete").hide();
            $(container).find(".button-clone").next().hide();
            $(clones).hide();
            $(container).removeClass(classEditMode).addClass(classEditable);
            $(container).contents().find("input, textarea, select").hide();
            $(clones).show();
    });
});