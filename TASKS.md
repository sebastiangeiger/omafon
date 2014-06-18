# Tasks
## 1. Sign up a user and store his credentials in a database
Don't need a screen for the sign up right now.

* [√] This entails project creation and 2 feature tests for positive / negative sign in.
* [√] Sign in testing however is done through websockets.
* [√] On successful sign in an authtoken is issued.
* [√] With the help of an auth token you can access a "secret"

## 2. Sign in lets user appear on contact list
* [√] Send all signed in users a message that someone logged on
* [√] Don't send that message to the user that just logged on
* [√] Send the newly signed in user a message with the statuses of all other users
* [√] Test this through websockets
* [√] Make sure the auth token is only sent to the user that logs in (there's an addressing problem in the system)

## 3. Rudimentary frontend
* [ ] Read the contacts from a yml file on startup
* [ ] Login page that signs you in or shows error message
* [ ] List contacts by email addresses once you're logged in

## 4. Closing the websocket connection signs you out
* [ ] More unit tests, better separation of internals (framework) and app logic


## 5. Users can only see each other when they have a friendship


## 6. Persist state to DB
