import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../screens/privacy_policy_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedLanguage = 'fr'; // fr, en, es

  @override
  void initState() {
    super.initState();
    // Le provider se charge automatiquement de l'initialisation
  }

  Future<void> _updateLanguage(String language) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isLoggedIn) return;
    
    try {
      await ref.read(authStateProvider.notifier).updateProfile(language: language);
      setState(() {
        _selectedLanguage = language;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.language.changed'.tr()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'common.error'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth.logout'.tr()),
        content: Text('profile.logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'auth.logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'common.error'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchEmail(String email, {String? subject, String? body}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    try {
      // Essayer d'ouvrir l'application email
      final bool canLaunch = await canLaunchUrl(emailUri);
      
      if (canLaunch) {
        await launchUrl(emailUri);
      } else {
        // Si pas de client email, afficher une boîte de dialogue avec les infos
        if (mounted) {
          _showEmailFallbackDialog(email, subject: subject, body: body);
        }
      }
    } catch (e) {
      // En cas d'erreur, afficher aussi la boîte de dialogue de fallback
      if (mounted) {
        _showEmailFallbackDialog(email, subject: subject, body: body);
      }
    }
  }

  void _showEmailFallbackDialog(String email, {String? subject, String? body}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactez-nous'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Impossible d\'ouvrir l\'application email. Vous pouvez nous contacter directement à :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SelectableText(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              if (subject != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Objet :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                SelectableText(subject),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.language.select'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('settings.language.french'.tr()),
              value: 'fr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: Text('settings.language.english'.tr()),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: Text('settings.language.spanish'.tr()),
              value: 'es',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final authState = ref.read(authStateProvider);
    if (!authState.isLoggedIn || authState.user == null) return;
    
    final nameController = TextEditingController(text: authState.user!.name);
    final phoneController = TextEditingController(text: authState.user!.phone);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('profile.edit_profile'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'profile.full_name'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'profile.phone'.tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(authStateProvider.notifier).updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('profile.updated'.tr()),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${'common.error'.tr()}: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    if (authState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('profile.title'.tr()),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.title'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (authState.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutDialog,
              tooltip: 'auth.logout'.tr(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section profil utilisateur
            _buildUserSection(),
            const SizedBox(height: 20),
            // Sections des paramètres
            _buildSettingsSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.user;
    
    if (!authState.isLoggedIn || currentUser == null) {
      return _buildGuestSection();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: currentUser.avatar != null
                ? NetworkImage(currentUser.avatar!)
                : null,
            child: currentUser.avatar == null
                ? Text(
                    currentUser.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            currentUser.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentUser.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit),
            label: Text('profile.edit_profile'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'profile.not_logged_in'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'profile.login_message'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/login');
            },
            icon: const Icon(Icons.login),
            label: Text('auth.login'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.isLoggedIn;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Section Compte
          if (isLoggedIn) ...[
            _buildSectionHeader('profile.my_account'.tr()),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('profile.personal_info'.tr()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showEditProfileDialog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: Text('profile.security'.tr()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implémenter la gestion du mot de passe
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('profile.coming_soon'.tr()),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Section Préférences
          _buildSectionHeader('profile.settings'.tr()),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('profile.language'.tr()),
                  subtitle: Text(_getLanguageLabel(context.locale.languageCode)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.push('/language-settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text('profile.notifications'.tr()),
                  trailing: Switch(
                    value: true, // TODO: Gérer les préférences de notification
                    onChanged: (value) {
                      // TODO: Implémenter la gestion des notifications
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text('settings.appearance.theme'.tr()),
                  subtitle: Text(
                    ref.watch(themeModeProvider) == ThemeMode.dark
                        ? 'settings.appearance.dark'.tr()
                        : 'settings.appearance.light'.tr(),
                  ),
                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Assistance
          _buildSectionHeader('profile.help'.tr()),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: Text('profile.send_feedback'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _launchEmail(
                      'mdt@tourisme.gov.ht',
                      subject: 'Commentaires sur l\'application Touris',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: Text('profile.contact_us'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _launchEmail('mdt@tourisme.gov.ht');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Légal
          _buildSectionHeader('profile.legal'.tr()),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text('profile.privacy'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('profile.about'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Touris',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.location_city,
                        size: 32,
                      ),
                      children: [
                        Text(
                          'app.slogan'.tr(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Déconnexion
          if (isLoggedIn) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'auth.logout'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: _showLogoutDialog,
              ),
            ),
            const SizedBox(height: 40),
          ] else
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageLabel(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }
}
