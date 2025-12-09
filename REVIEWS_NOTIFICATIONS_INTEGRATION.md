# Système d'Avis et Notifications - Documentation d'Intégration

## 📋 Vue d'ensemble

Ce document décrit l'implémentation complète du système d'avis et de notifications dans l'application Touris.

## ✅ Fonctionnalités implémentées

### Backend (Node.js/Express)

#### 1. Modèle de données (Prisma)
- **Notification** : Système de notifications pour inviter les utilisateurs à laisser des avis
  - Types : REVIEW_INVITATION, PROMOTION, SYSTEM, OTHER
  - Statut : isRead, readAt
  - Relation avec establishments

#### 2. API Reviews
- `POST /api/reviews` - Créer un avis (authentification requise)
- `GET /api/reviews` - Récupérer les avis avec filtres
- `GET /api/reviews/:id` - Récupérer un avis spécifique
- `PUT /api/reviews/:id` - Modifier un avis
- `DELETE /api/reviews/:id` - Supprimer un avis
- `GET /api/reviews/establishment/:id/stats` - Statistiques d'avis (note moyenne, distribution)

#### 3. API Notifications
- `GET /api/notifications` - Liste des notifications de l'utilisateur
- `GET /api/notifications/:id` - Détails d'une notification
- `GET /api/notifications/unread/count` - Nombre de notifications non lues
- `POST /api/notifications/review-invitation` - Créer une invitation à laisser un avis
- `PATCH /api/notifications/:id/read` - Marquer comme lue
- `PATCH /api/notifications/mark-all-read` - Tout marquer comme lu
- `DELETE /api/notifications/:id` - Supprimer une notification

#### 4. Sécurité
- Authentification JWT requise pour créer des avis
- Le userId est extrait du token (pas envoyé dans le body)
- Validation des données (note entre 1 et 5)
- Vérification : un utilisateur ne peut laisser qu'un seul avis par établissement

### Mobile (Flutter)

#### 1. Modèles de données
- **`AppNotification`** : Modèle pour les notifications
- **`ReviewStats`** : Statistiques d'avis (moyenne, distribution, nombre total)
- Sérialisation JSON automatique avec `json_serializable`

#### 2. Services
- **`ReviewService`** : Gestion complète des avis
  - `createReview()` : Créer un avis
  - `getReviews()` : Récupérer les avis avec filtres
  - `getReviewStats()` : Obtenir les statistiques
  - `updateReview()` : Modifier un avis
  - `deleteReview()` : Supprimer un avis

- **`NotificationService`** : Gestion des notifications
  - `getNotifications()` : Récupérer les notifications
  - `getUnreadCount()` : Nombre de non lues
  - `markAsRead()` : Marquer comme lue
  - `markAllAsRead()` : Tout marquer comme lu
  - `deleteNotification()` : Supprimer

#### 3. State Management
- **`NotificationProvider`** : Provider pour gérer l'état des notifications
  - Gestion du compteur de notifications non lues
  - Mise à jour en temps réel
  - Gestion des erreurs

#### 4. Widgets
- **`ReviewCard`** : Affichage d'un avis
  - Avatar utilisateur
  - Note avec étoiles
  - Commentaire
  - Date formatée
  - Support des images

- **`ReviewStatsWidget`** : Statistiques détaillées
  - Note moyenne (grand nombre)
  - Étoiles
  - Distribution des notes (barres de progression)
  - Bouton "Laisser un avis"

- **`CompactReviewStats`** : Version compacte pour les listes

#### 5. Écrans
- **`AddReviewScreen`** : Formulaire pour laisser un avis
  - Sélection de la note (étoiles cliquables)
  - Champ de commentaire
  - Validation
  - Retour avec succès pour rafraîchir

- **`NotificationsScreen`** : Liste des notifications
  - Onglets : Non lues / Toutes
  - Badge de compteur
  - Pull-to-refresh
  - Swipe pour supprimer
  - Navigation vers l'établissement depuis une notification

- **`EstablishmentDetailScreen`** : Mis à jour
  - Affichage des statistiques d'avis
  - Liste des avis avec ReviewCard
  - Bouton pour ajouter un avis
  - Rechargement automatique après ajout d'avis

## 🚀 Utilisation

### Créer un avis (utilisateur authentifié)

