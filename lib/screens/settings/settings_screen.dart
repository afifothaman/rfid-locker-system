import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../languages/app_localizations.dart';
import '../../services/logout_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';
  bool notificationsEnabled = true;
  bool emailNotifications = true;
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Rapid',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: 'KL',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF87CEEB),
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: ' Settings',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader(localizations.appearance, Icons.palette),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSwitchTile(
                localizations.darkMode,
                localizations.darkModeDescription,
                Icons.dark_mode,
                themeProvider.isDarkMode,
                (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader(localizations.language, Icons.language),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildDropdownTile(
                localizations.language,
                localizations.selectLanguage,
                Icons.translate,
                languageProvider.currentLanguageName,
                ['English', 'Bahasa Melayu'],
                (value) async {
                  String languageCode = value == 'Bahasa Melayu' ? 'ms' : 'en';
                  await languageProvider.changeLanguage(languageCode);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.languageChanged),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(localizations.notifications, Icons.notifications),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildSwitchTile(
                localizations.enableNotifications,
                'Receive app notifications',
                Icons.notifications_active,
                notificationsEnabled,
                (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const Divider(),
              _buildSwitchTile(
                localizations.emailNotifications,
                'Receive notifications via email',
                Icons.email,
                emailNotifications,
                (value) {
                  setState(() {
                    emailNotifications = value;
                  });
                },
              ),
              const Divider(),
              _buildSwitchTile(
                localizations.pushNotifications,
                'Receive push notifications',
                Icons.push_pin,
                pushNotifications,
                (value) {
                  setState(() {
                    pushNotifications = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(localizations.account, Icons.person),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildActionTile(
                localizations.changePassword,
                'Update your account password',
                Icons.lock_outline,
                () => _showChangePasswordDialog(),
              ),
              const Divider(),
              _buildActionTile(
                localizations.editProfile,
                'Update your profile information',
                Icons.edit,
                () => Navigator.pushNamed(context, '/profile'),
              ),
            ]),
            const SizedBox(height: 24),

            // System Section
            _buildSectionHeader(localizations.system, Icons.settings),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _buildActionTile(
                localizations.privacyPolicy,
                'Read our privacy policy',
                Icons.privacy_tip_outlined,
                () => _showPrivacyPolicy(),
              ),
              const Divider(),
              _buildActionTile(
                localizations.termsOfService,
                'Read terms and conditions',
                Icons.description_outlined,
                () => _showTermsOfService(),
              ),
              const Divider(),
              _buildActionTile(
                localizations.aboutApp,
                'App version and information',
                Icons.info_outline,
                () => _showAboutDialog(),
              ),
            ]),
            const SizedBox(height: 24),

            // Logout Section
            _buildSettingsCard([
              _buildActionTile(
                localizations.logout,
                'Sign out of your account',
                Icons.logout,
                () => LogoutService.showLogoutDialog(context),
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_reset),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              final credential = EmailAuthProvider.credential(
                                email: user?.email ?? '',
                                password: oldPasswordController.text,
                              );
                              await user?.reauthenticateWithCredential(credential);
                              await user?.updatePassword(newPasswordController.text);
                              
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password updated successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message = 'Failed to update password';
                              if (e.code == 'wrong-password') {
                                message = 'Incorrect current password';
                              }
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'RapidKL Smart Locker System Privacy Policy\n\n'
            '1. Information Collection\n'
            'We collect information you provide when registering for our service, including name, email, IC number, and phone number.\n\n'
            '2. Information Use\n'
            'Your information is used to provide locker access services and system administration.\n\n'
            '3. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '4. Contact\n'
            'For privacy concerns, contact our admin team.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'RapidKL Smart Locker System Terms of Service\n\n'
            '1. Service Usage\n'
            'This system is for authorized RapidKL personnel and approved users only.\n\n'
            '2. User Responsibilities\n'
            'Users must keep their RFID cards secure and report any issues immediately.\n\n'
            '3. System Access\n'
            'Access is granted based on admin approval and valid RFID registration.\n\n'
            '4. Prohibited Activities\n'
            'Unauthorized access attempts and system misuse are strictly prohibited.\n\n'
            '5. Service Availability\n'
            'We strive to maintain system availability but cannot guarantee 100% uptime.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'RapidKL Smart Locker',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              const Color(0xFF3182CE),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.train,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('Smart Locker System for RapidKL'),
        const SizedBox(height: 8),
        const Text('Developed for secure locker access management'),
        const SizedBox(height: 8),
        const Text('© 2024 RapidKL. All rights reserved.'),
      ],
    );
  }


}