# FoodFlow Pro - Enterprise Edition

Bienvenue dans le dépôt de **FoodFlow Pro**. Ce projet est une plateforme de livraison de repas performante et résiliente, développée avec Flutter pour les applications mobiles, et Firebase (Cloud Functions 2nd Gen) pour le backend.

Ce document est conçu pour aider tout développeur à comprendre l'architecture du projet et à l'installer localement.

---

## 🏗 Architecture du Projet

Le projet est divisé en plusieurs composants principaux formant un monorepo :

1. **`apps/customer`** : L'application mobile Flutter destinée aux clients (recherche de plats, commandes, suivi en temps réel).
2. **`apps/courier`** : L'application mobile Flutter pour les livreurs (gestion des courses, GPS, validation des livraisons).
3. **`backend/functions`** : L'API et la logique serveur développées en Node.js (TypeScript) avec Firebase Cloud Functions.
4. **`web/`** : Les interfaces web destinées à la gestion (ex: `admin-panel` et `restaurant-dashboard`).

### Technologies Clés

- **Frontend / Mobile** : Flutter, Riverpod (Gestion d'état).
- **Backend** : Firebase Cloud Functions, TypeScript.
- **Base de Données** : Cloud Firestore.
- **Stockage Local (Mobile)** : Isar (approche Offline-First).
- **Analytique & Cartographie** : Google Maps, algorithmes de distribution intelligente.

---

## 🚀 Prérequis Système

Pour compiler et exécuter ce projet localement, vous devez avoir installé :

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version >= 3.0.0)
- [Node.js](https://nodejs.org/) (version 18 recommandée pour Firebase)
- [Firebase CLI](https://firebase.google.com/docs/cli) (Installé globalement via `npm install -g firebase-tools`)
- **Android Studio** (pour l'émulation Android) ou **Xcode** (pour le simulateur iOS sous macOS)

---

## 🛠 Installation & Lancement en local

### 1. Configuration initiale

Clonez le dépôt sur votre machine locale :

```bash
git clone <URL_DU_DEPOT>
cd Uber-eats
```

Connectez-vous à Firebase avec votre compte développeur :

```bash
firebase login
```

### 2. Démarrer le Backend (Local Emulators)

Le projet utilise les émulateurs Firebase pour fonctionner localement sans impacter la base de données de production.

```bash
# Se placer dans le dossier des fonctions Cloud
cd backend/functions

# Installer les dépendances Node
npm install

# Compiler le code TypeScript et lancer les émulateurs Firebase
npm run serve
```

> Les émulateurs Firebase, y compris Firestore et les Cloud Functions, fonctionneront en local (généralement sur localhost:4000 par défaut). **Laissez ce terminal ouvert**.

### 3. Lancer l'application Customer (Client)

Dans un nouveau terminal :

```bash
# Se placer dans le dossier de l'app client
cd apps/customer

# Installer les paquets Flutter
flutter pub get

# Lancer l'application sur un émulateur ouvert (ou périphérique connecté)
flutter run
```

### 4. Lancer l'application Courier (Livreur)

Dans un troisième terminal :

```bash
# Se placer dans le dossier de l'app livreur
cd apps/courier

# Installer les paquets Flutter
flutter pub get

# Lancer l'application sur un autre émulateur (ou périphérique)
flutter run
```

---

## 📚 Documentation Supplémentaire

Des documents d'architecture plus complets se trouvent dans le dossier `docs/` :

- [C4 Architecture Blueprint](docs/ARCHITECTURE_C4.md)
- [Modèle de données & Schémas Firestore](docs/DATABASE_SCHEMA.md)

---

## 🤝 Contribution & Bonnes pratiques

- Exécutez régulièrement la commande `flutter clean` si vous rencontrez des problèmes de compilations Android après une mise à jour des paquets (notamment liés au `MultiDex` ou `Cloud Firestore`).
- Assurez-vous d'avoir toujours la dernière version de dépendances en appelant `flutter pub get`.
- Vérifiez la syntaxe et les erreurs avec `flutter analyze` avant tout commit.
