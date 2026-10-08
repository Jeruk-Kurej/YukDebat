# YukDebat

An iOS app for the competitive debate community. Debaters find sparring partners, generate practice motions, share case-building notes for feedback from adjudicators, and follow upcoming competitions.

Built by a team of four as a university project (May – June 2026).

## Features

- **Sparring lobby:** create and join public or private rooms with limited slots, updated in real time.
- **Motion generator:** debate motions from the Google Gemini API, with a fallback list when the request fails.
- **Case notes and evaluation:** write notes, set their visibility, and request feedback from approved adjudicators.
- **Competitions:** browse upcoming debate competitions.
- **Admin moderation:** approve adjudicator requests and competitions, and moderate public notes.

## Stack

Swift, SwiftUI (MVVM), Firebase Auth, Cloud Firestore, Google Gemini API, Cloudinary.

## Running it

1. Open `YukDebat.xcodeproj` in Xcode.
2. Add your own `GoogleService-Info.plist` to the `YukDebat` folder.
3. Provide your own Gemini and Cloudinary credentials.
4. Run on an iPhone or iPad simulator.

## Team

Bryan Carlie Lukito Setiawan and three teammates. My part: the sparring rooms, the motion generator, the adjudicator evaluation form, and the admin moderation screens.
