// jQuery plugin to make animate.css easy to use
// https://github.com/daneden/animate.css
$.fn.extend({
    animateCss: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).removeClass('animated ' + animationName);
        });
    },
    animateandhideCss: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $(this).addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).hide();
        });
    }
});

var action = '';
var currentOrder = 'random-order';
var currentLock  = 'unlocked';
var currentScreen = 'screen-home';
var playState    = 'play';
$('.screen').hide();


// Binding keys for navigation
// http://stackoverflow.com/a/6011119
$(document).keydown(function(e) {
    
    $('.controls button').removeClass('active');
    // $('.message.event').removeClass('animated');
    // console.log(e.which);

    switch(e.which) {

        case 13: // enter
        // $('.screen').toggleClass('shown');
        action = 'ok';
        break;

        case 37: // left
        action = 'navigate-left';
        break;

        case 38: // up
        action = 'navigate-up';
        break;

        case 39: // right
        action = 'navigate-right';
        break;

        case 40: // down
        action = 'navigate-down';
        break;

        case 8: // backspace
        action = 'navigate-back';
        break;

        case 32: // space
        action = 'play-pause';
        break;

        case 90: // z (r interferes with refresh)
        action = 'rewind';
        break;

        case 88: // x
        action = 'forward';
        break;

        default: return; // exit this handler for other keys
    }
    e.preventDefault(); // prevent the default action (scroll / move caret)
    console.log(action);
    // $('.message.event').show().html(action).addClass('animated flash');
    $('.message.event').show().html(action).animateCss('flash');
    // Delay: http://stackoverflow.com/a/2510255
    $('.remote .' + action).addClass('active').delay(300).queue(function(next){
        $(this).removeClass("active");
        next();
    });
    navigate(action);
});

// Navigating by clicking buttons
$('button').click(function() {

    $('.controls button').removeClass('active');
    var action = $(this).attr("class");
    console.log(action);
    $('.message.event').show().html(action).animateCss('flash');
    $('.remote .' + action).addClass('active').delay(300).queue(function(next){
        $(this).removeClass("active");
        next();
    });
    navigate(action);

});

// Switch screens or activate buttons

function navigate(action) {
    

    if(action == "navigate-up") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-order';
                $('.message.pause-icon').toggle().animateCss('zoomIn');
                playState = 'pause';
                break;
            case 'screen-order':
                currentOrder = 'random-order';
                $('.message.order-new').show().html(currentOrder).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock':
                currentLock = 'unlocked';
                $('.message.lock-new').show().html(currentLock).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock2':
                currentScreen = 'screen-lock';
                break;
            default:
                currentScreen = 'screen-home';
        }
        $('.screen').hide();
        if(currentScreen !== "screen-home") {
            $('.' + currentScreen).show();
        }
    }
    if(action == "navigate-down") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-lock';
                break;
            case 'screen-order':
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock':
                currentScreen = 'screen-lock2';
                break;
            default:
                currentScreen = 'screen-home';
        }
        $('.screen').hide();
        if(currentScreen !== "screen-home") {
            $('.' + currentScreen).show();
        }
    }
    if(action == "navigate-left") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-home';
                break;
            case 'screen-order':
                currentOrder = 'chronological-order';
                $('.message.order-new').show().html(currentOrder).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock':
                currentLock = 'lock-month';
                $('.message.lock-new').show().html(currentLock).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock2':
                currentLock = 'lock-day';
                $('.message.lock-new').show().html(currentLock).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            default:
                currentScreen = 'screen-home';
        }
        $('.screen').hide();
        if(currentScreen !== "screen-home") {
            $('.' + currentScreen).show();
        }
    }
    if(action == "navigate-right") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-home';
                break;
            case 'screen-order':
                currentOrder = 'alphabetical-order';
                $('.message.order-new').show().html(currentOrder).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock':
                currentLock = 'lock-folder';
                $('.message.lock-new').show().html(currentLock).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            case 'screen-lock2':
                currentLock = 'lock-year';
                $('.message.lock-new').show().html(currentLock).animateandhideCss('flash');
                currentScreen = 'screen-home';
                $('.message.pause-icon').hide();
                $('.message.play-icon').toggle().animateandhideCss('zoomIn');
                playState = 'play';
                break;
            default:
                currentScreen = 'screen-home';
        }
        $('.screen').hide();
        if(currentScreen !== "screen-home") {
            $('.' + currentScreen).show();
        }
    }
    if(action == "ok") {
        $('.' + currentScreen).toggle();
    }
    if(action == "play-pause") {
        $('.caption').toggle();
        if(playState == "play") {
            $('.message.play-icon').hide();
            $('.message.pause-icon').toggle().animateCss('zoomIn');
            playState = 'pause';
        }
        else {
            $('.message.pause-icon').hide();
            $('.message.play-icon').toggle().animateandhideCss('zoomIn');
            playState = 'play';
        }
    }
    if(action == "navigate-back") {
        currentScreen = 'screen-home';
        $('.screen').hide();
    }

    console.log(currentScreen);
    console.log(currentOrder);
    console.log(currentLock);
    
};


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