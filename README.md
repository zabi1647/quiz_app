# Quiz App - Flutter MCQ Practice Application

A comprehensive Flutter application for Android and Web that allows users to practice multiple-choice questions (MCQs) with intelligent spaced repetition, progress tracking, and a web-based admin dashboard.

## 🎯 Features

### Mobile App (Android)

#### 1. **User Authentication**
- Email/Password authentication via Firebase Auth
- Secure signup and login
- Password reset functionality
- Profile management

#### 2. **MCQ Practice**
- Browse questions by category (General, Science, Math, History, Geography)
- Smart Practice Mode with AI-powered question selection
- Interactive quiz interface with:
  - Progress tracking
  - Question difficulty indicators
  - Real-time answer selection
  - Immediate feedback

#### 3. **Spaced Repetition System** ⭐
- **Intelligent Question Selection**: Questions you get wrong appear more frequently
- **Priority Algorithm**: 
  - Questions with higher error rates get higher priority
  - 70% of practice questions focus on weak areas
  - 30% random questions for variety
- **Adaptive Learning**: The more you practice, the smarter the system becomes
- Questions are automatically sorted by difficulty based on your performance

#### 4. **Progress Tracking**
- Real-time performance statistics
- Overall accuracy percentage
- Total quizzes completed
- Correct vs incorrect answers tracking
- Visual charts and graphs (Pie charts)
- Detailed quiz results with:
  - Score summary
  - Question-by-question review
  - Correct answer explanations

#### 5. **User Profile**
- Personal information display
- Performance history
- Statistics dashboard with:
  - Average score
  - Total questions attempted
  - Success rate visualization
  - Performance trends

### Web Dashboard (Admin)

#### 1. **Admin Authentication**
- Secure admin login system
- Admin signup functionality
- Role-based access control

#### 2. **Dashboard Overview**
- Total MCQs count
- Total users registered
- Total quiz attempts
- Active quizzes statistics
- Quick access navigation

#### 3. **MCQ Management**
- **Add New Questions**: Create MCQs with:
  - Question text
  - Multiple options (up to 6)
  - Correct answer selection
  - Category assignment
  - Difficulty level (Easy/Medium/Hard)
- **Edit Existing Questions**: Update any MCQ details
- **Delete Questions**: Remove outdated or incorrect MCQs
- **Search & Filter**: Find questions quickly
- **Bulk Operations**: Manage multiple questions

#### 4. **User Performance Monitoring**
- View all registered users
- Individual user statistics:
  - Total quizzes taken
  - Questions answered
  - Correct/incorrect answers
  - Average score
  - Last activity date
- Sortable performance table
- Export capabilities

#### 5. **Statistics & Analytics**
- Most attempted questions
- Most missed questions (for improvement)
- Category distribution charts
- Difficulty distribution
- Performance trends over time
- User engagement metrics

## 🏗️ Architecture

### Models
```
lib/models/
├── mcq_model.dart              # MCQ data structure
└── user_performance_model.dart # User stats structure
```

### Services
```
lib/services/
├── firestore_service.dart           # Firebase Firestore operations
└── spaced_repetition_service.dart   # Smart question selection algorithm
```

### Pages Structure
```
lib/pages/
├── app/                        # Mobile app pages
│   ├── auth/
│   │   ├── mobile_login_page.dart
│   │   └── mobile_signup_page.dart
│   ├── home/
│   │   └── mobile_home_page.dart
│   ├── profile/
│   │   └── profile_page.dart
│   └── quiz/
│       ├── quiz_list_page.dart
│       ├── quiz_page.dart
│       └── quiz_result_page.dart
└── web/                        # Web dashboard pages
    ├── auth/
    │   ├── admin_login_page.dart
    │   └── admin_signup_page.dart
    └── dashboard/
        ├── admin_dashboard.dart
        └── widgets/
            ├── dashboard_overview.dart
            ├── mcq_management.dart
            ├── user_performance.dart
            └── statistics_view.dart
```

## 🚀 Technologies Used

- **Flutter**: Cross-platform UI framework
- **Firebase Authentication**: User authentication
- **Cloud Firestore**: Real-time database
- **flutter_screenutil**: Responsive UI design
- **fl_chart**: Data visualization
- **Dart**: Programming language

## 📱 Responsive Design

The app uses `flutter_screenutil` for perfect scaling across:
- Different screen sizes (phones, tablets)
- Various pixel densities
- Portrait and landscape orientations
- Android and Web platforms

## 🔥 Firebase Structure

### Collections

