/* © **2024** [Rahul Babu M P](https://linktr.ee/rahulthewhitehat)
All Rights Reserved.
This file is part of the Elecxa project and contains proprietary and
confidential information. Unauthorized copying, distribution, or use
of this file, via any medium, is strictly prohibited.
Proprietary information should not be shared without prior written permission. */

# Elecxa

**Elecxa** is a multi-vendor electronics marketplace app designed to connect local electronics stores with customers in real-time. This app offers functionalities for both store owners and customers, enabling efficient product management, seamless communication, and convenient shopping.

## Features

### Customer Features
- **Browse Stores**: Search and explore nearby electronics stores with detailed information.
- **Browse Products**: Access products by category, with options to filter by type or store.
- **Request Products**: Submit a product request with urgency levels (*Immediately*, *Within 3 days*, *Within a week*).
- **Messaging**: Directly communicate with store owners to inquire about product details.
- **View Requests**: Monitor the status of product requests (*Accepted*, *Rejected*, or *Pending*) made to store owners.
- **Account Settings**: Manage profile, view order history, and securely log out.

### Store Owner Features
- **Manage Products**: Easily add, edit, and delete products, ensuring inventory remains updated.
- **Notifications**: Receive customer product requests with urgency and status options, and accept or reject requests as needed.
- **Messaging**: Engage directly with customers about product inquiries.
- **Dashboard Management**: Access a structured dashboard for managing products, notifications, and messages.
- **Settings**: Update profile information, manage account preferences, and securely log out.

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore (real-time database), Firebase Authentication, Firebase Cloud Messaging, Firebase Storage

## Setup and Installation

### Prerequisites
- **Flutter**: [Install Flutter SDK](https://flutter.dev/docs/get-started/install)
- **Firebase Account**: Set up a Firebase project on the [Firebase Console](https://console.firebase.google.com/)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/elecxa.git
   cd elecxa
    ```
2. **Install dependencies:**
    ```bash
    flutter pub get```
   
3. **Firebase Setup:**

- Create a Firebase project in the Firebase Console.
- Register your app (for Android and/or iOS).
- Download the google-services.json file for Android and place it in the android/app directory.
- Enable Firebase Authentication (email, Google) and Firestore Database in your Firebase project.

4. **Run App**:
    ```bash 
    flutter run```

This project, Elecxa, is proprietary software and may not be used, copied,
or distributed without permission. The software, including all accompanying
documentation, logos, and designs, are the intellectual property of [Rahul Babu M P](https://linktr.ee/rahulthewhitehat).
Unauthorized reproduction, modification, or distribution of this software, or any portion of it,
may result in legal consequences.
