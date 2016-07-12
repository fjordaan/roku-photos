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

// Initialise defaults
var action = '';
var currentOrder = 'random-order';
var currentLock  = 'unlocked';
var currentScreen = 'screen-home';
var orderMessage = 'Photos displayed in random order';
var lockMessage = 'Unlocked: displaying all photos';
var playState    = 'play';
var slides = $('.slides').children('.slide');
console.log(slides);
var slide = 0;
$('.screen').hide();

// Slideshow
function slideShow(slide) {
    console.log(slide);
    // console.log(slides.length);
    if(slide > slides.length) {
        slide = 0;
    }
    $('.slides .slide').removeClass('active');
    $('.slides .slide:eq('+slide+')').addClass('active');
}
slideShow(slide);


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
    $('.message.event').show().html(action).animateCss('flash');
    $('.remote .' + action).addClass('active').delay(300).queue(function(next){
        $(this).removeClass("active");
        next();
    });
    navigate(action);

});

// Change order and lock mode
function newOrder(order) {
    currentOrder = order;
    switch(currentOrder) {
        case 'random-order':
            message = 'Photos displayed in random order';
            break;
        case 'chronological-order':
            message = 'Photos displayed in chronological order';
            break;
        case 'alphabetical-order':
            message = 'Photos displayed in alphabetical order';
            break;
        default:
            message = '';
    }
    $('.message.order-new').show().html(message).animateandhideCss('fadeOut');
    $('.message.order-current').html(message);
};
function newLock(lock) {
    currentLock = lock;
    switch(currentLock) {
        case 'unlocked':
            message = 'Unlocked: displaying all photos';
            break;
        case 'lock-month':
            message = 'Displaying photos from this month only';
            break;
        case 'lock-folder':
            message = 'Displaying photos from this folder only';
            break;
        case 'lock-day':
            message = 'Displaying photos from this day only';
            break;
        case 'lock-year':
            message = 'Displaying photos from this year only';
            break;
        default:
            message = '';
    }
    $('.message.lock-new').show().html(message).animateandhideCss('fadeOut');
    $('.message.lock-current').html(message);
};

function resume() {
    currentScreen = 'screen-home';
    $('.message.pause-icon').hide();
    $('.message.play-icon').toggle().animateandhideCss('zoomIn');
    playState = 'play';
};
function pause() {
    $('.message.pause-icon').toggle().animateCss('zoomIn');
    playState = 'pause';
};

// Switch screens or activate buttons

function navigateGo() {
    $('.screen').hide();
    if(currentScreen !== "screen-home") {
        $('.' + currentScreen).show();
    }
    $('.order-current').hide();
    $('.lock-current').hide();
}

function navigate(action) {

    if(action == "navigate-up") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-order';
                pause();
                break;
            case 'screen-order':
                newOrder('random-order');
                resume();
                break;
            case 'screen-lock':
                newLock('unlocked');
                resume();
                break;
            case 'screen-lock2':
                currentScreen = 'screen-lock';
                break;
            default:
                currentScreen = 'screen-home';
        }
        navigateGo();
    }
    if(action == "navigate-down") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-lock';
                break;
            case 'screen-order':
                resume();
                break;
            case 'screen-lock':
                currentScreen = 'screen-lock2';
                break;
            default:
                currentScreen = 'screen-home';
        }
        navigateGo();
    }
    if(action == "navigate-left") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-home';
                slide--;
                slideShow(slide);
                break;
            case 'screen-order':
                newOrder('chronological-order');
                resume();
                break;
            case 'screen-lock':
                newLock('lock-month');
                resume();
                break;
            case 'screen-lock2':
                newLock('lock-day');
                resume();
                break;
            default:
                currentScreen = 'screen-home';
        }
        navigateGo();
    }
    if(action == "navigate-right") {
        switch(currentScreen) {
            case 'screen-home':
                currentScreen = 'screen-home';
                slide++;
                slideShow(slide);
                break;
            case 'screen-order':
                newOrder('alphabetical-order');
                resume();
                break;
            case 'screen-lock':
                newLock('lock-folder');
                resume();
                break;
            case 'screen-lock2':
                newLock('lock-year');
                resume();
                break;
            default:
                currentScreen = 'screen-home';
        }
        navigateGo();
    }
    if(action == "ok") {
        $('.' + currentScreen).toggle();
        $('.message.order-current').toggle();
        $('.message.lock-current').toggle();
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

    // console.log(action);
    // console.log(currentScreen);
    // console.log(currentOrder);
    // console.log(currentLock);
    
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






