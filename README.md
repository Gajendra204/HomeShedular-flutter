# HomeScheduler - Appliance Management App

A Flutter application for managing household appliances, tracking warranties, and scheduling maintenance.

## Features

- **Authentication System**

  - Secure login and registration
  - Token-based authentication
  - Persistent sessions

- **Appliance Management**

  - Add new appliances with details:
    - Name
    - Purchase date
    - Warranty expiry date
    - Maintenance interval
  - View appliances in list or calendar view
  - Track warranty status with visual indicators
  - Monitor maintenance schedules

- **Smart Organization**

  - Filter appliances by status:
    - All appliances
    - Expired warranties
    - Needs maintenance
  - Search functionality for quick access
  - Visual progress indicators for warranty duration

- **Calendar Integration**

  - View important dates in calendar format
  - Track purchase dates, expiry dates, and maintenance schedules
  - Color-coded events for different types of reminders

- **User Interface**
  - Clean, modern Material Design
  - Dark/Light mode toggle
  - Responsive layout
  - Intuitive navigation

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- MongoDB (for backend)
- Node.js (for backend)

### Installation

1. Clone the repository:

```bash
git clone [repository-url]
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure backend:

- Set up MongoDB database
- Update API endpoints in lib/services/auth_service.dart
- Start backend server

4. Run the application:

```bash
flutter run
```

## Backend API Configuration

The application requires a running backend server. Update the API base URL in:

- lib/services/auth_service.dart
- lib/AuthenticationPages/homescreen.dart
- lib/AuthenticationPages/AddAppliancePage.dart

## Project Structure

- `lib/`
  - `main.dart` - Application entry point
  - `AuthenticationPages/` - Authentication and main screens
  - `providers/` - State management
  - `services/` - API services

## Tech Stack

- **Frontend**

  - Flutter
  - Provider (State Management)
  - table_calendar
  - http package for API calls
  - flutter_secure_storage

- **Backend**
  - Node.js
  - MongoDB
  - JWT Authentication

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request


## Acknowledgments

- Flutter Team
- Material Design
- Contributors

## Contact

Gajendra Sharma - [Gajendrasharma0145@gmail.com]

Project Link: [[repository-url](https://github.com/Gajendra204/HomeShedular-flutter.git)]
