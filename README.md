# 📱 Eat In Loc Polines - Real-Time Canteen Ordering System

> Final Project (UAS) - Mobile Programming Course

A real-time food ordering and kitchen queue management application developed for the "Kantin Kodok" canteen at Politeknik Negeri Semarang (POLINES). This project focuses on high-performance mobile state management and seamless cloud database integration using Flutter and Supabase.

---

## 🎨 UI/UX Design
Explore the full design system, wireframes, and interactive prototypes here:
👉 [Eat In Loc - Figma Design System](https://www.figma.com/design/MQcVQfrRmXDdZozhbrbTJX/tugas-besar-mobile?node-id=0-1&t=dZnXyOmnnlSmghGL-1)

---

## 🚀 Key Features

* **Real-Time Queue Management**: Implements a reactive Singleton State Management pattern to ensure synchronized order tracking between student devices and the kitchen admin panel without network latency.
* **Interactive Spatials & Routing**: Features an integrated `FlutterMap` powered by OpenStreetMap, calibrated with precise campus coordinates to provide students with accurate spatial guidance.
* **Digital Transaction Sandbox**: Includes an interactive QRIS digital payment simulation modal to provide a modern and secure user checkout experience.
* **Role-Based Access Control (RBAC)**: Secure authentication system utilizing Supabase Auth, dynamically segregating application permissions for `Mahasiswa` (Customers) and `Admin Dapur` (Kitchen Merchants).

---

## 🏗️ System Architecture

The application follows a modular architecture designed to minimize cloud request overhead:

* **Presentation Layer**: Flutter Mobile Framework (UI/UX).
* **Sync Layer**: Local Singleton State (Real-time data stream for orders).
* **Storage Layer**: Supabase Cloud Database (User Auth, Profile Management, and Menu Catalog).

---

## 🛠️ Requirements & Installation

Ensure you have the Flutter SDK and Git installed on your system.

1. **Clone the repository**:
   
```bash
   git clone [https://github.com/rynaid/flutter-RPL-Jobsheet.git](https://github.com/rynaid/flutter-RPL-Jobsheet.git)
   cd flutter-RPL-Jobsheet/eat_in_loc-main
