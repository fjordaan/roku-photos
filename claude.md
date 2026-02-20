# Project description

- This is a slideshow app to run on a Roku 3 set-top box.  
- It displays photos stored on a Synology NAS connected to the same network.  
- It is controlled by the Roku remote.  
- The remote is used to step forward and back through photos, and also change the playlist and other settings via on-screen menus.
- It should also have the ability to start automatically as a screensaver.

## Components

There will be 2 parts to the app:
- The Roku app, installed on the set-top box, that displays the photos and responds to user input from the remote control.
- The server app, running on the NAS, which creates playlists dynamically based on user choices. 

## Slideshow capabilities
- User can navigate to all previous and upcoming photos, even when using a playlist with random rather than sequential photos.
- User can select playlists based on photo EXIF or IPTC metadata, such as "All photos on this date" and "All photos with this tag"

## Server capabilities