```dart
final reviewService = ReviewService();

try {
  await reviewService.createReview(
    establishmentId: 'establishment_123',
    rating: 5,
    comment: 'Excellent établissement !',
  );
  // Avis créé avec succès
} catch (e) {
  // Gérer l'erreur (ex: utilisateur non connecté)
}
```

### Afficher les statistiques d'avis

```dart
final stats = await reviewService.getReviewStats('establishment_123');

// Utiliser dans un widget
ReviewStatsWidget(
  stats: stats,
  onTapWriteReview: () {
    // Ouvrir l'écran pour laisser un avis
  },
)
```

### Gérer les notifications avec Provider

```dart
// Dans votre app, ajouter le provider
ChangeNotifierProvider(
  create: (_) => NotificationProvider(),
  child: MyApp(),
)

// Dans un widget
Consumer<NotificationProvider>(
  builder: (context, provider, child) {
    return Badge(
      label: Text('${provider.unreadCount}'),
      child: IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsScreen(),
            ),
          );
        },
      ),
    );
  },
)
```

## 🔧 Configuration requise

### Backend

1. Base de données MySQL doit être mise à jour :
   ```bash
   cd listing-backend
   npx prisma db push
   ```

2. Générer le client Prisma :
   ```bash
   npx prisma generate
   ```

### Mobile

1. Générer les fichiers de sérialisation JSON :
   ```bash
   cd touris_app_mobile
   dart run build_runner build --delete-conflicting-outputs
   ```

2. Ajouter le NotificationProvider dans `main.dart` :
   ```dart
   MultiProvider(
     providers: [
       // ... autres providers
       ChangeNotifierProvider(create: (_) => NotificationProvider()),
     ],
     child: MyApp(),
   )
   ```

## 📱 Flux utilisateur

1. **Laisser un avis**
   - L'utilisateur visite un établissement
   - Clique sur "Laisser un avis" dans l'onglet Avis
   - Sélectionne une note (1-5 étoiles)
   - Écrit un commentaire
   - Soumet l'avis
   - Retour à la fiche de l'établissement avec rafraîchissement

2. **Recevoir une notification**
   - Le système crée une invitation après une visite
   - L'utilisateur voit le badge sur l'icône notifications
   - Ouvre les notifications
   - Clique sur une invitation
   - Est redirigé vers la fiche de l'établissement

3. **Consulter les avis**
   - L'utilisateur ouvre un établissement
   - Voit les statistiques (note moyenne, distribution)
   - Scroll pour voir les avis individuels
   - Peut cliquer sur "Laisser un avis"

## 🎨 Personnalisation

### Modifier l'apparence des étoiles
Éditez `review_card.dart` ou `review_stats.dart` :
```dart
Icon(
  Icons.star,
  color: Colors.amber, // Changez la couleur ici
  size: 20,
)
```

### Adapter les textes d'invitation
Éditez le backend dans `notificationsController.js` :
```javascript
title: `Donnez votre avis sur ${establishment.name}`,
message: `Vous avez récemment visité ${establishment.name}. Partagez votre expérience !`,
```

## 🐛 Dépannage

### Les avis ne s'affichent pas
- Vérifier que le backend est démarré et accessible
- Vérifier les logs : `debugPrint` dans review_service.dart
- Tester l'API avec curl ou Postman

### Erreur d'authentification lors de la création d'avis
- Vérifier que l'utilisateur est connecté
- Vérifier que le token JWT est valide
- Vérifier les headers Authorization dans api_service.dart

### Les notifications ne se mettent pas à jour
- Vérifier que NotificationProvider est bien déclaré
- Appeler `refreshUnreadCount()` après des actions
- Vérifier les logs réseau

## 📚 Ressources

- [Documentation Prisma](https://www.prisma.io/docs)
- [Flutter Provider](https://pub.dev/packages/provider)
- [JSON Serialization](https://flutter.dev/docs/development/data-and-backend/json)

## 🎯 Prochaines améliorations possibles

- [ ] Push notifications pour les invitations à laisser des avis
- [ ] Système de modération des avis (backend admin)
- [ ] Upload d'images dans les avis
- [ ] Réponses des établissements aux avis
- [ ] Filtres avancés (tri par note, date, etc.)
- [ ] Signalement d'avis inappropriés
- [ ] Badges pour utilisateurs actifs
- [ ] Statistiques avancées pour les établissements
