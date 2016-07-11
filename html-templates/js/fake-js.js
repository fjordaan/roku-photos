// Initialise
$order = randomOrder
$lock  = noLock
$screen = '.screen-home'

// Send appropriate event for either keyboard command or button click
if (key up) or (click up button)
    send event: $clickedUp
    $('.navigate-up').addClass('active'); // makes button highlight
if (key up) or (click up button)
    send event: $clickedUp
    $('.navigate-up').addClass('active'); // makes button highlight
// and so on for other buttons...

// What event does depends on which screen is active
if ($screen = '.screen-home') and $clickedUp
    set $screen = '.screen-order'
    display message "Current order: " + $order
    display message "Current lock: " + $lock

if ($screen = '.screen-order') and $clickedUp
    set $order = randomOrder
    display message "New order: " + $order
    $('.screen').hide();
    set $screen = '.screen-home' // back to default screen

if ($screen = '.screen-home') and $clickedDown
    set $screen = '.screen-lock'
    display message "Current order: " + $order
    display message "Current lock: " + $lock

if ($screen = '.screen-lock') and $clickedUp
    set $lock = noLock
    display message "New lock: " + $lock
    $('.screen').hide();
    set $screen = '.screen-home' // back to default screen
// and so on for other event/screen combos



forever evaluate $action
    case $action = 'up'
        case currentScreen = 'screen-home'
            currentScreen = 'screen-top'
        case currentScreen = 'screen-top'
            mode = 'new-mode'
            currentScreen = 'screen-home'
    case $action = 'down'
        case currentScreen = 'screen-home'
            currentScreen = 'screen-bottom'
        case currentScreen = 'screen-bottom'
            mode = 'other-mode'
            currentScreen = 'screen-home'
    $(currentScreen).show();


switch(expression) {
    case n:
        code block
        break;
    case n:
        code block
        break;
    default:
        default code block
} 

(function($) {

})(jQuery);