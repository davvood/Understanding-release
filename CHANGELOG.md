# Changelog

## v5.35.5
- Aim-Assist Step-by-Step Geometric Smoothing: Replaced the steep power-law drop-off with a smooth geometric progression (0.85 ^ (smooth - 1), ~15% gentler per step) across both mousemoverel and Camera.CFrame tracking so Smoothness 5 feels responsive and every step from 1 to 20 scales evenly without stalling at high values

## v5.35.4
- Aim-Assist Zero Flick-Back Fix: Locked-mouse cameras (1st-person / shift-lock / TPS) now turn smoothly via native mousemoverel with sub-pixel fractional accumulation so the game's own camera angles update and never snap back when you release the Aim Key (retains the Camera.CFrame fallback for unlocked cursors or executors without mousemoverel)

## v5.35.3
- Aim-Assist True Progressive Smoothing & Mouse Control: Removed the 0.05 per-frame clamp floor and switched to a smooth power curve (24 / (smooth - 1)^1.35, default Smoothness 5) so every step from 2 to 20 feels distinctly gentler; preserved user mouse movement on every frame in both standard and custom-camera games instead of locking out camera control

## v5.35.2
- Aim-Assist Smoothed Locking Fix: Tracks a persistent smoothed look direction across frames so Smoothness > 1 smoothly locks on and follows even in games whose camera scripts reset Camera.CFrame every frame, bound at RenderPriority.Last (default Smoothness 3)
- Keybind List Integration: Aim-Assist now appears in the Keybind List while enabled (showing MB2 · hold, MB2, or Always) and lights up immediately while holding the active key, toggled on, or Always On (including with Only Active Keybinds)
- Sticky Target & Wall Check: Sticky Target keeps lock while the target remains on screen or in the look cone and re-checks walls immediately without cache lag

## v5.35.1
- Dedicated Aim Tab: Moved Aim-Assist and Aim Overlays out of Visuals into their own COMBAT → Aim tab, with Aim-Assist clearly labelled on its toggle row and cleanly shown in the Active Features bar
- Aim-Assist Tracking & Input Fixes: Runs on BindToRenderStep after Roblox's CameraModule (Camera + 1) so camera movement is never overwritten, allows MouseButton2 even when GameProcessedEvent is set (ADS/camera orbit), polls held key/mouse state directly, adds Always On mode, and uses a much snappier smoothing curve (default 4)

## v5.35
- Universal Aim-Assist (Visuals): Smooth client-side camera tracking that works in both first and third person, with Hold/Toggle activation, rebindable Aim Key (defaults to MB2 / right mouse button, supports MB2–MB5 and keyboard keys), Aim Smoothness, Max Distance, Target Part (Head / Torso / Closest), and optional Velocity Prediction
- Smart Filters & PvE Support: Team Check, Wall Visibility raycast check, Alive Check, Sticky Target (1.5x FOV hysteresis), and Include NPCs / Mobs toggle
- FOV Circle, Target HUD & Hit Sound (Visuals → Aim Overlays): Customisable FOV Circle overlay, draggable macOS-style Target HUD pill showing locked target name, health bar, and distance, plus optional Hit Sound feedback on target HP drop

## v5.34.3
- Worker-Gated Delivery & Blacklist Support: Menu downloads now go through the verification server with real-time blacklist enforcement and faster update checks

## v5.34.2
- Discord Verification & Invite Update: Updated the Discord invite link, added live Discord server membership verification to the loader (with Copy Invite and Check Again buttons), and refined Earmuff Mode descriptions

## v5.34.1
- Character Fly Controls: Removed Q and E vertical movement bindings from Fly so those keys stay free for in-game interactions (Space/LeftShift and camera look still move up and down)

