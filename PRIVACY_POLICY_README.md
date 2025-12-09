# Page de Politique de Confidentialité - Documentation

## Fichiers créés

1. **`lib/screens/privacy_policy_screen.dart`** - La page complète de la politique de confidentialité
2. Traductions ajoutées dans :
   - `assets/lang/fr.json` (Français)
   - `assets/lang/en.json` (Anglais)
   - `assets/lang/es.json` (Espagnol)

## Comment naviguer vers cette page

### Option 1 : Navigation directe avec `Navigator`

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PrivacyPolicyScreen(),
  ),
);
```

### Option 2 : Avec `go_router` (si configuré)

Ajoutez la route dans votre configuration de routeur :

```dart
GoRoute(
  path: '/privacy-policy',
  builder: (context, state) => const PrivacyPolicyScreen(),
),
```

Puis naviguez :

```dart
context.go('/privacy-policy');
```

### Option 3 : Depuis le profil ou les paramètres

Dans votre écran de profil, ajoutez un `ListTile` :

```dart
ListTile(
  leading: const Icon(Icons.privacy_tip),
  title: Text('profile.privacy'.tr()),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  },
)
```

## Structure du contenu

La page contient 12 sections conformes au RGPD :

1. Qui sommes-nous ?
2. Données que nous collectons
3. Finalité de la collecte
4. Base légale du traitement
5. Durée de conservation
6. Partage des données
7. Cookies et outils d'analyse
8. Sécurité des données
9. Vos droits
10. Localisation et transfert des données
11. Consentement et modification
12. Contact (avec lien email cliquable)

## Fonctionnalités

- ✅ Support multilingue (Français, Anglais, Espagnol)
- ✅ Scrollable pour les petits écrans
- ✅ Lien email cliquable (mdt@tourisme.gov.ht)
- ✅ Mise en forme claire avec titres et sections
- ✅ Adapté au design Material

## Import nécessaire

Dans le fichier où vous voulez utiliser cette page, ajoutez :

```dart
import 'package:touris_app_mobile/screens/privacy_policy_screen.dart';
```

## Personnalisation

Pour modifier le contenu, éditez les fichiers de traduction dans `assets/lang/` :

- `fr.json` pour le français
- `en.json` pour l'anglais
- `es.json` pour l'espagnol

Les clés sont structurées comme suit :
```json
{
  "privacy": {
    "title": "...",
    "section1": {
      "title": "...",
      "content": "..."
    }
  }
}
```