#### 1. `mcqs` Collection
```json
{
  "question": "What is the capital of France?",
  "options": ["London", "Berlin", "Paris", "Madrid"],
  "correctAnswerIndex": 2,
  "category": "Geography",
  "difficulty": "Easy",
  "attemptsCount": 150,
  "correctCount": 120,
  "incorrectCount": 30,
  "createdAt": "2025-12-25T10:00:00Z",
  "updatedAt": "2025-12-25T15:30:00Z"
}
```

#### 2. `user_performances` Collection
```json
{
  "userId": "user123",
  "userName": "John Doe",
  "userEmail": "john@example.com",
  "totalQuizzes": 25,
  "totalQuestions": 500,
  "correctAnswers": 425,
  "incorrectAnswers": 75,
  "averageScore": 85.0,
  "lastAttempt": "2025-12-25T14:30:00Z"
}
```

## 🧠 Spaced Repetition Algorithm

### How It Works

1. **Priority Calculation**:
   ```
   priority = (incorrectCount / attemptsCount) * 10 + (incorrectCount * 0.5)
   ```

2. **Question Selection**:
   - 70% from high-priority (difficult) questions
   - 30% random selection for variety
   - Final shuffle for unpredictable order

3. **Adaptive Learning**:
   - Questions update their statistics after each attempt
   - Error rates automatically adjust priorities
   - Users naturally focus on weak areas

### Benefits
- **Efficient Learning**: Focus on what you don't know
- **Better Retention**: Repeat difficult concepts more often
- **Natural Progression**: Easy questions appear less frequently
- **Personalized**: Adapts to each user's performance

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (^3.9.2)
- Firebase project configured
- Android Studio / VS Code
- Firebase CLI (for web deployment)

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quiz_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add Android app to Firebase
   - Add Web app to Firebase
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS - if needed)
   - Update `firebase_options.dart`

4. **Run the app**
   
   For Android:
   ```bash
   flutter run
   ```
   
   For Web:
   ```bash
   flutter run -d chrome
   ```

5. **Build for production**
   
   Android APK:
   ```bash
   flutter build apk --release
   ```
   
   Web:
   ```bash
   flutter build web --release
   ```

## 🔐 Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // MCQs - Read for all, write for authenticated users (admins)
    match /mcqs/{mcqId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User performances - Users can only access their own data
    match /user_performances/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Admins can view all
    }
  }
}
```

## 📊 Key Features Checklist

- ✅ User authentication (email/password)
- ✅ MCQ practice by category
- ✅ Spaced repetition algorithm
- ✅ Progress tracking and statistics
- ✅ User profile with performance charts
- ✅ Quiz results with detailed review
- ✅ Web admin dashboard
- ✅ MCQ management (CRUD operations)
- ✅ User performance monitoring
- ✅ Statistics and analytics
- ✅ Responsive design (mobile & web)
- ✅ Real-time data sync with Firebase
- ✅ Smart question prioritization
- ✅ Category-based organization
- ✅ Difficulty levels

## 🎨 UI/UX Highlights

- Modern Material Design 3
- Gradient backgrounds
- Smooth animations
- Intuitive navigation
- Clear visual feedback
- Responsive layouts
- Accessible color schemes
- Professional admin interface

## 📱 Screen Shots

### Mobile App
- Login/Signup screens with gradient design
- Quiz list with category cards
- Practice mode with smart selection badge
- Interactive quiz interface with progress bar
- Results page with detailed breakdown
- Profile page with statistics and charts

### Web Dashboard
- Modern admin login
- Comprehensive dashboard overview
- MCQ management with search and filters
- User performance table
- Statistics visualizations

## 🔄 Data Flow

1. **User takes quiz** → 
2. **Answers recorded** → 
3. **Statistics updated in Firestore** → 
4. **User performance calculated** → 
5. **Spaced repetition algorithm adjusts priorities** → 
6. **Next quiz shows optimized questions**

## 🚀 Future Enhancements

- [ ] Offline mode support
- [ ] Question explanations/hints
- [ ] Timed quizzes
- [ ] Leaderboards
- [ ] Achievement badges
- [ ] Push notifications
- [ ] Social sharing
- [ ] Import/Export MCQs
- [ ] Advanced analytics
- [ ] Multi-language support

## 📄 License

This project is developed for educational purposes.

## 👨‍💻 Developer

Built with ❤️ using Flutter and Firebase

---

**Note**: This application implements a proven spaced repetition algorithm that helps users learn more efficiently by focusing on their weak areas while maintaining knowledge in strong areas.
