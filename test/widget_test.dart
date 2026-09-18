import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planner/models/plan_model.dart';
import 'package:planner/services/auth_service.dart';
import 'package:planner/services/planner_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Decision Tree Failover Logic: Plan A Gagal -> Plan B Menyala', () async {
    SharedPreferences.setMockInitialValues({});
    final plannerService = PlannerService();
    await plannerService.initialize();

    expect(plannerService.projects.isNotEmpty, isTrue);

    final project = plannerService.projects.first;
    expect(project.title, contains('Peluncuran Produk'));

    // Verifikasi kondisi awal sesuai desain Stitch:
    // Plan A gagal (OFF) dan Plan B menyala (fallbackGlow)
    final rootChildren = project.rootNode.children;
    expect(rootChildren.length, greaterThanOrEqualTo(2));

    final planA = rootChildren[0];
    final planB = rootChildren[1];

    expect(planA.status, equals(NodeStatus.failed));
    expect(planB.status, equals(NodeStatus.fallbackGlow));

    // Uji coba toggle Plan A kembali ke Aktif
    await plannerService.toggleNodeStatus(project.id, planA.id, NodeStatus.active);

    final updatedProject = plannerService.projects.firstWhere((p) => p.id == project.id);
    final updatedPlanA = updatedProject.rootNode.children[0];
    final updatedPlanB = updatedProject.rootNode.children[1];

    expect(updatedPlanA.status, equals(NodeStatus.active));
    expect(updatedPlanB.status, equals(NodeStatus.active));

    // Uji coba toggle Plan A ke Gagal kembali -> Plan B harus otomatis menyala
    await plannerService.toggleNodeStatus(project.id, planA.id, NodeStatus.failed);

    final refailedProject = plannerService.projects.firstWhere((p) => p.id == project.id);
    expect(refailedProject.rootNode.children[0].status, equals(NodeStatus.failed));
    expect(refailedProject.rootNode.children[1].status, equals(NodeStatus.fallbackGlow));
  });

  test('Auth Flow: Register, Login, Logout & Validation', () async {
    SharedPreferences.setMockInitialValues({});
    final authService = AuthService();
    await authService.initialize();

    // Awalnya belum login jika belum ada sesi tersimpan
    expect(authService.isLoggedIn, isFalse);

    // Login akun demo Sarah Wijaya
    final demoLogin = await authService.login(
      email: 'sarah.wijaya@planner.id',
      password: 'planner123',
    );
    expect(demoLogin.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser.email, equals('sarah.wijaya@planner.id'));

    // Uji Logout
    await authService.logout();
    expect(authService.isLoggedIn, isFalse);

    // Uji Login Gagal (Password salah)
    final failResult = await authService.login(
      email: 'sarah.wijaya@planner.id',
      password: 'wrong_password',
    );
    expect(failResult.success, isFalse);
    expect(authService.isLoggedIn, isFalse);

    // Uji Registrasi Akun Baru
    final regResult = await authService.register(
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@planner.id',
      password: 'password123',
      avatarEmoji: '👨‍💼',
    );
    expect(regResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
    expect(authService.currentUser.name, equals('Ahmad Fauzi'));
    expect(authService.currentUser.avatarEmoji, equals('👨‍💼'));

    // Uji Logout akun baru
    await authService.logout();
    expect(authService.isLoggedIn, isFalse);

    // Uji Login kembali dengan akun baru
    final loginResult = await authService.login(
      email: 'ahmad.fauzi@planner.id',
      password: 'password123',
    );
    expect(loginResult.success, isTrue);
    expect(authService.isLoggedIn, isTrue);
  });
}
