/// Representation of a local IDE project directory or git repository
class ProjectModel {
  final String id;
  final String name;
  final String path;
  final String? gitUrl;
  final DateTime lastOpened;
  final String language;
  final String? description;

  ProjectModel({
    required this.id,
    required this.name,
    required this.path,
    this.gitUrl,
    required this.lastOpened,
    this.language = 'Flutter/Dart',
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'gitUrl': gitUrl,
        'lastOpened': lastOpened.toIso8601String(),
        'language': language,
        'description': description,
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        gitUrl: json['gitUrl'] as String?,
        lastOpened: DateTime.parse(json['lastOpened'] as String),
        language: json['language'] as String? ?? 'Flutter/Dart',
        description: json['description'] as String?,
      );

  ProjectModel copyWith({
    String? id,
    String? name,
    String? path,
    String? gitUrl,
    DateTime? lastOpened,
    String? language,
    String? description,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      gitUrl: gitUrl ?? this.gitUrl,
      lastOpened: lastOpened ?? this.lastOpened,
      language: language ?? this.language,
      description: description ?? this.description,
    );
  }
}
