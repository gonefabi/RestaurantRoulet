# Restaurant Roulette

A Flutter app that picks a restaurant for you via a spinning wheel — search nearby, filter by cuisine, spin, navigate via Google Maps.

## Setup

1. **Flutter SDK** ≥ 3.2.0 (`flutter --version`).
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Provide build-time secrets.** Copy the template and fill in your own values:
   ```sh
   cp .env.example.json .env.json
   ```
   The four required keys are:
   - `SUPABASE_URL` and `SUPABASE_ANON_KEY` — from your Supabase project settings (anon/public).
   - `GEOAPIFY_KEY` — free tier key from [geoapify.com](https://www.geoapify.com/).
   - `GOOGLE_WEB_CLIENT_ID` — Web Client ID from Google Cloud Console (used as `serverClientId` for Google Sign-In).

   `.env.json` is gitignored. **Never commit real keys.**

## Run

```sh
flutter run --dart-define-from-file=.env.json
```

If a key is missing, the app fails fast at startup with a `StateError` listing the missing values (see `lib/core/config/env.dart`).

For one-off invocations without a file, pass each value individually:
```sh
flutter run \
  --dart-define=SUPABASE_URL=https://… \
  --dart-define=SUPABASE_ANON_KEY=… \
  --dart-define=GEOAPIFY_KEY=… \
  --dart-define=GOOGLE_WEB_CLIENT_ID=…
```

## Build

```sh
flutter build apk --dart-define-from-file=.env.json
flutter build ios --dart-define-from-file=.env.json
```

## Architecture

See [`docs/ARCHITECTURE_PLAN.md`](docs/ARCHITECTURE_PLAN.md) for the layered, feature-first layout used in `lib/`.
