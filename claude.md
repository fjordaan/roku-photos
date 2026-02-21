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
- Slideshow advances automatically, by default every 2 seconds
- User can use the `Back` / `Forward` buttons to navigate to all previous and upcoming photos in the current playlist, even in playlists with random rather than sequential order.
- User can use `Play/Pause` button to pause the slideshow. It stays paused until `Play/Pause` is pressed again.
- While paused it can be manually controlled using the `Back` / `Forward` buttons.
- User can use the menu to switch to a new playlist based on the properties of the current photo, such as "All photos on this date" and "All photos with this tag", using EXIF or IPTC metadata.

## Server capabilities
- Serves a REST API on port 8080 (Python/Flask)
- Builds and returns playlists as JSON arrays of photo objects, filtered by type (all, folder, date, tag) and sorted by order (random, chronological, A-Z)
- Serves photo files directly via HTTP (`send_file`)
- Maintains a SQLite database indexing all photos in the library (path, filename, date taken, EXIF/IPTC tags, dimensions)
- Provides a tag list endpoint for populating the "With tag" menu
- Manages a blocklist (stored in SQLite) to exclude specific photos from all playlists
- Indexer script scans `/volume1/Pictures` recursively, reads EXIF/IPTC metadata, and populates the database

## Architecture

### Tech stack
- **Roku app**: BrightScript + SceneGraph XML (native Roku channel, sideloaded)
- **Server**: Python 3, Flask, SQLite
- **NAS**: Synology DS215j, DSM 7.1.1, `/volume1/Pictures` (110K photos, 322GB)
- **Roku**: Model 4200X (Roku 3), SW 15.1, IP `192.168.1.181`
- **NAS IP**: `192.168.1.51`, server on port `8080`

### Roku app components
- `MainScene` — root scene, coordinates all sub-components
- `SlideshowComponent` — displays current photo via Poster node, manages auto-advance timer
- `PlaylistManager` — holds current photo array, current index, and history stack for back-navigation
- `ButtonHandler` — routes all `roUniversalControlEvent` presses to the correct handler
- `MenuComponent` — floating overlay, nested menu state machine (Exit / Main / submenus)
- `HUDComponent` — top-left "current / total" indicator
- `PhotoInfoComponent` — bottom semitransparent overlay (filename, path, date, tags) [Stage 3]
- `ThumbnailComponent` — top thumbnail strip [Stage 5]

### Settings persistence
All user settings stored in `roRegistry` (section `"roku-photos"`), so they survive app restarts.
Defaults: slide duration 2s, random order, all photos, looping, dissolve transition, fit to screen, no video, no sound.

### Server API endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/playlist` | Returns JSON array of photo objects. Params: `type` (all/folder/date/month/year/tag), `order` (random/chrono/az), `path`, `date`, `tag` |
| GET | `/api/tags` | Returns list of all IPTC tags in the library |
| POST | `/api/blocklist` | Adds a photo path to the blocklist |
| GET | `/photos/<path>` | Serves a photo file |
| GET | `/api/status` | Health check |

### EXIF/IPTC date resolution
For date-based playlists, use this fallback chain:
1. EXIF `DateTimeOriginal`
2. IPTC `DateCreated`
3. File modification time (`mtime`)

### Repository structure
```
roku-photos/
├── roku-app/          # BrightScript channel
│   ├── manifest       # Roku manifest
│   ├── source/        # .brs files (BrightScript logic)
│   └── components/    # SceneGraph XML components
├── server/            # Python Flask server
│   ├── app.py         # Flask app and API routes
│   ├── indexer.py     # Library scanner / metadata extractor
│   ├── config.py      # Library path, port, etc.
│   └── requirements.txt
└── *.md               # Documentation
```

### Key decisions
- No API authentication (home LAN only)
- Settings stored on Roku (not server-side)
- Photos served through Flask initially; switch to nginx in front if performance is a problem
- Library paths are configurable via registry (not hardcoded), defaulting to `/volume1/Pictures`
