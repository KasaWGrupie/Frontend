# Kasa w Grupie App

# Setting up firebase
## 1. Install Firebase CLI
First, install the Firebase CLI if you haven't already:
```sh
npm install -g firebase-tools
```
Then, log in to your Firebase account:
```sh
firebase login
```

## 2. Install FlutterFire CLI
Next, install the FlutterFire CLI:
```sh
dart pub global activate flutterfire_cli
```

## 3. Initialize Firebase in Your Flutter Project
Run the following command in the root of your Flutter project:
```sh
flutterfire configure
```
This will:
- Detect your Firebase project.
- Generate `google-services.json` for Android.
- Create a `firebase_options.dart` file.