## v5.34
- Earmuff Mode (World → Sound): Added a resizable 3D hearing circle around your character that mutes or lowers voices and game audio outside the circle (Earmuff Radius 4–120 st, Show Earmuff Circle, custom Earmuff Circle Color, Outside Volume 0%–100%, Mute Game Audio Outside, and optional Mute Global Music)
- Voice Chat & Audio Engine: Gates both legacy Roblox Voice Chat (VoiceChatInternal, preserving players you manually muted) and modern Audio API voices (AudioDeviceInput), plus 3D positional Sound/AudioPlayer sources with edge hysteresis, Loud Sound Limiter coordination, and full automatic restoration on toggle-off or unload

## v5.33.3
- Card Divider & Layout Fixes: Fixed Appearance accent swatch row clipping and divider alignment across Home (What's New), Animations, Automations, and Players, with a defensive layout guard so row dividers never collide with child layouts or padding
- Scaling, Dropdown & Modal Polish: Fixed dropdown checkmark overlap, Menu Scale label width math and slider value overlap, modal card button ordering and Escape priority, and row spacing across Teleports, Appearance, Emotes, and Overlays
- Light Theme Contrast & Reliability: Fixed Notification Center empty bell contrast in Light themes, gave the ESP Preview a dark stage with font-aware label sizing, fixed Fly respawn persistence, added MB4/MB5 isrbxactive capture self-healing, and kept Active Features chips synced with material changes

## v5.33.2
- Stability & Leak Hardening: Hardened unload teardown to clear all active registries, listeners, blur effects, and pending async tasks cleanly without post-unload errors or connection/instance leaks
- Loops & UI Performance: Converted idle background polling loops across ESP, Visuals, World, Players, Vehicle, Emotes, Wardrobe, Automations, Overlays, and MB4/MB5 tracking into on-demand event-driven hooks, debounced layout and Notification Center updates, and fixed camera/viewport resize handling
- Gameplay, Visuals & Config Bug Fixes: Fixed state restoration across World shadows/sounds, Visuals zoom/Freecam/X-Ray, Character JumpPower/Noclip/Godmode/Anti-Fling, Vehicle hooks, Players Spectate, Appearance HSV picker and startup save churn, Home IPv4 validation, and Config reset/autoload reliability
- Luau Headroom, Loader & Updater Reliability: Reclaimed Luau local variable headroom across the main chunk and tab modules, hardened HTTP 2xx validation and What's New overflow scrolling with fallback cooldowns, and tightened navigation and spring animation edge cases

## v5.33.1
- Update Check & Loader Reliability: Added commits/main.atom and raw header fallbacks plus HTTP StatusCode validation so Check for Updates and loader SHA pinning keep working even when api.github.com returns 403 rate limit exceeded

## v5.33
- macOS Shell & Appearance Overhaul: Moved window Traffic Lights to the top-left of the sidebar, grouped tabs under collapsible macOS sidebar headers, streamlined the Dynamic Island, added a toggleable Bottom Quick Dock, and rebuilt Appearance with a Live macOS Preview, 5 theme presets (macOS Dark/Light, Midnight, Graphite, Nord Slate), 3 window materials (Solid, Frosted, Liquid Glass), 10 Apple system accent swatches + gradient HSV sliders + #HEX input, and 10 macOS-inspired 3-weight UI fonts defaulting to SF Pro
- Inside-Tab Layout & Reorganization: Fixed 50% orphan columns and hidden empty section headers, upgraded sliders/inputs/dropdowns/context menus, renamed Myself to Character, moved Give Jerk Tool to Trolling and Gravity + Remove Invisible Walls to World, added progressive showWhen disclosure across Visuals/World/Vehicle/Players/Automations, and polished Home, Players, Teleports, Emotes, Animations, Wardrobe, and Settings/Servers
- Mouse 4 & 5 Side Buttons: Normalized numeric/boolean executor iskeypressed and isrbxactive checks, added self-healing window-focus recovery so faulty isrbxactive implementations cannot block MB4/MB5 polling, reconciled input/poll state, made key alias parsing case-insensitive, and ensured failed captures cancel cleanly on hide, tab switch, or unload

## v5.32.10
- Native iOS Remake: Rebuilt the menu as a crisp iPadOS split view with distinct iOS Dark & Light palettes, collapsible Large Titles, grouped inset cards with hairline dividers, tactile iOS switches and bounded sliders, an OLED Dynamic Island, a floating bottom tab bar, iOS banner notifications, and clean popover menus
- Motion & Reliability: Replaced legacy tweens with a unified spring motion engine (Api.Spring), pooled overlay rows to avoid frame rebuilds, and fixed slider/overlay drag focus-loss, popup cleanup on hide, Light Theme contrast, and accent recolouring edge cases
- Loader: Rebuilt the startup loader as a native iOS sheet with an app icon badge, capsule progress bar, readable multi-line errors, faster offline fallback, and clean blur handoff

## v5.32.9
- Mac Glass Unification: Replaced multiple glass material presets with one unified translucent macOS frosted glass system across a seamless window shell, airy frosted section cards, and smoked floating popovers
- Mac Layout & Controls: Moved Search to the top-left of content header, centered a compact Dynamic Island with quick Command Palette & Notification Center icons above clean unobstructed Traffic Lights, upgraded dropdown lists with right-side checkmarks, refined the Profile Popover with active footer glow, and updated the bottom Dock to circular frosted icon orbs

## v5.32.8
- Notifications: Remade toast cards in liquidDX11 glass (rounded app icon tile, category header, spring entrance, capsule timer bar) plus a Notification Center popover with All/Alerts filter, unread bell badge, and per-item dismiss
- Overlays: Rebuilt Watermark and Speedometer as frosted glass HUD capsules with brand badges, translucent dividers, and live status dots; rebuilt Keybind List and Active Features List as cascading glass cards with 3D keycaps
- Lists: Upgraded dropdown menus, Player List, Profile Card, Chat Log, Teleports, Wardrobe, Automations, Configs, Server Browser, Font Picker, Emotes, and Home cards with frosted list wells, rim lighting, and smooth hover/selection wash

## v5.32.7
- Menu: Complete liquidDX11 Liquid Glass UI remake with frosted blur panels, diagonal specular rim highlights, and 5 glass material presets (Subtle, Default, Frost, Vivid, Deep) in Appearance
- Chrome: Top-center Dynamic Island (expands on hover with latency & command hint), macOS Traffic Light window controls, sliding liquid-glass sidebar selection pill, bottom magnifying macOS dock, glass profile popover, and Ctrl+K Command Palette
- Widgets: Spring-animated pill switches with liquid velocity stretch, bouncy knob sliders, and click-ripple glass buttons

## v5.32.6
- Menu: Higher-resolution (512x512) sidebar logo with a refreshed cache download
- Keybinds: Mouse 3 (middle click), Mouse 4, and Mouse 5 (side mouse buttons) can now be bound everywhere as MB3, MB4, and MB5 (including Hold/Toggle modes, Menu Toggle/Panic keys, Teleports, Vehicle Jump, Automations, Keybind List, and saved configs)

## v5.32.5
- Settings: Reverted the Server Browser back to the v5.32.1 behavior

## v5.32.4
- Settings: Server Browser now detects reserved/matchmade games whose main place is a 1-player launcher (like FLATS) instead of showing fake 1/1 servers, and Server Hop re-enters matchmaking via the main place

## v5.32.3
- Settings: Server Browser now falls back to Asc / limit=50 / full-included queries and the game's root PlaceId (for sub-places) so it stops falsely saying 'No other servers found' when servers are listed on the website

## v5.32.2
- Settings: Server Browser now fetches 1 page at a time to stay under Roblox's 3-requests/min limit and caches the server list on disk (Understanding_servers.json) so reloads and rate limits keep your server list usable

## v5.32.1
- Players: Spectate now works across the whole map like Freecam even when a player's character is streamed out, and no longer turns off or snaps back in games that reset the camera every half second

## v5.32
- Visuals: dragging Name, Distance, Weapon or the Health bar in the ESP Preview now follows your mouse live instead of jumping when you let go
- Menu: smoother animations and transitions, a one-click clear button in the search bar, and faster tab switching
- Performance: faster ESP, Radar and Overlays with less frame work when many players or objects are on screen
- Reliability: cleaner reset of movement, camera, vehicle and character settings when you respawn or unload the menu

## v5.31.2
- Vehicle: Cruise Control and Autopilot hold their speed across vehicles with wheel motors, movers, nested car models, and scripts that brake on RenderStepped / Stepped
- Vehicle: Cruise Control remembers the speed you had before letting go of W to click the toggle, and has full power in cars that brake hard by themselves
- Vehicle: Autopilot keeps its speed through gentle turns and skips route waypoints that have fallen behind the car
- Vehicle: the Status box shows how hard the game slows the car while Cruise Control or Autopilot drives

## v5.31.1
- Vehicle: Cruise Control really holds your speed now, uphill and downhill, also in cars that brake by themselves when you let go
- Vehicle: Autopilot works without a destination: it drives around, keeps to the road it is on and takes a turning now and then
- Vehicle: the Status box shows the speed Cruise Control holds and what Autopilot is doing

## v5.31
- New Wardrobe tab: save the avatars you like and try them on (only you see it)
- Save a player's outfit from the Players tab, or anyone's by username
- Buy opens Roblox's own avatar window for a saved outfit; Links copies the items' catalog links
- Try Catalog Item puts one item or bundle on top of what you wear, from its ID or link

## v5.30
- Vehicle: Cruise Control holds your speed; braking switches it off
- Vehicle: Auto Dodge steers into the nearest gap when a car or wall is in the way, with a slider for how close it cuts
- Vehicle: Autopilot drives to a saved place, or to anything in the Teleports list (the Walk button reads Drive while you sit in a car)
- Vehicle: Flying Car - the car hovers, E goes up and Q down
- Vehicle: Drive on Water and Wall Driving

## v5.29
- New Automations tab: build your own rules, 'when this happens, do that'
- When: health drops below a percent, an item or NPC appears, a player joins, you respawn, a key, a timer, the menu starts, you sit in a vehicle
- Then: switch a feature on or off, teleport to a saved place, go back, load a config, show a notification
- Each rule can be for this game or every game, has a wait time, and is kept between sessions
- The panic key pauses your rules, so nothing switches back on by itself

## v5.28.1
- Teleports: an item you picked up no longer stays in the list (tools in a backpack or in someone's hand, switched-off prompts)
- Teleports: a row whose thing is gone leaves the list within a couple of seconds

## v5.28
- New Teleports tab: your saved places, NPCs and items in one list you can search and filter
- Go teleports you there, Walk goes on foot; same-named NPCs and items are one row that goes to the nearest
- Items are dropped tools and things you can use or click; the search also finds any object by name
- Back to Where I Was returns you to the spot before your last teleport
- Right-click a saved place (or the back button) to give it a key
- Saved Teleports moved here from the World tab: your saved places are kept

## v5.27.1
- Home: a What's New section shows what changed in the newest versions, with a button for the older ones

## v5.27
- Vehicle: Drift - the car slides through corners; give it a hold key for a handbrake-style drift button
- Drift sliders: how long it slides, how fast it swings round, the widest angle, and power to keep the slide going

## v5.26.1
- Update notice: the check can no longer be answered with an old, saved reply, so a new version is noticed within 5 minutes
- Settings > Script: Check for Updates looks for a new version right away

## v5.26
- New Vehicle tab: works on any car, boat or kart you drive yourself
- Speed Boost with top speed and acceleration, Nitro (give it a hold key) and Instant Brake
- Turn Assist, Extra Grip, Downforce, Air Control, Anti-Flip and a Flip Vehicle button
- Vehicle Jump on its own key (H until you change it), jump height, air jumps and vehicle gravity
- Speedometer you can drag anywhere, in studs per second, km/h or mph

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
