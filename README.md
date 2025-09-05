# 🎓 Student Feedback App

A modern Flutter application for managing student feedback with beautiful UI and Firebase backend.



## ✨ Features

### 🔐 Authentication
- Firebase Authentication
- Role-based access (Student/Admin)
- Demo credentials for testing

### 👨‍🎓 Student Features
- Submit feedback with rich text
- View feedback history
- Profile management
- Real-time updates

### 👨‍💼 Admin Features
- Dashboard with analytics
- User management
- Feedback review & response
- Advanced reports
- Settings configuration

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.8.1+
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Auth**: Firebase Auth
- **State Management**: Provider
- **Animations**: Flutter Animate, Lottie

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.8.1+
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mr-ahmad161/Feedback-App.git
   cd Feedback-App/app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create Firebase project
   - Enable Authentication & Firestore
   - Add `google-services.json` to `android/app/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@university.edu` | `admin123` |
| Student | `student@university.edu` | `student123` |

## 📁 Project Structure

```
app/lib/
├── main.dart                 # App entry point
├── splash_screen.dart        # Splash screen
├── login_page.dart           # Authentication
├── models/                   # Data models
├── services/                 # Firebase services
├── viewmodels/              # State management
└── views/
    ├── admin/               # Admin screens
    └── student/             # Student screens
```

## 📱 Build APK

```bash
cd app
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👤 Author

**Ahmad** - [GitHub](https://github.com/mr-ahmad161)

---

⭐ Star this repository if you find it helpful!"# student-feedback-app" 
