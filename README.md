# Boltcard NFC Programming App

Quickly program a blank NFC card (NTAG424DNA) to act as your own personal Boltcard. A contactless / paywave like experience for the Lightning network. Before programming your NFC card you must set up your own [boltcard server](https://github.com/boltcard/boltcard).

The boltcard can be used with Lightning PoS terminals that have NFC support, or Breez wallet PoS App.

Find out more at [boltcard.org](https://boltcard.org)

# [Card programming errors](card-programming-errors.md)

## NFC Card Support

-   NXP NTAG424 DNA
-   NXP NTAG424 DNA TT (Tag Tamper) Thanks to [Bassim](https://github.com/bassim)

## Quick Install

Download the compiled APK from the [latest release](https://github.com/boltcard/bolt-nfc-android-app/releases) and install on your android phone.

Download from the [Google Play store](https://play.google.com/store/apps/details?id=com.lightningnfcapp&hl=en&gl=US)

## Get started

1. Install dependencies

    ```bash
    npm install
    ```

2. Start the app

    ```bash
    npx expo start
    ```

In the output, you'll find options to open the app in a

-   [development build](https://docs.expo.dev/develop/development-builds/introduction/)
-   [Android emulator](https://docs.expo.dev/workflow/android-studio-emulator/)
-   [iOS simulator](https://docs.expo.dev/workflow/ios-simulator/)
-   [Expo Go](https://expo.dev/go), a limited sandbox for trying out app development with Expo

## Usage

1. Install [boltcard server](https://github.com/boltcard/boltcard) and aquire some blank NTAG424DNA tags.
2. When app has loaded go to the write screen and put your lnurlw domain and path in to the text box.
3. When finished tap a card on the NFC scanner to write the card.
4. Go to the read screen and check that your URL looks correct. Should also be outputting the PICC and CMAC as URL paramters
5. To change your keys (to prevent malicious re-writing of your card) Go to the boltcard server terminal and run the command to show the card key change URL in QR code form and then scan this with the phone camera to load the server keys.
6. When the keys are loaded, Hold the NFC card to the phone to run the key change on the card. Do not move the card until the key change has completed.
   Warning! If you lose the new keys then you will be unable to reprogram the card again

## Wiping cards

To wipe a card get the keys into a json in the following format:

```
{
	"version": 1,
	"action": "wipe",
	"k0": "11111111111111111111111111111111",
	"k1": "22222222222222222222222222222222",
	"k2": "33333333333333333333333333333333",
	"k3": "44444444444444444444444444444444",
	"k4": "55555555555555555555555555555555"
}
```

Go to the advanced > key reset screen and either paste this json from the clipboard or scan a QR code with this JSON encoded in it.
Then press "reset card now" and tap and hold your card against the NFC reader.

## UID Privacy

As of 0.1.4 the app now supports card UID Randomisation (irreversable). If you add the "uid_privacy" field and set its value to "Y" the card will be programmed to have a random UID. Any other value or ommission of this field will leave the card UID as-is. Please note this action is irreversable.

```
{
    "protocol_name": "new_bolt_card_response",
    "protocol_version":1,
    "card_name": "Spending_Card",
    "lnurlw_base": "lnurlw://your.domain.com/ln",
    "uid_privacy": "Y",
    "k0":"11111111111111111111111111111111",
    "k1":"22222222222222222222222222222222",
    "k2":"33333333333333333333333333333333",
    "k3":"44444444444444444444444444444444",
    "k4":"55555555555555555555555555555555"
}
```

# Dependencies / Security considerations

React native & Expo libraries are used to make building the UI easier.

Keep all your keys secret, and be careful when creating your cards that there are no other potential listening devices in range.

# Mock server for Testing
[https://bolt-card-mock-server.vercel.app/](https://bolt-card-mock-server.vercel.app/)
