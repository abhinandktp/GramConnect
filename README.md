# Gram - Connect

## 1. Description
Gram - Connect is a comprehensive platform designed to empower local communities and tourists. It combines a social space for discovering local places with practical tools for civic engagement. The app directly addresses pressing issues such as illegal garbage dumping, food wastage, and low awareness of historical and cultural sites by providing a one-stop solution for community-driven initiatives and information.

---

## 2. Features

- **Village Tour:** A community-driven guide to historical and cultural places, complete with user ratings and reviews. Users can also post their own places.
- **Food Management:** Helps reduce food waste by allowing hotels and events to post surplus food. Users in need can then request it.
- **Waste Management:** An interactive map powered by OpenStreetMap that shows the location of public waste bins.
- **Complaint Management:** Allows users to report illegal waste dumping and other societal issues with photo proof. Other users can like or dislike complaints to show support.
- **Local Services:** A locator tool to find essential public services like post offices, village offices, panchayats, municipalities, corporations, and public toilets.

---

## 3. Tech Stack

- **Frontend:** Flutter
- **Database:** Firebase Real-Time Database
- **Mapping:** OpenStreetMap

---

## 4. Installation & Setup

1.  Clone the repository:
    ```bash
    git clone [https://github.com/abhinandktp/GramConnect.git]
    ```

2.  Navigate to the project directory:
    ```bash
    cd gram_connect
    ```

3.  Install dependencies:
    ```bash
    flutter pub get
    ```

4.  Configure Firebase:
    * Add your app to a Firebase project and download the configuration files.
    * Place `google-services.json` in the `android/app/` directory.
    * Place `GoogleService-Info.plist` in the `ios/Runner/` directory.

5.  Run the app:
    ```bash
    flutter run
    ```

---

## 5. Usage Screenshots

### Initial Pages & User Management
<div align="center">

| **Splash Screen** | **Login** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/d028d28c-40bf-4b3a-a60e-c1caa485edc8" alt="Splash Screen" width="200"> | <img src="https://github.com/user-attachments/assets/76243946-27f5-4b58-a055-7d2aad1e49a9" alt="Login Screen" width="200"> |

| **Registration** | **Home Screen** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/eff1b907-a547-4f5a-bbe4-0b3b74d92d67" alt="Registration Page" width="200"> | <img src="https://github.com/user-attachments/assets/af58b449-6883-44a3-8e81-d76fc22c6822" alt="Home Screen" width="200"> |

</div>

### Local Services
<div align="center">

| **Post Office** | **Village Office** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/5af5d9f0-87f4-4336-8a48-5027b223b2fb" alt="Post Office Locator" width="200"> | <img src="https://github.com/user-attachments/assets/ea038786-8eba-40e0-b6ae-55e111c15265" alt="Village Office Locator" width="200"> |

| **Municipality** | **Public Toilet** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/bc0c55d4-70ef-4df0-a3ac-0a702e4ca06e" alt="Municipality Locator" width="200"> | <img src="https://github.com/user-attachments/assets/672d6245-c8b9-4a81-9bb7-129c09e8a26f" alt="Public Toilet Locator" width="200"> |

</div>

### Food Management
<div align="center">

| **Add Food Post** | **Request Food** | **View Posts** |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/77b059d6-87ad-43b2-9f9f-49620af753f9" alt="Add Food Post" width="200"> | <img src="https://github.com/user-attachments/assets/5a06095a-c982-4964-b61d-a90566915eff" alt="Request Food" width="200"> | <img src="https://github.com/user-attachments/assets/ef680669-da24-4b0e-97af-c4373157769d" alt="View Food Posts" width="200"> |

</div>

### Waste Management
<div align="center">

| **Waste Management Menu** | **Waste Bin Locations** | **Waste Dumping Complaints** |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/2d55fbcb-3ba7-4abe-a601-1c0e9fc7a908" alt="Waste Management Menu" width="200"> | <img src="https://github.com/user-attachments/assets/e0a097d4-62ec-46e3-9c43-0caf4c9f196f" alt="Waste Bin Locations" width="200"> | <img src="https://github.com/user-attachments/assets/60d7e7de-7c5f-41d6-964d-59a2fbf38a73" alt="Waste Dumping Complaints" width="200"> |

</div>

### Village Tour
<div align="center">

| **Add Place** | **View Places** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/6f53a899-fe63-4057-ac19-f8b7d787f9c3" alt="Add a New Place" width="200"> | <img src="https://github.com/user-attachments/assets/4c555ca4-26ce-4079-bb55-8f480fa80db1" alt="View Places" width="200"> |

| **My Posts** | **Place Details** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/7b0046b7-5af8-4633-8162-36a31ed0f8c3" alt="My Posts" width="200"> | <img src="https://github.com/user-attachments/assets/63d3dbf0-0f57-4671-9629-acdbf944e661" alt="Place Details" width="200"> |

</div>

### Complaint Management
<div align="center">

| **View Complaints** | **Complaint Details** | **My Complaints** |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/b566c244-3b1c-49e4-aae7-05dca7bedd7e" alt="View Complaints" width="200"> | <img src="https://github.com/user-attachments/assets/5367dbb6-b8cd-4bff-b240-b7a1d893c073" alt="Add Complaints" width="200"> | <img src="https://github.com/user-attachments/assets/21facb8d-ab68-43e6-8de6-2afd3bfbdfb8" alt="View My Complaints" width="200"> |

</div>

---

## 6. Demo Link

You can download the application's **APK file** and watch a **demo video** with instructions on how to use it by clicking the link below.

[Download App & Watch Demo](https://drive.google.com/drive/folders/1tlIoAX8R8JwPOpUkLLQ4k5BEj_X0b_QW)

---

## 7. Contributors

* Anurag K
* Abin N M
* Abhinand K S

---

## 8. License
