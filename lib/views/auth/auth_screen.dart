import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/stitch_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late AnimationController _bgBlobController;

  final AuthService _authService = AuthService();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _rememberMe = true;
  bool _isLoginLoading = false;
  String? _loginError;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  String _selectedAvatar = '👩‍💼';
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;
  bool _isRegLoading = false;
  String? _regError;

  // Interactive Demo Simulation State
  bool _demoPlanAFailed = true;

  final List<String> _avatarChoices = [
    '👩‍💼', '👨‍💼', '🚀', '🎯', '⚡', '👑', '🦉', '🦊', '🦁', '⭐'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bgBlobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _bgBlobController.dispose();
    _entranceController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    setState(() {
      _loginEmailController.text = 'sarah.wijaya@planner.id';
      _loginPasswordController.text = 'planner123';
      _loginError = null;
    });
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final pass = _loginPasswordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _loginError = 'Email dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _isLoginLoading = true;
      _loginError = null;
    });

    final result = await _authService.login(
      email: email,
      password: pass,
    );

    if (!mounted) return;
    setState(() => _isLoginLoading = false);

    if (!result.success) {
      setState(() => _loginError = result.message);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final pass = _regPasswordController.text.trim();
    final confirm = _regConfirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _regError = 'Silakan lengkapi semua data pendaftaran.');
      return;
    }

    if (pass != confirm) {
      setState(() => _regError = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() {
      _isRegLoading = true;
      _regError = null;
    });

    final result = await _authService.register(
      name: name,
      email: email,
      password: pass,
      avatarEmoji: _selectedAvatar,
    );

    if (!mounted) return;
    setState(() => _isRegLoading = false);

    if (!result.success) {
      setState(() => _regError = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    return Scaffold(
      backgroundColor: StitchColors.darkBackground,
      body: Stack(
        children: [
          // 1. Ambient Animated Glowing Background Blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgBlobController,
              builder: (context, _) {
                final t = _bgBlobController.value * 2 * math.pi;
                return CustomPaint(
                  painter: _AmbientGlowPainter(t),
                );
              },
            ),
          ),

          // 2. Notion-style Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _AuthGridBackgroundPainter(),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _entranceController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Interactive Animated Decision Forest Showcase
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: _buildShowcaseSection(),
                ),
              ),
              const SizedBox(width: 48),
              // Right: Auth Form Card
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: _buildAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShowcaseSection(compact: true),
              const SizedBox(height: 24),
              _buildAuthCard(),
              const SizedBox(height: 20),
              const Text(
                'BranchPlan • Notion-Style Contingency Engine',
                style: TextStyle(color: StitchColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SHOWCASE / ANIMATION SECTION ---
  Widget _buildShowcaseSection({bool compact = false}) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Brand Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: StitchColors.tealGlowSubtle,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StitchColors.tealGlow.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: StitchColors.tealGlow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: StitchColors.tealGlow.withOpacity(
                              0.4 + (_pulseController.value * 0.6)),
                          blurRadius: 8 * _pulseController.value,
                          spreadRadius: 2 * _pulseController.value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Decision Forest & Failover Engine',
                style: TextStyle(
                  color: StitchColors.tealGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Headline
        Text(
          'Perencanaan Ranting\nDengan Kontingensi Otomatis',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: StitchColors.textPrimary,
            fontSize: compact ? 22 : 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ketika Rencana A Gagal (OFF), sistem otomatis menyalakan Rencana B sebagai opsi cadangan dengan visual glow kontingensi.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: StitchColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Live Interactive Animation Canvas: Decision Tree Simulator
        _buildInteractiveTreeSimulator(compact: compact),

        if (!compact) ...[
          const SizedBox(height: 24),
          // Feature pills
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildFeatureBadge(Icons.account_tree_outlined, 'Pohon Ranting Tanpa Batas'),
              _buildFeatureBadge(Icons.flash_on_outlined, 'Failover Glow Otomatis'),
              _buildFeatureBadge(Icons.alarm_on_outlined, 'Alarm Pengingat H-1 & Hari H'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: StitchColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StitchColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: StitchColors.tealGlow),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: StitchColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTreeSimulator({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.darkCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StitchColors.tealGlow.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: StitchColors.tealGlow.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.touch_app_rounded, size: 14, color: StitchColors.tealGlow),
              const SizedBox(width: 6),
              const Text(
                'Simulasi Interaktif: Coba Klik Plan A',
                style: TextStyle(
                  color: StitchColors.tealGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: StitchColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _demoPlanAFailed ? 'Status: Failover ON' : 'Status: Normal',
                  style: TextStyle(
                    color: _demoPlanAFailed ? StitchColors.yellowWarning : StitchColors.greenSuccess,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Root Node
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: StitchColors.darkSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StitchColors.indigoAccent.withOpacity(0.7)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🚀', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Text(
                    'Peluncuran Produk Q3',
                    style: TextStyle(
                      color: StitchColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Connecting lines with glowing pulse
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(double.infinity, 36),
                painter: _BranchConnectorPainter(
                  pulse: _pulseController.value,
                  isPlanAFailed: _demoPlanAFailed,
                ),
              );
            },
          ),

          // Two Branches: Plan A and Plan B
          Row(
            children: [
              // Branch A: Clickable to toggle Fail / Active
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _demoPlanAFailed = !_demoPlanAFailed;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _demoPlanAFailed
                          ? StitchColors.redFailedBg
                          : StitchColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _demoPlanAFailed
                            ? StitchColors.redFailed
                            : StitchColors.darkBorderActive,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('🏢', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Plan A: Offline Expo',
                                style: TextStyle(
                                  color: StitchColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _demoPlanAFailed
                                ? StitchColors.redFailed.withOpacity(0.25)
                                : StitchColors.tealGlowSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _demoPlanAFailed ? 'GAGAL (OFF) ✖' : 'AKTIF ✔',
                            style: TextStyle(
                              color: _demoPlanAFailed
                                  ? StitchColors.redFailed
                                  : StitchColors.tealGlow,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Branch B: Fallback Node (Glows when Plan A fails)
              Expanded(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final isGlowing = _demoPlanAFailed;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isGlowing
                            ? const Color(0xFF003830)
                            : StitchColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isGlowing
                              ? StitchColors.tealGlow
                              : StitchColors.darkBorder,
                          width: isGlowing ? 1.8 : 1.0,
                        ),
                        boxShadow: isGlowing
                            ? [
                                BoxShadow(
                                  color: StitchColors.tealGlow.withOpacity(
                                      0.3 + (_pulseController.value * 0.4)),
                                  blurRadius: 16 * _pulseController.value + 4,
                                  spreadRadius: 1 + _pulseController.value * 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('📱', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Plan B: KOL & Live',
                                  style: TextStyle(
                                    color: StitchColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isGlowing
                                  ? StitchColors.tealGlow
                                  : StitchColors.darkSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isGlowing ? 'MENYALA (FALLBACK) 🔥' : 'STANDBY',
                              style: TextStyle(
                                color: isGlowing ? Colors.black : StitchColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- AUTH CARD SECTION ---
  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: StitchColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StitchColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StitchColors.darkSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: StitchColors.tealGlow.withOpacity(0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.account_tree_rounded,
                    size: 22,
                    color: StitchColors.tealGlow,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BranchPlan',
                      style: TextStyle(
                        color: StitchColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Masuk untuk kelola pohon rencana',
                      style: TextStyle(
                        color: StitchColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar (Masuk / Daftar)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: StitchColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StitchColors.darkBorder),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: StitchColors.tealGlow,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: StitchColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Masuk'),
                Tab(text: 'Daftar Akun'),
              ],
            ),
          ),

          // Tab Views
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                height: _tabController.index == 0 ? 370 : 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loginError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: StitchColors.redFailedBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: StitchColors.redFailed.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: StitchColors.redFailed, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _loginError!,
                    style: const TextStyle(color: StitchColors.redFailed, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Email
        const Text(
          'Email',
          style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'nama@domain.com',
            prefixIcon: Icon(Icons.alternate_email, size: 16, color: StitchColors.textMuted),
          ),
        ),

        const SizedBox(height: 12),

        // Kata Sandi
        const Text(
          'Kata Sandi',
          style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Masukkan kata sandi',
            prefixIcon: const Icon(Icons.lock_outline, size: 16, color: StitchColors.textMuted),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: StitchColors.textMuted,
                size: 16,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Remember Me & Demo Quick Fill
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: StitchColors.tealGlow,
                checkColor: Colors.black,
                onChanged: (val) => setState(() => _rememberMe = val ?? true),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Ingat Saya',
              style: TextStyle(color: StitchColors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            InkWell(
              onTap: _fillDemoAccount,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: StitchColors.tealGlowSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: StitchColors.tealGlow.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_fix_high, size: 12, color: StitchColors.tealGlow),
                    SizedBox(width: 4),
                    Text(
                      'Akun Demo (1-Klik)',
                      style: TextStyle(
                        color: StitchColors.tealGlow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const Spacer(),

        // Tombol Masuk
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchColors.tealGlow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoginLoading ? null : _handleLogin,
            child: _isLoginLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text(
                    'Masuk ke BranchPlan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_regError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: StitchColors.redFailedBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: StitchColors.redFailed.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: StitchColors.redFailed, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _regError!,
                    style: const TextStyle(color: StitchColors.redFailed, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Pilih Avatar
        const Text(
          'Pilih Avatar Profil',
          style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarChoices.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final emoji = _avatarChoices[index];
              final isSelected = emoji == _selectedAvatar;
              return InkWell(
                onTap: () => setState(() => _selectedAvatar = emoji),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? StitchColors.tealGlowSubtle : StitchColors.darkSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? StitchColors.tealGlow : StitchColors.darkBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Nama Lengkap
        const Text(
          'Nama Lengkap',
          style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _regNameController,
          style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Misal: Budi Santoso',
            prefixIcon: Icon(Icons.person_outline, size: 16, color: StitchColors.textMuted),
          ),
        ),

        const SizedBox(height: 10),

        // Email
        const Text(
          'Email',
          style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'nama@domain.com',
            prefixIcon: Icon(Icons.alternate_email, size: 16, color: StitchColors.textMuted),
          ),
        ),

        const SizedBox(height: 10),

        // Password & Confirm Password Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kata Sandi', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _regPasswordController,
                    obscureText: _obscureRegPassword,
                    style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Min 6 char',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureRegPassword ? Icons.visibility_off : Icons.visibility, color: StitchColors.textMuted, size: 14),
                        onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Konfirmasi', style: TextStyle(color: StitchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _regConfirmPasswordController,
                    obscureText: _obscureRegConfirm,
                    style: const TextStyle(color: StitchColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ulangi sandi',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureRegConfirm ? Icons.visibility_off : Icons.visibility, color: StitchColors.textMuted, size: 14),
                        onPressed: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const Spacer(),

        // Tombol Daftar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchColors.tealGlow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isRegLoading ? null : _handleRegister,
            child: _isRegLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text(
                    'Daftar & Buat Akun Baru',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }
}

// --- PAINTERS ---

class _BranchConnectorPainter extends CustomPainter {
  final double pulse;
  final bool isPlanAFailed;

  _BranchConnectorPainter({
    required this.pulse,
    required this.isPlanAFailed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const startY = 0.0;
    final endY = size.height;
    final leftX = size.width * 0.25;
    final rightX = size.width * 0.75;

    // Line to left (Plan A)
    final pathA = Path()
      ..moveTo(centerX, startY)
      ..cubicTo(centerX, endY * 0.5, leftX, endY * 0.5, leftX, endY);

    final paintA = Paint()
      ..color = isPlanAFailed
          ? StitchColors.redFailed.withOpacity(0.5)
          : StitchColors.darkBorderActive
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPlanAFailed ? 1.5 : 1.2;

    canvas.drawPath(pathA, paintA);

    // Line to right (Plan B - Fallback)
    final pathB = Path()
      ..moveTo(centerX, startY)
      ..cubicTo(centerX, endY * 0.5, rightX, endY * 0.5, rightX, endY);

    final paintB = Paint()
      ..color = isPlanAFailed
          ? StitchColors.tealGlow.withOpacity(0.5 + (pulse * 0.5))
          : StitchColors.darkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPlanAFailed ? 2.0 + (pulse * 1.0) : 1.0;

    canvas.drawPath(pathB, paintB);
  }

  @override
  bool shouldRepaint(covariant _BranchConnectorPainter oldDelegate) => true;
}

class _AmbientGlowPainter extends CustomPainter {
  final double time;

  _AmbientGlowPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final x1 = size.width * (0.3 + 0.15 * math.sin(time));
    final y1 = size.height * (0.25 + 0.1 * math.cos(time));

    final x2 = size.width * (0.75 + 0.1 * math.cos(time * 0.8));
    final y2 = size.height * (0.7 + 0.15 * math.sin(time * 0.8));

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          StitchColors.tealGlow.withOpacity(0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x1, y1), radius: 280));

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          StitchColors.indigoAccent.withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x2, y2), radius: 320));

    canvas.drawCircle(Offset(x1, y1), 280, paint1);
    canvas.drawCircle(Offset(x2, y2), 320, paint2);
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) => true;
}

class _AuthGridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E212A)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
