// Binding keys for navigation
// http://stackoverflow.com/a/6011119


$(document).keydown(function(e) {
    
    $('.controls button').removeClass('active');
    // console.log(e.which);

    switch(e.which) {

        case 13: // enter
        // $('.screen').toggleClass('shown');
        $('.ok').addClass('active');
        control = 'enter';
        break;

        case 37: // left
        $('.navigate-left').addClass('active');
        control = 'left';
        break;

        case 38: // up
        $('.navigate-up').addClass('active');
        control = 'up';
        break;

        case 39: // right
        $('.navigate-right').addClass('active');
        control = 'right';
        break;

        case 40: // down
        $('.navigate-down').addClass('active');
        control = 'down';
        break;

        case 8: // backspace
        $('.navigate-back').addClass('active');
        control = 'back';
        break;

        case 32: // space
        $('.play-pause').addClass('active');
        control = 'play-pause';
        break;

        case 90: // z (r interferes with refresh)
        $('.rewind').addClass('active');
        control = 'rewind';
        break;

        case 88: // x
        $('.forward').addClass('active');
        control = 'forward';
        break;

        default: return; // exit this handler for other keys
    }
    e.preventDefault(); // prevent the default action (scroll / move caret)
    console.log(control);
    $('.message.event').show().html(control);
});

// Switch screens

$('.screen-home .navigate-up').click(function(){
    $('.screen-home').removeClass('shown');
    $('.screen-order').addClass('shown');
    return false;
});
$('.screen-order .navigate-down').click(function(){
    $('.screen-order').removeClass('shown');
    $('.screen-home').addClass('shown');
    return false;
});
$('.screen-order .navigate-up').click(function(){
    $('.message.order-new').show();
    return false;
});
$('.screen-home .navigate-down').click(function(){
    $('.screen-home').removeClass('shown');
    $('.screen-lock').addClass('shown');
    return false;
});
$('.screen-lock .navigate-up').click(function(){
    $('.screen-lock').removeClass('shown');
    $('.screen-home').addClass('shown');
    return false;
});
$('.screen-lock .navigate-down').click(function(){
    $('.screen-lock').removeClass('shown');
    $('.screen-lock2').addClass('shown');
    return false;
});
$('.screen-lock2 .navigate-up').click(function(){
    $('.screen-lock').addClass('shown');
    $('.screen-lock2').removeClass('shown');
    return false;
});
// $('button.btn').click(function(){
//     $('.screen').hide();
//     return false;
// });

// Make remote draggable
// https://css-tricks.com/snippets/jquery/draggable-without-jquery-ui/

(function($) {
    $.fn.drags = function(opt) {

        opt = $.extend({handle:"",cursor:"move"}, opt);

        if(opt.handle === "") {
            var $el = this;
        } else {
            var $el = this.find(opt.handle);
        }

        return $el.css('cursor', opt.cursor).on("mousedown", function(e) {
            if(opt.handle === "") {
                var $drag = $(this).addClass('draggable');
            } else {
                var $drag = $(this).addClass('active-handle').parent().addClass('draggable');
            }
            var z_idx = $drag.css('z-index'),
                drg_h = $drag.outerHeight(),
                drg_w = $drag.outerWidth(),
                pos_y = $drag.offset().top + drg_h - e.pageY,
                pos_x = $drag.offset().left + drg_w - e.pageX;
            $drag.css('z-index', 1000).parents().on("mousemove", function(e) {
                $('.draggable').offset({
                    top:e.pageY + pos_y - drg_h,
                    left:e.pageX + pos_x - drg_w
                }).on("mouseup", function() {
                    $(this).removeClass('draggable').css('z-index', z_idx);
                });
            });
            e.preventDefault(); // disable selection
        }).on("mouseup", function() {
            if(opt.handle === "") {
                $(this).removeClass('draggable');
            } else {
                $(this).removeClass('active-handle').parent().removeClass('draggable');
            }
        });

    }
})(jQuery);

$('.remote').drags();