import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/plan_model.dart';

class PlannerService extends ChangeNotifier {
  static final PlannerService _instance = PlannerService._internal();
  factory PlannerService() => _instance;
  PlannerService._internal();

  static const String _storageKey = 'branch_planner_projects_v2';
  final _uuid = const Uuid();

  List<PlanProject> _projects = [];
  bool _isInitialized = false;

  List<PlanProject> get projects => _projects;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData != null && savedData.isNotEmpty) {
      try {
        final List<dynamic> list = json.decode(savedData) as List<dynamic>;
        _projects = list
            .map((item) => PlanProject.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error loading saved projects: $e');
        _loadDefaultProjects();
      }
    } else {
      _loadDefaultProjects();
    }

    _isInitialized = true;
    notifyListeners();

    // Sinkronisasi dari Supabase jika user sudah login di cloud
    _syncFromSupabase();
  }

  Future<void> _syncFromSupabase() async {
    if (_supabase == null) return;
    final user = _supabase!.auth.currentUser;
    if (user == null) return;

    try {
      final projectsRes = await _supabase!
          .from('plan_projects')
          .select()
          .eq('user_id', user.id);

      if (projectsRes.isNotEmpty) {
        final List<PlanProject> cloudProjects = [];

        for (final pMap in projectsRes) {
          final pId = pMap['id'] as String;
          // Ambil seluruh node milik proyek ini
          final nodesRes = await _supabase!
              .from('plan_nodes')
              .select()
              .eq('project_id', pId)
              .order('sort_order', ascending: true);

          if (nodesRes.isNotEmpty) {
            // Bangun kembali hierarki tree node dari daftar datar (flat nodes)
            final treeRoot = _rebuildTreeFromFlatList(nodesRes);
            if (treeRoot != null) {
              cloudProjects.add(PlanProject(
                id: pId,
                title: pMap['title'] as String? ?? 'Proyek',
                description: pMap['description'] as String? ?? '',
                emoji: pMap['emoji'] as String? ?? '🚀',
                targetDate: DateTime.tryParse(pMap['target_date'] as String? ?? '') ?? DateTime.now(),
                category: pMap['category'] as String? ?? 'Strategi Utama',
                rootNode: treeRoot,
              ));
            }
          }
        }

        if (cloudProjects.isNotEmpty) {
          _projects = cloudProjects;
          await _saveToStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Sync from Supabase notice: $e');
    }
  }

  PlanNode? _rebuildTreeFromFlatList(List<dynamic> rawNodes) {
    final Map<String, PlanNode> nodeMap = {};
    final Map<String, List<PlanNode>> childrenMap = {};

    for (final raw in rawNodes) {
      final id = raw['id'] as String;
      final parentId = raw['parent_id'] as String?;
      final node = PlanNode(
        id: id,
        parentId: parentId,
        title: raw['title'] as String? ?? '',
        description: raw['description'] as String? ?? '',
        emoji: raw['emoji'] as String? ?? '📌',
        targetDate: DateTime.tryParse(raw['target_date'] as String? ?? '') ?? DateTime.now(),
        status: NodeStatusExtension.fromCode(raw['status'] as String?),
        alarmHMinus1: raw['alarm_h_minus_1'] as bool? ?? true,
        alarmHMinus1Time: raw['alarm_h_minus_1_time'] as String? ?? '09:00',
        alarmHariH: raw['alarm_hari_h'] as bool? ?? true,
        alarmHariHTime: raw['alarm_hari_h_time'] as String? ?? '08:00',
      );
      nodeMap[id] = node;
      if (parentId != null) {
        childrenMap.putIfAbsent(parentId, () => []).add(node);
      }
    }

    PlanNode attachChildren(PlanNode parent) {
      final kids = childrenMap[parent.id] ?? [];
      final resolvedKids = kids.map((k) => attachChildren(k)).toList();
      return parent.copyWith(children: resolvedKids);
    }

    // Root node adalah node tanpa parent_id
    final rootCandidates = nodeMap.values.where((n) => n.parentId == null).toList();
    if (rootCandidates.isNotEmpty) {
      return attachChildren(rootCandidates.first);
    }
    return null;
  }

  void _loadDefaultProjects() {
    final now = DateTime.now();
    final targetDate1 = DateTime(now.year, now.month, 15);
    final targetDate2 = DateTime(now.year, now.month, 28);
    final targetDate3 = DateTime(now.year, now.month + 1, 5);

    final rootId1 = _uuid.v4();
    final planAId = _uuid.v4();
    final planBId = _uuid.v4();
    final planB1Id = _uuid.v4();
    final planB2Id = _uuid.v4();

    // Default Stitch Project 1: Peluncuran Produk Q3 2025
    final project1 = PlanProject(
      id: 'proj-1',
      title: 'Peluncuran Produk Q3 2025',
      description:
          'Penetrasi pasar besar platform enterprise versi 2.0. Target penetrasi pasar domestik & akuisisi 10.000 user perdana.',
      emoji: '🚀',
      targetDate: targetDate1,
      category: 'Tech / Go-to-Market',
      rootNode: PlanNode(
        id: rootId1,
        title: 'Peluncuran Produk Q3 2025',
        description:
            'Pusat koordinasi rilis platform enterprise versi 2.0. Memetakan strategi utama vs kontingensi gerilya.',
        emoji: '🎯',
        targetDate: targetDate1,
        status: NodeStatus.active,
        alarmHMinus1: true,
        alarmHariH: true,
        children: [
          PlanNode(
            id: planAId,
            parentId: rootId1,
            title: 'Plan A: Pameran Fisik Expo & Booth Akbar',
            description:
                'Sewa booth utama di Jakarta Convention Center dan sebar brosur fisik enterprise.',
            emoji: '🏢',
            targetDate: targetDate1,
            status: NodeStatus.failed, // DEFAULT: GAGAL / OFF
            alarmHMinus1: true,
            alarmHariH: false,
          ),
          PlanNode(
            id: planBId,
            parentId: rootId1,
            title: 'Plan B: Community Guerilla & Referral',
            description:
                'Mengalihkan traffic organik melalui program relasi developer Discord, telegram broadcast, dan program duta kampus.',
            emoji: '⚡',
            targetDate: targetDate1,
            status: NodeStatus.fallbackGlow, // MENYALA OTOMATIS KARENA PLAN A GAGAL
            alarmHMinus1: true,
            alarmHariH: true,
            children: [
              PlanNode(
                id: planB1Id,
                parentId: planBId,
                title: 'Inisiatif Early Adopter',
                description:
                    'Tawarkan slot premium uji coba gratis untuk 500 pengguna loyal pertama.',
                emoji: '🎁',
                targetDate: targetDate1,
                status: NodeStatus.active,
              ),
              PlanNode(
                id: planB2Id,
                parentId: planBId,
                title: 'Program Diskon Buta / Voucher',
                description:
                    'Potongan 45% tahun pertama untuk peluncuran viral & reward referral aktif.',
                emoji: '🎟️',
                targetDate: targetDate1,
                status: NodeStatus.active,
              ),
            ],
          ),
        ],
      ),
    );

    // Default Stitch Project 2: Ekspansi Klien Korporat
    final rootId2 = _uuid.v4();
    final project2 = PlanProject(
      id: 'proj-2',
      title: 'Ekspansi Klien Korporat',
      description: 'Penyusunan otomasi on-boarding saluran baru, cold outreach ke 50 lead target.',
      emoji: '💼',
      targetDate: targetDate2,
      category: 'Sales / Enterprise',
      rootNode: PlanNode(
        id: rootId2,
        title: 'Ekspansi Klien Korporat',
        description: 'Pusat akuisisi akun enterprise regional.',
        emoji: '🏢',
        targetDate: targetDate2,
        status: NodeStatus.active,
        children: [
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId2,
            title: 'Plan A: Kontak Langsung via LinkedIn Sales Nav',
            description: 'Kirimkan pesan personalisasi ke 50 VP & Direktur teknologi.',
            emoji: '🤝',
            targetDate: targetDate2,
            status: NodeStatus.active,
          ),
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId2,
            title: 'Plan B: Webinar Eksekutif dengan Tamu Pembicara',
            description: 'Undang praktisi ternama untuk mengulas efisiensi workflow perusahaan.',
            emoji: '🎙️',
            targetDate: targetDate2,
            status: NodeStatus.active,
          ),
        ],
      ),
    );

    // Default Stitch Project 3: Relokasi & Remote Setup
    final rootId3 = _uuid.v4();
    final project3 = PlanProject(
      id: 'proj-3',
      title: 'Relokasi & Remote Setup',
      description: 'Penataan infrastruktur kerja fleksibel kuartal akhir.',
      emoji: '🌐',
      targetDate: targetDate3,
      category: 'Operasional',
      rootNode: PlanNode(
        id: rootId3,
        title: 'Relokasi & Remote Setup',
        description: 'Sistem cloud dan koordinasi async lintas tim.',
        emoji: '💻',
        targetDate: targetDate3,
        status: NodeStatus.active,
        children: [
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId3,
            title: 'Plan A: Migrasi Server Private ke Cloud Hybrid',
            description: 'Pindahkan database staging dan live ke cluster multi-region.',
            emoji: '☁️',
            targetDate: targetDate3,
            status: NodeStatus.active,
          ),
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId3,
            title: 'Plan B: Subsidi Full WFH & Coworking Allowance',
            description: 'Berikan alokasi tunjangan bulanan untuk perlengkapan kerja tim dari rumah.',
            emoji: '🏡',
            targetDate: targetDate3,
            status: NodeStatus.active,
          ),
        ],
      ),
    );

    _projects = [project1, project2, project3];
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = json.encode(_projects.map((p) => p.toMap()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving projects: $e');
    }
  }

  Future<void> _saveProjectToSupabase(PlanProject project) async {
    if (_supabase == null) return;
    final user = _supabase!.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Simpan baris proyek
      await _supabase!.from('plan_projects').upsert({
        'id': project.id,
        'user_id': user.id,
        'title': project.title,
        'description': project.description,
        'emoji': project.emoji,
        'category': project.category,
        'target_date': project.targetDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Simpan seluruh node dalam pohon (traversal)
      int order = 0;
      final nodes = project.getAllNodes();
      for (final n in nodes) {
        await _supabase!.from('plan_nodes').upsert({
          'id': n.id,
          'project_id': project.id,
          'parent_id': n.parentId,
          'title': n.title,
          'description': n.description,
          'emoji': n.emoji,
          'target_date': n.targetDate.toIso8601String(),
          'status': n.status.code,
          'alarm_h_minus_1': n.alarmHMinus1,
          'alarm_h_minus_1_time': n.alarmHMinus1Time,
          'alarm_hari_h': n.alarmHariH,
          'alarm_hari_h_time': n.alarmHariHTime,
          'sort_order': order++,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error saving to Supabase: $e');
    }
  }

  // --- CRUD Project ---
  Future<void> addProject({
    required String title,
    required String description,
    required String emoji,
    required DateTime targetDate,
    String category = 'Strategi Utama',
  }) async {
    final projId = _uuid.v4();
    final rootId = _uuid.v4();

    final newProject = PlanProject(
      id: projId,
      title: title,
      description: description,
      emoji: emoji,
      targetDate: targetDate,
      category: category,
      rootNode: PlanNode(
        id: rootId,
        title: title,
        description: description,
        emoji: emoji,
        targetDate: targetDate,
        status: NodeStatus.active,
        children: [
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId,
            title: 'Plan A: Rencana Utama',
            description: 'Langkah eksekusi primer.',
            emoji: '🎯',
            targetDate: targetDate,
            status: NodeStatus.active,
          ),
          PlanNode(
            id: _uuid.v4(),
            parentId: rootId,
            title: 'Plan B: Jalur Kontingensi',
            description: 'Jalur cadangan jika Plan A mengalami kendala.',
            emoji: '⚡',
            targetDate: targetDate,
            status: NodeStatus.active,
          ),
        ],
      ),
    );

    _projects.insert(0, newProject);
    notifyListeners();
    await _saveToStorage();
    await _saveProjectToSupabase(newProject);
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
    await _saveToStorage();

    if (_supabase != null && _supabase!.auth.currentUser != null) {
      try {
        await _supabase!.from('plan_projects').delete().eq('id', projectId);
      } catch (e) {
        debugPrint('Supabase delete project notice: $e');
      }
    }
  }

  PlanProject? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      return null;
    }
  }

  // --- Decision Forest Node Manipulation ---
  Future<void> addBranch({
    required String projectId,
    required String parentNodeId,
    required String title,
    String description = '',
    String emoji = '🌱',
    required DateTime targetDate,
  }) async {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex == -1) return;

    final project = _projects[projectIndex];
    final newNode = PlanNode(
      id: _uuid.v4(),
      parentId: parentNodeId,
      title: title,
      description: description,
      emoji: emoji,
      targetDate: targetDate,
      status: NodeStatus.active,
    );

    PlanNode updateTree(PlanNode current) {
      if (current.id == parentNodeId) {
        final updatedChildren = List<PlanNode>.from(current.children)..add(newNode);
        return current.copyWith(children: updatedChildren);
      }
      return current.copyWith(
        children: current.children.map(updateTree).toList(),
      );
    }

    final updatedRoot = updateTree(project.rootNode);
    final updatedProject = project.copyWith(rootNode: updatedRoot);
    _projects[projectIndex] = updatedProject;
    notifyListeners();
    await _saveToStorage();
    await _saveProjectToSupabase(updatedProject);
  }

  Future<void> updateNode(String projectId, PlanNode updatedNode) async {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex == -1) return;

    final project = _projects[projectIndex];

    PlanNode updateTree(PlanNode current) {
      if (current.id == updatedNode.id) {
        return updatedNode.copyWith(children: current.children);
      }
      return current.copyWith(
        children: current.children.map(updateTree).toList(),
      );
    }

    final updatedRoot = updateTree(project.rootNode);
    final updatedProject = project.copyWith(rootNode: updatedRoot);
    _projects[projectIndex] = updatedProject;
    notifyListeners();
    await _saveToStorage();
    await _saveProjectToSupabase(updatedProject);
  }

  /// Logika Failover Kunci: Ketika Plan A di-toggle ke Gagal (OFF),
  /// opsi cadangan saudaranya (Plan B) otomatis menyala/aktif (fallbackGlow)!
  Future<void> toggleNodeStatus(String projectId, String nodeId, NodeStatus newStatus) async {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex == -1) return;

    final project = _projects[projectIndex];

    PlanNode processTree(PlanNode current) {
      final hasTargetChild = current.children.any((c) => c.id == nodeId);

      if (hasTargetChild) {
        final List<PlanNode> newChildren = [];
        final targetIndex = current.children.indexWhere((c) => c.id == nodeId);

        for (int i = 0; i < current.children.length; i++) {
          final child = current.children[i];
          if (i == targetIndex) {
            newChildren.add(child.copyWith(status: newStatus));
          } else {
            if (newStatus == NodeStatus.failed) {
              if (child.status == NodeStatus.active) {
                newChildren.add(child.copyWith(status: NodeStatus.fallbackGlow));
              } else {
                newChildren.add(child);
              }
            } else if (newStatus == NodeStatus.active) {
              if (child.status == NodeStatus.fallbackGlow) {
                newChildren.add(child.copyWith(status: NodeStatus.active));
              } else {
                newChildren.add(child);
              }
            } else {
              newChildren.add(child);
            }
          }
        }
        return current.copyWith(children: newChildren);
      }

      return current.copyWith(
        children: current.children.map(processTree).toList(),
      );
    }

    PlanNode finalRoot;
    if (project.rootNode.id == nodeId) {
      finalRoot = project.rootNode.copyWith(status: newStatus);
    } else {
      finalRoot = processTree(project.rootNode);
    }

    final updatedProject = project.copyWith(rootNode: finalRoot);
    _projects[projectIndex] = updatedProject;
    notifyListeners();
    await _saveToStorage();
    await _saveProjectToSupabase(updatedProject);
  }

  Future<void> deleteNode(String projectId, String nodeId) async {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex == -1) return;

    final project = _projects[projectIndex];
    if (project.rootNode.id == nodeId) return; // Tidak bisa menghapus root

    PlanNode removeFromTree(PlanNode current) {
      final filtered = current.children.where((c) => c.id != nodeId).toList();
      return current.copyWith(
        children: filtered.map(removeFromTree).toList(),
      );
    }

    final updatedRoot = removeFromTree(project.rootNode);
    final updatedProject = project.copyWith(rootNode: updatedRoot);
    _projects[projectIndex] = updatedProject;
    notifyListeners();
    await _saveToStorage();
    await _saveProjectToSupabase(updatedProject);

    if (_supabase != null && _supabase!.auth.currentUser != null) {
      try {
        await _supabase!.from('plan_nodes').delete().eq('id', nodeId);
      } catch (e) {
        debugPrint('Supabase delete node notice: $e');
      }
    }
  }

  // Alias untuk addBranch agar kompatibel
  Future<void> addChildNode({
    required String projectId,
    required String parentNodeId,
    required String title,
    String description = '',
    String emoji = '🌱',
    required DateTime targetDate,
  }) async {
    await addBranch(
      projectId: projectId,
      parentNodeId: parentNodeId,
      title: title,
      description: description,
      emoji: emoji,
      targetDate: targetDate,
    );
  }

  // Pengelompokan seluruh node beserta project-nya untuk kalender ScheduleView
  Map<DateTime, List<Map<String, dynamic>>> getEventsByDate() {
    final Map<DateTime, List<Map<String, dynamic>>> map = {};
    for (final project in _projects) {
      for (final node in project.getAllNodes()) {
        final dateKey = DateTime(
          node.targetDate.year,
          node.targetDate.month,
          node.targetDate.day,
        );
        map.putIfAbsent(dateKey, () => []).add({
          'project': project,
          'node': node,
        });
      }
    }
    return map;
  }
}
