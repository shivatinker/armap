# armap
Simple ARMap for INT20H contest

**Tested on iPhone 8**

Description:
Simple two-panelled AR app. You can see two parts on initial screen:
- Top AR part with compass markers and target marker (when you will set up one)
- Bottom map part, that acts like a radar, continuously following user's location and bearing angle

To add a target tap on map view and select location in opened window, then go back, you should see your target's location in AR and location on radar map.
You can change radar's zoom with slider on AR part, and move the line between views by dragging, so adjusting the map size.

## Installation:
- Clone repo
- Run `pod install` in root directory
- Open `Resources/config.plist` file, and change `YOUR_API_KEY` string to your Google API Key, with Google Maps app linked to account. (If you have troubles, contact me in Telegram: `@shivatinker`)
- Open and Build/Run project using `ARMap.xcworkspace` file
