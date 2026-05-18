# MediFlow Web Dashboard

A companion web dashboard for the MediFlow Flutter app. Built with plain PHP, HTML, CSS, and JavaScript.

## Features

- **Dashboard**: Overview of medication adherence, today's schedule, quick stats
- **Medicines**: View and manage all medications
- **History**: Track medication intake over time with filters
- **Health**: Monitor 13 health metrics with trend charts
- **Design**: Matches the Flutter app's "Space Meets Healthcare" theme

## Tech Stack

- **Backend**: Plain PHP
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Charts**: Chart.js
- **Database**: Firebase Firestore (via REST API)
- **Session**: PHP native sessions

## Project Structure

```
mediflow-web/
├── config/
│   ├── database.php     # Firebase & app config
│   └── functions.php   # Helper functions
├── services/
│   ├── AuthService.php   # Authentication service
│   └── FirebaseService.php # Firestore REST API client
├── public/
│   ├── index.php       # Main entry point
│   ├── css/
│   │   └── style.css   # MediFlow theme styles
│   └── js/
│       ├── api.js      # API service
│       ├── charts.js   # Chart.js configs
│       └── app.js      # Main app logic
├── views/
│   ├── layouts/
│   │   └── main.php    # Main layout
│   ├── auth/
│   │   └── login.php   # Login page
│   ├── dashboard/
│   │   └── index.php   # Dashboard view
│   ├── medicines/
│   │   └── index.php   # Medicines view
│   ├── history/
│   │   └── index.php   # History view
│   └── health/
│       └── index.php   # Health metrics view
├── .env                # Environment variables
├── index.php           # Entry point redirect
└── README.md
```

## Setup Instructions

### 1. Prerequisites

- A web server (Apache, Nginx, or PHP built-in server)
- PHP 7.4 or higher
- A Firebase project (for Firestore connection)

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select a project
3. Enable Firestore Database
4. Get your Firebase config from Project Settings
5. Update the `.env` file with your Firebase credentials

### 3. Configuration

Edit `.env` file:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_APP_ID=your-app-id
```

### 4. Running the App

#### Option A: PHP Built-in Server (Recommended for development)

```bash
cd mediflow-web
php -S localhost:8000
```

Then open: http://localhost:8000

#### Option B: Apache/Nginx

Configure your web server to point to the `mediflow-web` directory.

### 5. Demo Credentials

The app includes demo credentials for testing:
- **Email**: demo@mediflow.app
- **Password**: demo123

## Firebase Firestore Structure

The app expects the following Firestore collections:

```
/caregivers/{uid}/
├── medicines/{medicineId}
├── reminders/{reminderId}
├── history/{historyId}

/linkedPatients/{patientId}
```

## API Integration

The PHP backend connects to Firebase Firestore via REST API:

- `GET /caregivers/{uid}/medicines` - List medicines
- `GET /caregivers/{uid}/history` - List history
- `GET /caregivers/{uid}/reminders` - List reminders
- `GET /linkedPatients/{uid}` - Get linked patient

## Customization

### Changing Colors

Edit CSS variables in `public/css/style.css`:
```css
:root {
    --primary: #00E5FF;
    --bg-primary: #08090F;
    --bg-card: #0D1520;
}
```

### Adding New Pages

1. Create view in `views/{page}/index.php`
2. Add route in `public/index.php`
3. Add nav link in `views/layouts/main.php`

## Troubleshooting

### "Firebase not connected" error
- Check your `.env` configuration
- Ensure Firestore is enabled in Firebase Console
- Check browser console for CORS errors

### Session issues
- Ensure PHP session is working
- Check that cookies are enabled

### Styles not loading
- Check that CSS paths are correct
- Ensure the `public` folder is accessible

## Future Enhancements

- [ ] MySQL database sync with Flutter SQLite
- [ ] User registration
- [ ] Medicine CRUD operations
- [ ] Real-time updates with Firebase listeners
- [ ] Mobile-responsive improvements
- [ ] Export functionality

## License

MIT License - Feel free to use and modify!

## Support

For issues or questions, please open an issue on the GitHub repository.