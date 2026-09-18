import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/planner_service.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../theme/stitch_theme.dart';

class ProfileView extends StatefulWidget {
  final Function(String themeMode)? onThemeChanged;

  const ProfileView({super.key, this.onThemeChanged});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileService _profileService = ProfileService();
  final PlannerService _plannerService = PlannerService();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final List<String> _avatarOptions = [
    '👩‍💼', '👨‍💼', '🚀', '🎯', '👑', '⚡', '🦉', '🦊', '🦁', '⭐'
  ];

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profileService.profile.name);
    final emailController = TextEditingController(text: _profileService.profile.email);
    String selectedAvatar = _profileService.profile.avatarEmoji;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: StitchColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: StitchColors.darkBorder),
              ),
              title: const Text(
                'Ubah Data Profil',
                style: TextStyle(color: StitchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Avatar / Foto Profil', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _avatarOptions.map((emoji) {
                        final isSelected = emoji == selectedAvatar;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedAvatar = emoji),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? StitchColors.tealGlowSubtle : StitchColors.darkCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? StitchColors.tealGlow : StitchColors.darkBorder,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nama Lengkap', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: StitchColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    const Text('Email', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: StitchColors.textPrimary),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: StitchColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.tealGlow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    _profileService.updateProfile(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      avatarEmoji: selectedAvatar,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Profil'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handlePasswordChange() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua field kata sandi')),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi baru minimal 6 karakter')),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok')),
      );
      return;
    }

    final success = await _profileService.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (!mounted) return;

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: StitchColors.greenSuccess,
          content: Text('Kata sandi berhasil diperbarui!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: StitchColors.redFailed,
          content: Text('Kata sandi saat ini salah. Silakan coba lagi.'),
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StitchColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: StitchColors.darkBorder),
          ),
          title: const Text('Keluar dari Akun?', style: TextStyle(color: StitchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari sesi ini? Semua rencana dan strategi Anda tetap tersimpan dengan aman.',
            style: TextStyle(color: StitchColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: StitchColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.redFailed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                AuthService().logout();
              },
              child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_profileService, _plannerService]),
      builder: (context, _) {
        final profile = _profileService.profile;
        final totalProjects = _plannerService.projects.length;
        final allNodes = _plannerService.projects.expand((p) => p.getAllNodes()).toList();
        final completedNodes = allNodes.where((n) => n.status == NodeStatus.completed).length;
        final fallbackNodes = allNodes.where((n) => n.status == NodeStatus.fallbackGlow).length;
        final completionRate = allNodes.isEmpty
            ? 89
            : ((completedNodes / allNodes.length) * 100).toInt();

        return Scaffold(
          backgroundColor: StitchColors.darkBackground,
          appBar: AppBar(
            backgroundColor: StitchColors.darkSurface,
            title: const Text(
              'Profil & Konfigurasi Pengguna',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StitchColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StitchColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: StitchColors.darkSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: StitchColors.tealGlow, width: 2),
                                ),
                                child: Center(
                                  child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 34)),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _showEditProfileDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: StitchColors.tealGlow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 12, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: const TextStyle(
                                    color: StitchColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.email,
                                  style: const TextStyle(color: StitchColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: StitchColors.tealGlowSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Strategist Lead • Pro Account',
                                    style: TextStyle(color: StitchColors.tealGlow, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: StitchColors.darkBorder, height: 1),
                      const SizedBox(height: 16),

                      // Metrics Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem('$totalProjects', 'Proyek Plan'),
                          _buildMetricItem('$completionRate%', 'Keberhasilan'),
                          _buildMetricItem('$fallbackNodes', 'Kontingensi Aktif'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Konfigurasi Alarm & Notifikasi
                const Text(
                  'Konfigurasi Alarm & Notifikasi',
                  style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      // H-1
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, color: StitchColors.tealGlow, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Pengingat H-1 Plan', style: TextStyle(color: StitchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('Waktu Peringatan: ${profile.defaultAlarmHMinus1Time}', style: const TextStyle(color: StitchColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: profile.defaultAlarmHMinus1,
                            activeColor: StitchColors.tealGlow,
                            onChanged: (val) => _profileService.updateAlarmSettings(defaultAlarmHMinus1: val),
                          ),
                        ],
                      ),
                      const Divider(color: StitchColors.darkBorder, height: 18),
                      // Hari-H
                      Row(
                        children: [
                          const Icon(Icons.alarm_on_rounded, color: StitchColors.indigoAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Pengingat Hari-H Plan', style: TextStyle(color: StitchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('Waktu Alarm: ${profile.defaultAlarmHariHTime}', style: const TextStyle(color: StitchColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: profile.defaultAlarmHariH,
                            activeColor: StitchColors.indigoAccent,
                            onChanged: (val) => _profileService.updateAlarmSettings(defaultAlarmHariH: val),
                          ),
                        ],
                      ),
                      const Divider(color: StitchColors.darkBorder, height: 18),
                      // Auto-switch Fallback Alert
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: StitchColors.tealGlow, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Auto-alert Switch Plan B', style: TextStyle(color: StitchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('Nyalakan opsi cadangan otomatis bila Plan A gagal', style: TextStyle(color: StitchColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: profile.autoAlertFallback,
                            activeColor: StitchColors.tealGlow,
                            onChanged: (val) => _profileService.updateAlarmSettings(autoAlertFallback: val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Akun & Keamanan (Ubah Kata Sandi)
                const Text(
                  'Akun & Keamanan',
                  style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kata Sandi Saat Ini', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        style: const TextStyle(color: StitchColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi saat ini',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: StitchColors.textMuted, size: 18),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Kata Sandi Baru (Minimal 6 Karakter)', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        style: const TextStyle(color: StitchColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi baru',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: StitchColors.textMuted, size: 18),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Konfirmasi Kata Sandi Baru', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: StitchColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: StitchColors.textMuted, size: 18),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StitchColors.tealGlow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _handlePasswordChange,
                          icon: const Icon(Icons.lock_reset_rounded, size: 18),
                          label: const Text('Simpan Kata Sandi', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Preferensi & Zona Waktu
                const Text(
                  'Preferensi & Zona Waktu',
                  style: TextStyle(color: StitchColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, color: StitchColors.tealGlow, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Tampilan Tema', style: TextStyle(color: StitchColors.textPrimary, fontSize: 14)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: StitchColors.darkSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: StitchColors.tealGlow.withOpacity(0.4)),
                            ),
                            child: const Text('Dark Carbon (Stitch)', style: TextStyle(color: StitchColors.tealGlow, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(color: StitchColors.darkBorder, height: 18),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, color: StitchColors.indigoAccent, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Zona Waktu Sistem', style: TextStyle(color: StitchColors.textPrimary, fontSize: 14)),
                          ),
                          Text(
                            profile.timezone,
                            style: const TextStyle(color: StitchColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Tombol Keluar dari Akun (Logout)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StitchColors.redFailed,
                      side: const BorderSide(color: StitchColors.redFailed, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: StitchColors.redFailedBg,
                    ),
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'BranchPlan v2.1 • Client ID SB1-KP-156',
                    style: TextStyle(color: StitchColors.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: StitchColors.tealGlow,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: StitchColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
