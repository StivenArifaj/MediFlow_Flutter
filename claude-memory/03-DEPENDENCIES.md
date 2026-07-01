# Dependency Decisions

## Android Package ID
- `com.mediflow.app` (changed from `com.example.mediflow` before Play Store submission)

## Firebase: FULLY REMOVED
- Deps (firebase_core, firebase_auth, cloud_firestore) removed in earlier session
- Last artifact: com.google.gms:google-services plugin removed from both android/build.gradle.kts files during package rename
- google-services.json still present on disk but no longer referenced by any build config

## To ADD
- supabase_flutter (replaces firebase_core, firebase_auth, cloud_firestore)
- google_sign_in (for Google OAuth)

## To REMOVE (confirmed unused — zero imports found in audit)
- flutter_timezone
- purchases_flutter (until premium is actually built)
- lottie
- image
- printing
- firebase_core, firebase_auth, cloud_firestore (after migration complete)

## To WIRE UP (installed but unused)
- flutter_secure_storage → session token storage
- http → OpenFDA barcode lookup

## Keep as-is
- flutter_riverpod, go_router, drift (drift may be removed entirely once 
  Supabase is the only data source — TBD after migration)
- google_mlkit_text_recognition, camera, image_picker, mobile_scanner (OCR/scan)
- flutter_local_notifications, timezone
- fl_chart, google_fonts, flutter_animate
- pdf, share_plus
- crypto, intl
