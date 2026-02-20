# Components

A breakdown of all UI components, their design and composition. Slideshow, Menu, Photo information, Thumbnails

## Slideshow 

- In normal operation the slideshow has no visible user interface, apart from a minimal HUD (1 / n) showing in the top left corner.
- The HUD shows the current slide number and the total number of slides in the current playlist, after which the slideshow will loop or stop.
- When the user presses the `Play/Pause` button, a large Play or Pause icon will show in the centre of the screen for 2 seconds.
- When the user presses the `REW` or `FWD` buttons, a large `<< 10` or `>> 10` icon will show in the centre of the screen for 2 seconds.
- Button actions during slideshow documented in [buttons.md](buttons.md)

## Photo information overlay

- When the `Down` button is pressed during slideshow, a bottom semitransparent overlay appears showing the photo information.
- This mode persists until the user presses the `Up` arrow during slideshow, which hides the photo information overlay.
- Information displayed, stacked vertically:
  - File path
  - Filename (large bold text)
  - Photo description / caption, if in EXIF/IPTC data
  - Tags, if in EXIF/IPTC data
  - Date and time (DD Month YYYY HH:MM:SS) - in top right corner, lining up with file path
- The height of the overlay adapts to its contents.
 
## Menu

- Menu appears in the centre of the screen, using a simple visual style.
- It sits ABOVE all other content, including the overlays.
- Menu item structure and menu contents documented in [menus.md](menus.md)
- Button actions during menu documented in [buttons.md](buttons.md)
- Menu option functionality documented in [functionality.md](functionality.md)

## Thumbnails overlay

- When the `Up` button is pressed during slideshow, a top semitransparent overlay appears showing a row of thumbnail images with the photos in the current playlist.
- This mode persists until the user presses the `Down` arrow during slideshow, which hides the thumbnails overlay.
- The current photo is highlighted and it is always in the horizontal centre, unless it has reached the end or beginning of the playlist.
- The HUD (1 / n) sits ABOVE the Thumbnails overlay.
