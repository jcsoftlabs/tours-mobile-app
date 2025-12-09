import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('privacy.title'.tr()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'privacy.section1.title'.tr(),
              content: 'privacy.section1.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section2.title'.tr(),
              content: 'privacy.section2.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section3.title'.tr(),
              content: 'privacy.section3.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section4.title'.tr(),
              content: 'privacy.section4.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section5.title'.tr(),
              content: 'privacy.section5.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section6.title'.tr(),
              content: 'privacy.section6.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section7.title'.tr(),
              content: 'privacy.section7.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section8.title'.tr(),
              content: 'privacy.section8.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section9.title'.tr(),
              content: 'privacy.section9.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section10.title'.tr(),
              content: 'privacy.section10.content'.tr(),
            ),
            _buildSection(
              context,
              title: 'privacy.section11.title'.tr(),
              content: 'privacy.section11.content'.tr(),
            ),
            _buildContactSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'privacy.section12.title'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              children: [
                TextSpan(text: 'privacy.section12.content'.tr()),
                const TextSpan(text: '\n\n📩 '),
                TextSpan(
                  text: 'mdt@tourisme.gov.ht',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchEmail('mdt@tourisme.gov.ht');
                    },
                ),
                TextSpan(text: '\n${'privacy.section12.address'.tr()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
