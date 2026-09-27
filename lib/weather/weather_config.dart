// Google API key used for weather, Places autocomplete and Place details.
//
// The key is NOT stored in source control. It is injected at build time:
//   flutter run --dart-define-from-file=secrets.json
// where secrets.json (git-ignored) contains {"GOOGLE_API_KEY": "<your key>"}.
// See secrets.example.json and the README "Configuration" section.
const String kGoogleWeatherApiKey = String.fromEnvironment('GOOGLE_API_KEY');
const String kGooglePlacesApiKey = kGoogleWeatherApiKey;

/// True when a key was provided at build time.
const bool kHasGoogleApiKey = kGoogleWeatherApiKey != '';
