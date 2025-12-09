# Gestion Sécurisée des Erreurs

## Vue d'ensemble

Cette application utilise un système centralisé de gestion des erreurs qui masque automatiquement les informations sensibles (comme les URLs du backend) et affiche des messages compréhensibles pour les utilisateurs.

## Architecture

### 1. ErrorHandler (`lib/core/network/error_handler.dart`)

Service central qui convertit les exceptions techniques en messages utilisateur-friendly :

```dart
// Convertir une erreur en message sécurisé
String message = ErrorHandler.getUserFriendlyMessage(error);

// Logger une erreur (pour le débogage uniquement)
ErrorHandler.logError(error, stackTrace: stackTrace, context: 'MyService');

// Vérifier si c'est une erreur réseau
bool isNetwork = ErrorHandler.isNetworkError(error);
```

### 2. UiHelpers (`lib/core/utils/ui_helpers.dart`)

Utilitaires pour afficher les erreurs dans l'interface :

```dart
// Afficher une erreur avec SnackBar
UiHelpers.showErrorSnackBar(context, error);

// Afficher une erreur avec Dialog
UiHelpers.showErrorDialog(context, error, title: 'Erreur');

// Afficher un succès
UiHelpers.showSuccessSnackBar(context, 'Opération réussie');
```

## Utilisation dans les Services

### Exemple : Service API

```dart
Future<List<Item>> fetchItems() async {
  try {
    final response = await _apiService.get('/api/items');
    return response.data.map((json) => Item.fromJson(json)).toList();
  } catch (e, stackTrace) {
    // Logger l'erreur technique (ne sera pas visible par l'utilisateur)
    ErrorHandler.logError(e, stackTrace: stackTrace, context: 'fetchItems');
    
    // Relancer l'erreur pour que l'UI puisse l'attraper
    rethrow;
  }
}
```

## Utilisation dans l'UI

### Avec FutureBuilder

```dart
FutureBuilder(
  future: _service.fetchData(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      // Afficher l'erreur de manière sécurisée
      return Center(
        child: Column(
          children: [
            Icon(Icons.error),
            Text(ErrorHandler.getUserFriendlyMessage(snapshot.error)),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    // ... reste du code
  },
)
```

### Avec try-catch

```dart
Future<void> _saveData() async {
  try {
    await _service.save(data);
    UiHelpers.showSuccessSnackBar(context, 'Données sauvegardées');
  } catch (e) {
    UiHelpers.showErrorSnackBar(context, e);
  }
}
```

## Messages d'Erreur

### Erreurs Réseau

Quand l'utilisateur n'a pas de connexion Internet :
- ❌ **Ancien** : `SocketException: Failed host lookup: 'https://discover-ht-production.up.railway.app'`
- ✅ **Nouveau** : `Impossible de se connecter à Internet. Vérifiez votre connexion et réessayez.`

### Timeout

Quand la requête prend trop de temps :
- ❌ **Ancien** : `DioException [connection timeout]: The connection has timed out`
- ✅ **Nouveau** : `La connexion a pris trop de temps. Veuillez réessayer.`

### Erreurs HTTP

- **400** : `Données invalides`
- **401** : `Session expirée. Veuillez vous reconnecter.`
- **403** : `Vous n'avez pas les permissions nécessaires`
- **404** : `Ressource introuvable`
- **429** : `Trop de tentatives. Veuillez patienter.`
- **500+** : `Le serveur rencontre des difficultés. Veuillez réessayer plus tard.`

## Bonnes Pratiques

### ✅ À FAIRE

1. **Toujours utiliser UiHelpers pour afficher les erreurs** :
   ```dart
   UiHelpers.showErrorSnackBar(context, error);
   ```

2. **Logger les erreurs techniques** :
   ```dart
   ErrorHandler.logError(error, stackTrace: stackTrace);
   ```

3. **Fournir un contexte** :
   ```dart
   ErrorHandler.getUserFriendlyMessage(error, context: 'Établissement');
   // Résultat: "Établissement introuvable"
   ```

### ❌ À ÉVITER

1. **Ne jamais afficher l'erreur brute** :
   ```dart
   // ❌ MAUVAIS
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(error.toString())),
   );
   ```

2. **Ne jamais exposer les URLs ou tokens** :
   ```dart
   // ❌ MAUVAIS
   Text('Erreur: ${error.message}')
   ```

3. **Ne jamais loguer les informations sensibles en production** :
   ```dart
   // ❌ MAUVAIS
   print('Token: $token'); // Les tokens ne doivent jamais être loggés
   ```

## Sécurité

Le système masque automatiquement :
- 🔒 URLs du backend
- 🔒 Tokens d'authentification
- 🔒 Détails techniques des stack traces
- 🔒 Noms d'hôtes et adresses IP

Seuls les messages génériques et compréhensibles sont affichés aux utilisateurs.

## Tests

Pour tester le système de gestion d'erreurs :

1. **Mode avion** : Activez le mode avion pour simuler une perte de connexion
2. **Timeout** : Testez avec une connexion très lente
3. **Erreurs serveur** : Testez avec un backend en maintenance

Dans tous les cas, l'utilisateur devrait voir des messages clairs sans aucune information technique sensible.
