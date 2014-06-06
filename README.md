# Omafon
This is document describes the web part of Omafon.
Omafon itself is a dedicated video messenger similar to Skype or Facetime.
The other part is a Raspberry Pi that is hooked up to a touchscreen and a camera and automatically boots a webbrowser that then loads the `Home screen`.

## Screens
### Home screen
The initial screen of Omafon displays all your contacts.
Clicking on a contact will call it, that's it.
Probably the contacts need a status indicator (last seen) and maybe a clock showing current local time (for the time difference).
Additionally it needs to show notifications about missed calls and voicemails.

### Call screen
Ideally full screen.
The call is initiated, it is ringing on the callee's end.
After `n` rings there is the possibility to record a visual voicemail.
Once the call is established, the caller's image is smaller and embedded into the larger callee's image.
Also needs a duration indicator, a hangup button and volume control.

## Proof of concept
Especially on the Javascript end it seems unclear if everything is feasible.
Therefore I need to create 3 small applications that do the following:
### 1. Send videos
Basic example of two parties communicating. A sends video to B, B displays A's video and vice versa.
Also test if this works with actual devices over the internet, local network is not enough.

### 2. Record a video
Capture the output of the webcam, show the output on the webpage but also send it to a server.

### 3. Embed caller's video
Extension of example 1, but now B displays A's video and additionally B's video.
Ideally B's video overlays A's video.

