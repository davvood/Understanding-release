# Changelog

## v5.25.1
- Home: Join the Discord now sits right under your favourites
- Home: the music player is gone

## v5.25
- Join the Discord: new button at the bottom of the Home tab (copies the invite)
- Welcome card the first time you run the menu, with the basics
- The menu tells you once which features your executor can't run, so nothing quietly does nothing

## v5.24
- New watermark in the menu's own style: separate cells for FPS, ping and the time; FPS and ping turn yellow or red when they get bad
- Choose what the watermark shows: Watermark FPS, Watermark Ping, Watermark Clock (Visuals > Overlays)
- New Keybind List: real rows with a dot and a key cap, a header that counts what is on, and it grows to fit long names
- Only Active Keybinds: the list only shows the features that are on

## v5.23.5
- The loader now always gets the newest version straight after a release (it could give the previous one for a few minutes)

## v5.23.4
- ESP preview: no longer zoomed in - it zooms out until your whole avatar fits (hair, crowns, tails), with the box around the body like in the game
- ESP preview: a label you drag follows the pointer again

## v5.23.3
- ESP preview: the box now fits your avatar the way it does in the game (hats, wings and floating effects no longer shrink the avatar)
- ESP preview: the skeleton follows your avatar's own body instead of a fixed stick figure
- ESP preview: labels on the left or right are no longer cut off - the box makes room for them

## v5.23.2
- More clean-up: changing animation packs no longer leaves old animations loaded
- Browsing the emote Library for a long time no longer keeps growing memory
- Turning X-Ray or Performance Mode off, and turning the Loud Sound Limiter on, no longer hitch on big maps
- Invisible recovers by itself if it fails in a game (the toggle used to stay stuck)

## v5.23.1
- Big clean-up for long sessions: less memory used over time and less work every frame
- ESP is lighter in full servers (skeleton, boxes and labels only update what changed)
- X-Ray, Remove Invisible Walls and Performance Mode always put the map back, and no longer freeze big maps when switched
- Emotes keep working after hundreds of plays in one life; My Emotes and the Library are smoother with big collections
- Fixed: Chat Spam or the Jerk Tool could keep running after turning them off or reloading
- Fixed: Anti-Void could get stuck putting you back every frame on low maps
- Fixed: turning Invisible off right after on could lose your character
- Fixed: failed rejoins / server hops made the menu start several times in the next server
- Fixed: the profile card now says when someone isn't your friend; chams no longer stay on far-away NPCs

## v5.23
- Walk to a saved spot: a Walk button next to Go in Saved Teleports (finds its way around walls; WASD stops it)
- World: sky presets, Exposure, Ambient Light, Remove Shadows and a Personal Light only you can see
- World: Click to Delete Parts on your screen, with Undo and Restore
- Camera: Camera Through Walls, force first or third person, Freecam to Target
- Rejoin Where You Stood, and Fly / Noclip now carry the vehicle you're sitting in
- Loud Sound Limiter, mute one player's sounds, Low FPS / Ping Alerts and Streamer Mode
- Fixed: Fullbright and Clear Weather Effects stopped with an error in games with an Atmosphere

## v5.22
- Radar (Visuals): a small map of the players around you that turns with your camera; friends in green, names optional
- Crosshair (Visuals): cross, T-shape or dot with your own colour, length, gap, thickness, outline, centre dot and spin
- Active Features List: everything that's on, shown in the top-right corner while you play
- Radar and the list can be dragged anywhere and remember their spot

## v5.21
- New Follow Player (Players tab): walks after the selected player, finds a way around walls and stops a few studs away
- Follow Distance slider (3-15 studs); walk yourself with WASD at any time, click another player to switch
- The old teleporting Auto Follow in Trolling is gone

## v5.20.3
- The Understanding logo now shows next to the name (on executors that support custom images)

## v5.20.2
- ESP labels above a player sit a little higher, clear of their head
- Labels in the ESP preview sit right next to the box on every side

## v5.20.1
- ESP preview lines up with the menu (same top and height)
- Dragging a label in the preview now stays under your cursor
- Dropdowns, colour pickers and the notification log open exactly next to their button

## v5.20
- New player ESP: box (full or corners), name, distance, held item, health bar and number, skeleton, head dot
- Tracers from the bottom, middle, top or your mouse; arrows for players off screen; NPC ESP
- Visible Check colours players by whether a wall is in the way; text background and size
- ESP preview next to the menu on the Visuals tab, on your own avatar: drag a label to move it

## v5.19
- New compact layout: sections sit side by side in two columns, each a card with its title inside
- Checkboxes instead of switches; colour swatches and keybinds sit on the feature's own row
- Slimmer sliders, dropdowns and text boxes, and a wider window

## v5.18
- Object ESP (Visuals): see doors, chests, shops, dropped tools or anything by name through walls
- Air Walk (Myself): walk on an invisible floor in mid-air; jump to go up, hold Ctrl to go down
- Chat Log (Players): scroll back, search and copy public chat; optional alert when someone says your name
- Music player (Home): play sounds only you hear, with 8 tracks from Roblox's library and a saved list
- Fixed: Tracers can be turned on without another ESP being on

