import 'dart:convert';

enum NodeStatus {
  active,
  failed,
  fallbackGlow,
  completed,
}

extension NodeStatusExtension on NodeStatus {
  String get label {
    switch (this) {
      case NodeStatus.active:
        return 'Aktif';
      case NodeStatus.failed:
        return 'Gagal (OFF)';
      case NodeStatus.fallbackGlow:
        return 'Kontingensi Menyala';
      case NodeStatus.completed:
        return 'Selesai';
    }
  }

  String get code {
    switch (this) {
      case NodeStatus.active:
        return 'active';
      case NodeStatus.failed:
        return 'failed';
      case NodeStatus.fallbackGlow:
        return 'fallbackGlow';
      case NodeStatus.completed:
        return 'completed';
    }
  }

  static NodeStatus fromCode(String? code) {
    switch (code) {
      case 'failed':
        return NodeStatus.failed;
      case 'fallbackGlow':
        return NodeStatus.fallbackGlow;
      case 'completed':
        return NodeStatus.completed;
      case 'active':
      default:
        return NodeStatus.active;
    }
  }
}

class PlanNode {
  final String id;
  final String? parentId;
  final String title;
  final String description;
  final String emoji;
  final DateTime targetDate;
  final NodeStatus status;
  final bool alarmHMinus1;
  final String alarmHMinus1Time;
  final bool alarmHariH;
  final String alarmHariHTime;
  final List<PlanNode> children;

  PlanNode({
    required this.id,
    this.parentId,
    required this.title,
    this.description = '',
    this.emoji = '📌',
    required this.targetDate,
    this.status = NodeStatus.active,
    this.alarmHMinus1 = true,
    this.alarmHMinus1Time = '09:00',
    this.alarmHariH = true,
    this.alarmHariHTime = '08:00',
    List<PlanNode>? children,
  }) : children = children ?? [];

  PlanNode copyWith({
    String? id,
    String? parentId,
    String? title,
    String? description,
    String? emoji,
    DateTime? targetDate,
    NodeStatus? status,
    bool? alarmHMinus1,
    String? alarmHMinus1Time,
    bool? alarmHariH,
    String? alarmHariHTime,
    List<PlanNode>? children,
  }) {
    return PlanNode(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      alarmHMinus1: alarmHMinus1 ?? this.alarmHMinus1,
      alarmHMinus1Time: alarmHMinus1Time ?? this.alarmHMinus1Time,
      alarmHariH: alarmHariH ?? this.alarmHariH,
      alarmHariHTime: alarmHariHTime ?? this.alarmHariHTime,
      children: children ?? this.children.map((c) => c.copyWith()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'description': description,
      'emoji': emoji,
      'targetDate': targetDate.toIso8601String(),
      'status': status.code,
      'alarmHMinus1': alarmHMinus1,
      'alarmHMinus1Time': alarmHMinus1Time,
      'alarmHariH': alarmHariH,
      'alarmHariHTime': alarmHariHTime,
      'children': children.map((c) => c.toMap()).toList(),
    };
  }

  factory PlanNode.fromMap(Map<String, dynamic> map) {
    return PlanNode(
      id: map['id'] as String,
      parentId: map['parentId'] as String?,
      title: map['title'] as String? ?? 'Rencana Baru',
      description: map['description'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '📌',
      targetDate: map['targetDate'] != null
          ? DateTime.tryParse(map['targetDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: NodeStatusExtension.fromCode(map['status'] as String?),
      alarmHMinus1: map['alarmHMinus1'] as bool? ?? true,
      alarmHMinus1Time: map['alarmHMinus1Time'] as String? ?? '09:00',
      alarmHariH: map['alarmHariH'] as bool? ?? true,
      alarmHariHTime: map['alarmHariHTime'] as String? ?? '08:00',
      children: (map['children'] as List<dynamic>?)
              ?.map((item) => PlanNode.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanNode.fromJson(String source) =>
      PlanNode.fromMap(json.decode(source) as Map<String, dynamic>);
}

class PlanProject {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime targetDate;
  final String category;
  final PlanNode rootNode;

  PlanProject({
    required this.id,
    required this.title,
    this.description = '',
    this.emoji = '🚀',
    required this.targetDate,
    this.category = 'Strategi Utama',
    required this.rootNode,
  });

  PlanProject copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    DateTime? targetDate,
    String? category,
    PlanNode? rootNode,
  }) {
    return PlanProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      rootNode: rootNode ?? this.rootNode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'rootNode': rootNode.toMap(),
    };
  }

  factory PlanProject.fromMap(Map<String, dynamic> map) {
    return PlanProject(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Proyek Baru',
      description: map['description'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '🚀',
      targetDate: map['targetDate'] != null
          ? DateTime.tryParse(map['targetDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] as String? ?? 'Strategi Utama',
      rootNode: PlanNode.fromMap(map['rootNode'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanProject.fromJson(String source) =>
      PlanProject.fromMap(json.decode(source) as Map<String, dynamic>);

  List<PlanNode> getAllNodes() {
    final List<PlanNode> result = [];
    void traverse(PlanNode node) {
      result.add(node);
      for (final child in node.children) {
        traverse(child);
      }
    }

    traverse(rootNode);
    return result;
  }

  int get totalNodesCount => getAllNodes().length;

  int get activeBranchesCount => rootNode.children.length;

  bool get hasFallbackGlow {
    return getAllNodes().any((n) => n.status == NodeStatus.fallbackGlow);
  }

  bool get hasFailedNode {
    return getAllNodes().any((n) => n.status == NodeStatus.failed);
  }
}
