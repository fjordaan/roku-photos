# Functionality

What do each of the menu items in [structure.md ](https://github.com/fjordaan/roku-photos/blob/master/structure.md) do?  

Boolean options display a checkmark if selected. Activating them again will not remove the checkmark, the user has to select a different option. 
Where I write ### it means the number of photos in that selection.

## Exit menu

### Cancel
- **Function:** Closes menu

### Exit screensaver
- **Function:** Closes the screensaver app and returns to the Roku home screen

## Main menu

### Photos 
- **Type:** Submenu
- **Function:** Opens Photos submenu
- **Label:** Selected option label or short label, followed by ###

#### Displaying all photos (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in Library
- **Label:** ### (number of photos in Library)
- **Short label:** All *(displayed as label in parent menu)*

#### This folder only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos in the same directory as the current photo
- **Label:** ### (number of matching photos)

#### This day only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same date (day, month year) as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### This month only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same month and year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### This year only
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Photos menu
- **Function:** Sets Playlist to all photos with the same year as the current photo. (TBC which EXIF/IPTC field to use.)
- **Label:** ### (number of matching photos)

#### With tag...
- **Type:** Submenu AND Boolean. Display checkmark if any sub-option is selected. Cannot normally be combined with other options in Photos menu, apart from "Any tag"
- **Function:** Opens Tag sub-submenu
- **Label:** Selected tag or tags (comma-separated), or short label, followed by (###)

##### Any tag (only show photos that have tags)
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Photos menu. CANNOT be combined with other options in Tag sub-submenu
- **Function:** Sets Playlist to all photos IN THE CURRENT PLAYLIST which have one or more IPTC tags. (Which is usually those I added to Flickr.)
- **Label:** ### (number of matching photos)
- **Short label:** Any tag *(displayed as label in parent menu)*

##### Tag n
- One menu item for every IPTC tag in the current photo
- **Type:** Boolean option. Display checkmark if selected. CAN be combined with other options in Tag sub-submenu. (So you can select multiple tags.)
- **Function:** Sets Playlist to all photos in Library that includes the selected IPTC tag

##### Close menu
- **Function:** Closes Tag sub-submnenu

*Why no "Clear tags" option? You clear tags by selecting a different option from the Photos submenu.*

#### Close menu
- **Function:** Closes Photos submnenu

### Order
- **Type:** Submenu
- **Function:** Opens Order submenu
- **Label:** Selected option label or short label
- Selecting any of these options will create a new playlist. The user will remain at the current photo, but they will not be able to go `Back` to previous photos.

#### Random order (default)
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to random order. The photos in the playlist stay the same, but their order is randomised. The current photo stays the same.
- **Label:** None
- **Short label:** Random order

#### Chronological order
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to chronological order (using EXIF/IPTC metadata), with the user continuing from the current photo.
- **Label:** None

#### A-Z by filename
- **Type:** Boolean option. Display checkmark if selected. Cannot be combined with other options in Order menu
- **Function:** Sets Playlist sequence to alphanumeric order based on filename, with the user continuing from the current photo.
- **Label:** None

#### Close menu
- **Function:** Closes Order submnenu

### Settings
- **Type:** Submenu
- **Function:** Opens Settings submenu
- **Label:** None

TO DO: Settings menu functionality