## v5.17
- Full remake: rounded floating panels, line icons in the sidebar and header
- Drag the window from any empty space, and scale it from any corner
- New notifications: icon, timer bar, hover to pause, click to dismiss
- Smoother motion (switch off in Appearance → Reduce Motion)

## v5.16
- New look: cleaner, darker design with each section grouped into one card
- Sidebar without emoji, grouped into Player, Style, World and Menu
- Slimmer switches and sliders, key caps for keybinds, quieter title bar and active bar

## v5.15.1
- Dragging the bottom-right corner now scales the whole menu (same as Menu Scale), and it's remembered
- Removed the feature counts on the tabs and the red dots (the tooltip warning stays)

## v5.15
- Click a section title to fold it; options that don't apply yet stay hidden until they do
- Bar along the bottom shows what's on (click to turn off), and each tab shows how many
- Tab icons, a Compact Sidebar option, and drag the bottom-right corner to resize the window
- Colour pickers for chams, name ESP and tracers; dropdowns for notification corner and emote sort
- Notification history (bell in the title bar), Background Blur, red dot on risky features

## v5.14
- New Animations tab: 18 Roblox animation packs; right-click a pack to mix and match parts
- New Servers tab: rejoin, previous server, server browser and a new Smallest-server hop
- Join / leave alerts (Players), optionally friends only
- Field of View and X-Ray (Visuals), Gravity (World), Hip Height (Myself)
- Anti-Void and Respawn Where You Died (Myself)

## v5.13
- Much lighter: the 60,000-emote list loads ~7x faster and uses ~100 MB less memory
- Emote search and the Library react instantly (no more freezes while typing)
- Less work every frame: labels only redraw when they change, sliders share one listener
- Fixed a slow leak when changing Home favourites

## v5.12.3
- Server location says 'not available on this executor' instead of a technical message when it can't be looked up

## v5.12.2
- Server location: retries Roblox's security check, and says exactly why when it can't find the server

## v5.12.1
- Server location: also reads the address from the client's own join log, so it works without Roblox login access

## v5.12
- Home: the server card shows where the server is (city, region, country) when your executor allows the lookup

## v5.11.2
- Hide Purchase Prompts now closes the window (like pressing its X), so no dark screen or frozen controls

## v5.11.1
- Hide Purchase Prompts now also hides Roblox's new 'Buy Robux and item' window

## v5.11
- Library now only shows emotes that aren't in a folder yet (Unfiled)
- Hide Purchase Prompts (World): no more 'buy this' pop-ups
- Remove Invisible Walls (World): walk through invisible barriers; floors stay solid

## v5.10
- Emote folders: My Emotes view with Favourites, Dances, Sitting & Poses, Greetings, plus your own
- Right-click an emote to put it in any folders; the star still adds to Favourites in one click
- Rename a folder by clicking its name; open/close it by clicking the header
- Tidier Emotes tab: My Emotes / Library switch, page controls under the list

## v5.9.1
- Fixed: emotes didn't play with Keep Emote While Moving on (and stopped when walking with it off)

## v5.9
- Emotes keep playing when you walk (new 'Keep Emote While Moving' option, on by default)
- Emotes tab reorganised: one list with filters (All, Favourites, Keybinds, Recent) and sorting
- Search emotes by name or ID; Random button; Now Playing bar with Stop
- Emote Speed slider

## v5.8
- Home tab: right-click any toggle, button or slider and choose Add to Home
- Home also shows this server: players, uptime, a ping graph, copy server ID or join link
- Players tab: distance and team on every row, sort by distance, profile card for the selected player
- Notification settings (Appearance): corner, how long they stay, mute info messages

## v5.7
- Spectate works in more games: switches to a backup camera if the game blocks the normal one
- Quick toggle: type in the title-bar search and press Enter to switch the top match
- Performance Mode and an FPS cap (World)
- Ctrl+Click Teleport (Myself)
- Update notice only appears when the menu itself changed

## v5.6
- Freecam (Visuals): fly the camera around while your character stays put
- Waypoints (World): see your saved spots in the world with distance
- Auto-load per game: the Auto button cycles Off / All games / This game
- Error log: feature errors are saved; copy them from Settings for bug reports

## v5.5
- Panic key (Settings): one key turns every feature off at once
- Keybinds can be 'hold': right-click a toggle, set Mode to Hold
- Keybind List shows all your binds; the ones that are on are highlighted
- Light theme (Appearance)
- Colour picker and watermark drag work with touch

## v5.4
- Share configs: 'Copy Config to Clipboard' and a paste box in Settings
- Auto-load: mark a config 'Auto' and it loads every time the menu starts
- This 'What's new' card after each update
- Update notice: reload a newer version without leaving the server
- Saved teleports: rename, sort by name or newest, export / import

## v5.3
- ESP options: distance, team colours, hide teammates, max distance
