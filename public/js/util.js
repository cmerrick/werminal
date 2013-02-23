function focusAtEnd(el) {
    if (typeof el.selectionStart == "number") {
        el.selectionStart = el.selectionEnd = el.value.length;
    } else if (typeof el.createTextRange != "undefined") {
        el.focus();
        var range = el.createTextRange();
        range.collapse(false);
        range.select();
    }
}

function getTextBoxCaretPosition(el) {
    if (typeof el.selectionStart == 'number') {
		return el.selectionStart
    } else if (document.selection && document.selection.createRange) {
        range = document.selection.createRange();
        if (range.parentElement() == editableDiv) {
            var tempEl = document.createElement("span");
            editableDiv.insertBefore(tempEl, editableDiv.firstChild);
            var tempRange = range.duplicate();
            tempRange.moveToElementText(tempEl);
            tempRange.setEndPoint("EndToEnd", range);
            caretPos = tempRange.text.length;
        }
    }
    return caretPos;
}

function getCaretPosition(editableDiv) {
    var caretPos = 0, containerEl = null, sel, range;
    if (window.getSelection) {
       sel = window.getSelection();
        if (sel.rangeCount) {
            range = sel.getRangeAt(0);
            if (range.commonAncestorContainer.parentNode == editableDiv) {
                caretPos = range.endOffset;
            }
        }
    } else if (document.selection && document.selection.createRange) {
        range = document.selection.createRange();
        if (range.parentElement() == editableDiv) {
            var tempEl = document.createElement("span");
            editableDiv.insertBefore(tempEl, editableDiv.firstChild);
            var tempRange = range.duplicate();
            tempRange.moveToElementText(tempEl);
            tempRange.setEndPoint("EndToEnd", range);
            caretPos = tempRange.text.length;
        }
    }
    return caretPos;
}

function isEven(n) 
{
	return (parseInt(n, 10) % 2 == 0);
}

function isOdd(n)
{
	return (parseInt(n, 10) % 2 == 1);
}

$(function() {
$('div.prompt').bind('', function() {

    var offset = getCaretPosition(this),
        $org = $(this),
        $el = $org.clone(),
        char = $el.text().substr(offset-1, 1);

    if (char == '"')
    {
        var html = '<span class="ins_str">' + char + '</span>';
        $el.html($el.text().substr(0, offset - 1) + html + $el.text().substr(offset));
    
        var x = $org.offset().left,
            y = $org.offset().top,
            width = $org.outerWidth() - 22,
            height = $org.outerHeight() - 22;
    
        $el.css({
            'position': 'absolute',
            'top': y,
            'left': x,
            'width': width,
            'height': height,
            'opacity': 0
        });
        $org.before($el);
    
        var $span = $el.find('span.ins_str');
        if ($span.length > 0)
        {
            var offset = $span.offset(),
                char_x = offset.left - $(this).scrollLeft(),
                char_y = offset.top - $(this).scrollTop();
    
            $('#popup').css({
                'left': char_x,
                'top': char_y
            });
        }
        
        console.log($span.offset(), $span.position());
    
        $el.remove();   
    }
    else
    {
        // Use a regex to see if we are in the context of a valid username beginning with @, if not reset the caret
    }
});
})
