// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LabelsTable extends Labels with TableInfo<$LabelsTable, Label> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('label'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6366F1'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    parentId,
    name,
    iconName,
    color,
    sortOrder,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Label> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Label map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Label(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class Label extends DataClass implements Insertable<Label> {
  final String id;
  final String userId;
  final String? parentId;
  final String name;
  final String iconName;
  final String color;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const Label({
    required this.id,
    required this.userId,
    this.parentId,
    required this.name,
    required this.iconName,
    required this.color,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      id: Value(id),
      userId: Value(userId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      iconName: Value(iconName),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory Label.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Label(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Label copyWith({
    String? id,
    String? userId,
    Value<String?> parentId = const Value.absent(),
    String? name,
    String? iconName,
    String? color,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => Label(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Label copyWithCompanion(LabelsCompanion data) {
    return Label(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Label(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    parentId,
    name,
    iconName,
    color,
    sortOrder,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class LabelsCompanion extends UpdateCompanion<Label> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> iconName;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LabelsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabelsCompanion.insert({
    required String id,
    required String userId,
    this.parentId = const Value.absent(),
    required String name,
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Label> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabelsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String>? iconName,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LabelsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<String> labelId = GeneratedColumn<String>(
    'label_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _hasTimeTrackingMeta = const VerificationMeta(
    'hasTimeTracking',
  );
  @override
  late final GeneratedColumn<bool> hasTimeTracking = GeneratedColumn<bool>(
    'has_time_tracking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_time_tracking" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleIdMeta = const VerificationMeta(
    'recurrenceRuleId',
  );
  @override
  late final GeneratedColumn<String> recurrenceRuleId = GeneratedColumn<String>(
    'recurrence_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    labelId,
    title,
    description,
    iconName,
    imagePath,
    url,
    category,
    status,
    priority,
    hasTimeTracking,
    estimatedMinutes,
    recurrenceRuleId,
    scheduledDate,
    dueDate,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('has_time_tracking')) {
      context.handle(
        _hasTimeTrackingMeta,
        hasTimeTracking.isAcceptableOrUnknown(
          data['has_time_tracking']!,
          _hasTimeTrackingMeta,
        ),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
        _recurrenceRuleIdMeta,
        recurrenceRuleId.isAcceptableOrUnknown(
          data['recurrence_rule_id']!,
          _recurrenceRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      hasTimeTracking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_time_tracking'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      recurrenceRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule_id'],
      ),
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String userId;
  final String? labelId;
  final String title;
  final String? description;
  final String? iconName;
  final String? imagePath;
  final String? url;
  final String? category;
  final String status;
  final String priority;
  final bool hasTimeTracking;
  final int? estimatedMinutes;
  final String? recurrenceRuleId;
  final DateTime? scheduledDate;
  final DateTime? dueDate;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const Task({
    required this.id,
    required this.userId,
    this.labelId,
    required this.title,
    this.description,
    this.iconName,
    this.imagePath,
    this.url,
    this.category,
    required this.status,
    required this.priority,
    required this.hasTimeTracking,
    this.estimatedMinutes,
    this.recurrenceRuleId,
    this.scheduledDate,
    this.dueDate,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || labelId != null) {
      map['label_id'] = Variable<String>(labelId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['has_time_tracking'] = Variable<bool>(hasTimeTracking);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId);
    }
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      labelId: labelId == null && nullToAbsent
          ? const Value.absent()
          : Value(labelId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      status: Value(status),
      priority: Value(priority),
      hasTimeTracking: Value(hasTimeTracking),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      labelId: serializer.fromJson<String?>(json['labelId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      url: serializer.fromJson<String?>(json['url']),
      category: serializer.fromJson<String?>(json['category']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      hasTimeTracking: serializer.fromJson<bool>(json['hasTimeTracking']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      recurrenceRuleId: serializer.fromJson<String?>(json['recurrenceRuleId']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'labelId': serializer.toJson<String?>(labelId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'iconName': serializer.toJson<String?>(iconName),
      'imagePath': serializer.toJson<String?>(imagePath),
      'url': serializer.toJson<String?>(url),
      'category': serializer.toJson<String?>(category),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'hasTimeTracking': serializer.toJson<bool>(hasTimeTracking),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'recurrenceRuleId': serializer.toJson<String?>(recurrenceRuleId),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    Value<String?> labelId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> iconName = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? status,
    String? priority,
    bool? hasTimeTracking,
    Value<int?> estimatedMinutes = const Value.absent(),
    Value<String?> recurrenceRuleId = const Value.absent(),
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    labelId: labelId.present ? labelId.value : this.labelId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    iconName: iconName.present ? iconName.value : this.iconName,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    url: url.present ? url.value : this.url,
    category: category.present ? category.value : this.category,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    hasTimeTracking: hasTimeTracking ?? this.hasTimeTracking,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    recurrenceRuleId: recurrenceRuleId.present
        ? recurrenceRuleId.value
        : this.recurrenceRuleId,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      url: data.url.present ? data.url.value : this.url,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      hasTimeTracking: data.hasTimeTracking.present
          ? data.hasTimeTracking.value
          : this.hasTimeTracking,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('labelId: $labelId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('imagePath: $imagePath, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('hasTimeTracking: $hasTimeTracking, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    labelId,
    title,
    description,
    iconName,
    imagePath,
    url,
    category,
    status,
    priority,
    hasTimeTracking,
    estimatedMinutes,
    recurrenceRuleId,
    scheduledDate,
    dueDate,
    isArchived,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.labelId == this.labelId &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconName == this.iconName &&
          other.imagePath == this.imagePath &&
          other.url == this.url &&
          other.category == this.category &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.hasTimeTracking == this.hasTimeTracking &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.scheduledDate == this.scheduledDate &&
          other.dueDate == this.dueDate &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> labelId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> iconName;
  final Value<String?> imagePath;
  final Value<String?> url;
  final Value<String?> category;
  final Value<String> status;
  final Value<String> priority;
  final Value<bool> hasTimeTracking;
  final Value<int?> estimatedMinutes;
  final Value<String?> recurrenceRuleId;
  final Value<DateTime?> scheduledDate;
  final Value<DateTime?> dueDate;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.url = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.hasTimeTracking = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String userId,
    this.labelId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.iconName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.url = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.hasTimeTracking = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? labelId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconName,
    Expression<String>? imagePath,
    Expression<String>? url,
    Expression<String>? category,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<bool>? hasTimeTracking,
    Expression<int>? estimatedMinutes,
    Expression<String>? recurrenceRuleId,
    Expression<DateTime>? scheduledDate,
    Expression<DateTime>? dueDate,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (labelId != null) 'label_id': labelId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (imagePath != null) 'image_path': imagePath,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (hasTimeTracking != null) 'has_time_tracking': hasTimeTracking,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (dueDate != null) 'due_date': dueDate,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? labelId,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? iconName,
    Value<String?>? imagePath,
    Value<String?>? url,
    Value<String?>? category,
    Value<String>? status,
    Value<String>? priority,
    Value<bool>? hasTimeTracking,
    Value<int?>? estimatedMinutes,
    Value<String?>? recurrenceRuleId,
    Value<DateTime?>? scheduledDate,
    Value<DateTime?>? dueDate,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      labelId: labelId ?? this.labelId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      imagePath: imagePath ?? this.imagePath,
      url: url ?? this.url,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      hasTimeTracking: hasTimeTracking ?? this.hasTimeTracking,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dueDate: dueDate ?? this.dueDate,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<String>(labelId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (hasTimeTracking.present) {
      map['has_time_tracking'] = Variable<bool>(hasTimeTracking.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('labelId: $labelId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconName: $iconName, ')
          ..write('imagePath: $imagePath, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('hasTimeTracking: $hasTimeTracking, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRulesTable extends RecurrenceRules
    with TableInfo<$RecurrenceRulesTable, RecurrenceRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMonthsMeta = const VerificationMeta(
    'intervalMonths',
  );
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
    'interval_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxOccurrencesMeta = const VerificationMeta(
    'maxOccurrences',
  );
  @override
  late final GeneratedColumn<int> maxOccurrences = GeneratedColumn<int>(
    'max_occurrences',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    daysOfWeek,
    intervalDays,
    intervalMonths,
    startDate,
    endDate,
    maxOccurrences,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('interval_months')) {
      context.handle(
        _intervalMonthsMeta,
        intervalMonths.isAcceptableOrUnknown(
          data['interval_months']!,
          _intervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('max_occurrences')) {
      context.handle(
        _maxOccurrencesMeta,
        maxOccurrences.isAcceptableOrUnknown(
          data['max_occurrences']!,
          _maxOccurrencesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      intervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_months'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      maxOccurrences: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_occurrences'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $RecurrenceRulesTable createAlias(String alias) {
    return $RecurrenceRulesTable(attachedDatabase, alias);
  }
}

class RecurrenceRule extends DataClass implements Insertable<RecurrenceRule> {
  final String id;
  final String userId;
  final String type;
  final String? daysOfWeek;
  final int? intervalDays;
  final int? intervalMonths;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const RecurrenceRule({
    required this.id,
    required this.userId,
    required this.type,
    this.daysOfWeek,
    this.intervalDays,
    this.intervalMonths,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || daysOfWeek != null) {
      map['days_of_week'] = Variable<String>(daysOfWeek);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || intervalMonths != null) {
      map['interval_months'] = Variable<int>(intervalMonths);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || maxOccurrences != null) {
      map['max_occurrences'] = Variable<int>(maxOccurrences);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  RecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRulesCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      daysOfWeek: daysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(daysOfWeek),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      intervalMonths: intervalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMonths),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      maxOccurrences: maxOccurrences == null && nullToAbsent
          ? const Value.absent()
          : Value(maxOccurrences),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory RecurrenceRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRule(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      daysOfWeek: serializer.fromJson<String?>(json['daysOfWeek']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      intervalMonths: serializer.fromJson<int?>(json['intervalMonths']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      maxOccurrences: serializer.fromJson<int?>(json['maxOccurrences']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'daysOfWeek': serializer.toJson<String?>(daysOfWeek),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'intervalMonths': serializer.toJson<int?>(intervalMonths),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'maxOccurrences': serializer.toJson<int?>(maxOccurrences),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  RecurrenceRule copyWith({
    String? id,
    String? userId,
    String? type,
    Value<String?> daysOfWeek = const Value.absent(),
    Value<int?> intervalDays = const Value.absent(),
    Value<int?> intervalMonths = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> maxOccurrences = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => RecurrenceRule(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    daysOfWeek: daysOfWeek.present ? daysOfWeek.value : this.daysOfWeek,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    intervalMonths: intervalMonths.present
        ? intervalMonths.value
        : this.intervalMonths,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    maxOccurrences: maxOccurrences.present
        ? maxOccurrences.value
        : this.maxOccurrences,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  RecurrenceRule copyWithCompanion(RecurrenceRulesCompanion data) {
    return RecurrenceRule(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      intervalMonths: data.intervalMonths.present
          ? data.intervalMonths.value
          : this.intervalMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      maxOccurrences: data.maxOccurrences.present
          ? data.maxOccurrences.value
          : this.maxOccurrences,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRule(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('maxOccurrences: $maxOccurrences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    daysOfWeek,
    intervalDays,
    intervalMonths,
    startDate,
    endDate,
    maxOccurrences,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRule &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.daysOfWeek == this.daysOfWeek &&
          other.intervalDays == this.intervalDays &&
          other.intervalMonths == this.intervalMonths &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.maxOccurrences == this.maxOccurrences &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class RecurrenceRulesCompanion extends UpdateCompanion<RecurrenceRule> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> daysOfWeek;
  final Value<int?> intervalDays;
  final Value<int?> intervalMonths;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> maxOccurrences;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const RecurrenceRulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.maxOccurrences = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceRulesCompanion.insert({
    required String id,
    required String userId,
    required String type,
    this.daysOfWeek = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.maxOccurrences = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurrenceRule> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? daysOfWeek,
    Expression<int>? intervalDays,
    Expression<int>? intervalMonths,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? maxOccurrences,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (maxOccurrences != null) 'max_occurrences': maxOccurrences,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String?>? daysOfWeek,
    Value<int?>? intervalDays,
    Value<int?>? intervalMonths,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? maxOccurrences,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return RecurrenceRulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (maxOccurrences.present) {
      map['max_occurrences'] = Variable<int>(maxOccurrences.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('maxOccurrences: $maxOccurrences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskOccurrencesTable extends TaskOccurrences
    with TableInfo<$TaskOccurrencesTable, TaskOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>(
        'occurrence_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskId,
    occurrenceDate,
    status,
    completedAt,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurrence_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TaskOccurrencesTable createAlias(String alias) {
    return $TaskOccurrencesTable(attachedDatabase, alias);
  }
}

class TaskOccurrence extends DataClass implements Insertable<TaskOccurrence> {
  final String id;
  final String userId;
  final String taskId;
  final DateTime occurrenceDate;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const TaskOccurrence({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.occurrenceDate,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<String>(taskId);
    map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TaskOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return TaskOccurrencesCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      occurrenceDate: Value(occurrenceDate),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory TaskOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskOccurrence(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      occurrenceDate: serializer.fromJson<DateTime>(json['occurrenceDate']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String>(taskId),
      'occurrenceDate': serializer.toJson<DateTime>(occurrenceDate),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TaskOccurrence copyWith({
    String? id,
    String? userId,
    String? taskId,
    DateTime? occurrenceDate,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => TaskOccurrence(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  TaskOccurrence copyWithCompanion(TaskOccurrencesCompanion data) {
    return TaskOccurrence(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskOccurrence(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskId,
    occurrenceDate,
    status,
    completedAt,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskOccurrence &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class TaskOccurrencesCompanion extends UpdateCompanion<TaskOccurrence> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskId;
  final Value<DateTime> occurrenceDate;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TaskOccurrencesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskOccurrencesCompanion.insert({
    required String id,
    required String userId,
    required String taskId,
    required DateTime occurrenceDate,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       occurrenceDate = Value(occurrenceDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskOccurrence> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<DateTime>? occurrenceDate,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskId,
    Value<DateTime>? occurrenceDate,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TaskOccurrencesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionEventsTable extends CompletionEvents
    with TableInfo<$CompletionEventsTable, CompletionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskId,
    occurrenceId,
    completedAt,
    notes,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CompletionEventsTable createAlias(String alias) {
    return $CompletionEventsTable(attachedDatabase, alias);
  }
}

class CompletionEvent extends DataClass implements Insertable<CompletionEvent> {
  final String id;
  final String userId;
  final String taskId;
  final String? occurrenceId;
  final DateTime completedAt;
  final String? notes;
  final DateTime createdAt;
  final bool isDeleted;
  const CompletionEvent({
    required this.id,
    required this.userId,
    required this.taskId,
    this.occurrenceId,
    required this.completedAt,
    this.notes,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || occurrenceId != null) {
      map['occurrence_id'] = Variable<String>(occurrenceId);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CompletionEventsCompanion toCompanion(bool nullToAbsent) {
    return CompletionEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      occurrenceId: occurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceId),
      completedAt: Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory CompletionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionEvent(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      occurrenceId: serializer.fromJson<String?>(json['occurrenceId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String>(taskId),
      'occurrenceId': serializer.toJson<String?>(occurrenceId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CompletionEvent copyWith({
    String? id,
    String? userId,
    String? taskId,
    Value<String?> occurrenceId = const Value.absent(),
    DateTime? completedAt,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    bool? isDeleted,
  }) => CompletionEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    occurrenceId: occurrenceId.present ? occurrenceId.value : this.occurrenceId,
    completedAt: completedAt ?? this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  CompletionEvent copyWithCompanion(CompletionEventsCompanion data) {
    return CompletionEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskId,
    occurrenceId,
    completedAt,
    notes,
    createdAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.occurrenceId == this.occurrenceId &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class CompletionEventsCompanion extends UpdateCompanion<CompletionEvent> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskId;
  final Value<String?> occurrenceId;
  final Value<DateTime> completedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CompletionEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionEventsCompanion.insert({
    required String id,
    required String userId,
    required String taskId,
    this.occurrenceId = const Value.absent(),
    required DateTime completedAt,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       completedAt = Value(completedAt),
       createdAt = Value(createdAt);
  static Insertable<CompletionEvent> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<String>? occurrenceId,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskId,
    Value<String?>? occurrenceId,
    Value<DateTime>? completedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CompletionEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerSessionsTable extends TimerSessions
    with TableInfo<$TimerSessionsTable, TimerSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('running'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskId,
    occurrenceId,
    startedAt,
    pausedAt,
    endedAt,
    elapsedSeconds,
    status,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      elapsedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_seconds'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TimerSessionsTable createAlias(String alias) {
    return $TimerSessionsTable(attachedDatabase, alias);
  }
}

class TimerSession extends DataClass implements Insertable<TimerSession> {
  final String id;
  final String userId;
  final String taskId;
  final String? occurrenceId;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final DateTime? endedAt;
  final int elapsedSeconds;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const TimerSession({
    required this.id,
    required this.userId,
    required this.taskId,
    this.occurrenceId,
    required this.startedAt,
    this.pausedAt,
    this.endedAt,
    required this.elapsedSeconds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || occurrenceId != null) {
      map['occurrence_id'] = Variable<String>(occurrenceId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TimerSessionsCompanion toCompanion(bool nullToAbsent) {
    return TimerSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      occurrenceId: occurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceId),
      startedAt: Value(startedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      elapsedSeconds: Value(elapsedSeconds),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory TimerSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      occurrenceId: serializer.fromJson<String?>(json['occurrenceId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String>(taskId),
      'occurrenceId': serializer.toJson<String?>(occurrenceId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TimerSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    Value<String?> occurrenceId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> pausedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    int? elapsedSeconds,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => TimerSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    occurrenceId: occurrenceId.present ? occurrenceId.value : this.occurrenceId,
    startedAt: startedAt ?? this.startedAt,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  TimerSession copyWithCompanion(TimerSessionsCompanion data) {
    return TimerSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskId,
    occurrenceId,
    startedAt,
    pausedAt,
    endedAt,
    elapsedSeconds,
    status,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.occurrenceId == this.occurrenceId &&
          other.startedAt == this.startedAt &&
          other.pausedAt == this.pausedAt &&
          other.endedAt == this.endedAt &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class TimerSessionsCompanion extends UpdateCompanion<TimerSession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskId;
  final Value<String?> occurrenceId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> endedAt;
  final Value<int> elapsedSeconds;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TimerSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerSessionsCompanion.insert({
    required String id,
    required String userId,
    required String taskId,
    this.occurrenceId = const Value.absent(),
    required DateTime startedAt,
    this.pausedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TimerSession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<String>? occurrenceId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? elapsedSeconds,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskId,
    Value<String?>? occurrenceId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? pausedAt,
    Value<DateTime?>? endedAt,
    Value<int>? elapsedSeconds,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TimerSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      endedAt: endedAt ?? this.endedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KpiDefinitionsTable extends KpiDefinitions
    with TableInfo<$KpiDefinitionsTable, KpiDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KpiDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<String> labelId = GeneratedColumn<String>(
    'label_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kpiTypeMeta = const VerificationMeta(
    'kpiType',
  );
  @override
  late final GeneratedColumn<String> kpiType = GeneratedColumn<String>(
    'kpi_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _longTermTargetMeta = const VerificationMeta(
    'longTermTarget',
  );
  @override
  late final GeneratedColumn<double> longTermTarget = GeneratedColumn<double>(
    'long_term_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('count'),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _metricCategoryMeta = const VerificationMeta(
    'metricCategory',
  );
  @override
  late final GeneratedColumn<String> metricCategory = GeneratedColumn<String>(
    'metric_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('output'),
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    labelId,
    name,
    description,
    kpiType,
    targetValue,
    currentValue,
    longTermTarget,
    unit,
    platform,
    metricCategory,
    period,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kpi_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<KpiDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('kpi_type')) {
      context.handle(
        _kpiTypeMeta,
        kpiType.isAcceptableOrUnknown(data['kpi_type']!, _kpiTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_kpiTypeMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('long_term_target')) {
      context.handle(
        _longTermTargetMeta,
        longTermTarget.isAcceptableOrUnknown(
          data['long_term_target']!,
          _longTermTargetMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('metric_category')) {
      context.handle(
        _metricCategoryMeta,
        metricCategory.isAcceptableOrUnknown(
          data['metric_category']!,
          _metricCategoryMeta,
        ),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KpiDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KpiDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      kpiType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kpi_type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      longTermTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}long_term_target'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      metricCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_category'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $KpiDefinitionsTable createAlias(String alias) {
    return $KpiDefinitionsTable(attachedDatabase, alias);
  }
}

class KpiDefinition extends DataClass implements Insertable<KpiDefinition> {
  final String id;
  final String userId;
  final String? labelId;
  final String name;
  final String? description;
  final String kpiType;
  final double targetValue;
  final double currentValue;
  final double? longTermTarget;
  final String unit;
  final String platform;
  final String metricCategory;
  final String period;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const KpiDefinition({
    required this.id,
    required this.userId,
    this.labelId,
    required this.name,
    this.description,
    required this.kpiType,
    required this.targetValue,
    required this.currentValue,
    this.longTermTarget,
    required this.unit,
    required this.platform,
    required this.metricCategory,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || labelId != null) {
      map['label_id'] = Variable<String>(labelId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['kpi_type'] = Variable<String>(kpiType);
    map['target_value'] = Variable<double>(targetValue);
    map['current_value'] = Variable<double>(currentValue);
    if (!nullToAbsent || longTermTarget != null) {
      map['long_term_target'] = Variable<double>(longTermTarget);
    }
    map['unit'] = Variable<String>(unit);
    map['platform'] = Variable<String>(platform);
    map['metric_category'] = Variable<String>(metricCategory);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  KpiDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return KpiDefinitionsCompanion(
      id: Value(id),
      userId: Value(userId),
      labelId: labelId == null && nullToAbsent
          ? const Value.absent()
          : Value(labelId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      kpiType: Value(kpiType),
      targetValue: Value(targetValue),
      currentValue: Value(currentValue),
      longTermTarget: longTermTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(longTermTarget),
      unit: Value(unit),
      platform: Value(platform),
      metricCategory: Value(metricCategory),
      period: Value(period),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory KpiDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KpiDefinition(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      labelId: serializer.fromJson<String?>(json['labelId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      kpiType: serializer.fromJson<String>(json['kpiType']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      longTermTarget: serializer.fromJson<double?>(json['longTermTarget']),
      unit: serializer.fromJson<String>(json['unit']),
      platform: serializer.fromJson<String>(json['platform']),
      metricCategory: serializer.fromJson<String>(json['metricCategory']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'labelId': serializer.toJson<String?>(labelId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'kpiType': serializer.toJson<String>(kpiType),
      'targetValue': serializer.toJson<double>(targetValue),
      'currentValue': serializer.toJson<double>(currentValue),
      'longTermTarget': serializer.toJson<double?>(longTermTarget),
      'unit': serializer.toJson<String>(unit),
      'platform': serializer.toJson<String>(platform),
      'metricCategory': serializer.toJson<String>(metricCategory),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  KpiDefinition copyWith({
    String? id,
    String? userId,
    Value<String?> labelId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    String? kpiType,
    double? targetValue,
    double? currentValue,
    Value<double?> longTermTarget = const Value.absent(),
    String? unit,
    String? platform,
    String? metricCategory,
    String? period,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => KpiDefinition(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    labelId: labelId.present ? labelId.value : this.labelId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    kpiType: kpiType ?? this.kpiType,
    targetValue: targetValue ?? this.targetValue,
    currentValue: currentValue ?? this.currentValue,
    longTermTarget: longTermTarget.present
        ? longTermTarget.value
        : this.longTermTarget,
    unit: unit ?? this.unit,
    platform: platform ?? this.platform,
    metricCategory: metricCategory ?? this.metricCategory,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  KpiDefinition copyWithCompanion(KpiDefinitionsCompanion data) {
    return KpiDefinition(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      kpiType: data.kpiType.present ? data.kpiType.value : this.kpiType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      longTermTarget: data.longTermTarget.present
          ? data.longTermTarget.value
          : this.longTermTarget,
      unit: data.unit.present ? data.unit.value : this.unit,
      platform: data.platform.present ? data.platform.value : this.platform,
      metricCategory: data.metricCategory.present
          ? data.metricCategory.value
          : this.metricCategory,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KpiDefinition(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('labelId: $labelId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('kpiType: $kpiType, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('longTermTarget: $longTermTarget, ')
          ..write('unit: $unit, ')
          ..write('platform: $platform, ')
          ..write('metricCategory: $metricCategory, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    labelId,
    name,
    description,
    kpiType,
    targetValue,
    currentValue,
    longTermTarget,
    unit,
    platform,
    metricCategory,
    period,
    startDate,
    endDate,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KpiDefinition &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.labelId == this.labelId &&
          other.name == this.name &&
          other.description == this.description &&
          other.kpiType == this.kpiType &&
          other.targetValue == this.targetValue &&
          other.currentValue == this.currentValue &&
          other.longTermTarget == this.longTermTarget &&
          other.unit == this.unit &&
          other.platform == this.platform &&
          other.metricCategory == this.metricCategory &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class KpiDefinitionsCompanion extends UpdateCompanion<KpiDefinition> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> labelId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> kpiType;
  final Value<double> targetValue;
  final Value<double> currentValue;
  final Value<double?> longTermTarget;
  final Value<String> unit;
  final Value<String> platform;
  final Value<String> metricCategory;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const KpiDefinitionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.kpiType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.longTermTarget = const Value.absent(),
    this.unit = const Value.absent(),
    this.platform = const Value.absent(),
    this.metricCategory = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KpiDefinitionsCompanion.insert({
    required String id,
    required String userId,
    this.labelId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required String kpiType,
    required double targetValue,
    this.currentValue = const Value.absent(),
    this.longTermTarget = const Value.absent(),
    this.unit = const Value.absent(),
    this.platform = const Value.absent(),
    this.metricCategory = const Value.absent(),
    required String period,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       kpiType = Value(kpiType),
       targetValue = Value(targetValue),
       period = Value(period),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KpiDefinition> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? labelId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? kpiType,
    Expression<double>? targetValue,
    Expression<double>? currentValue,
    Expression<double>? longTermTarget,
    Expression<String>? unit,
    Expression<String>? platform,
    Expression<String>? metricCategory,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (labelId != null) 'label_id': labelId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (kpiType != null) 'kpi_type': kpiType,
      if (targetValue != null) 'target_value': targetValue,
      if (currentValue != null) 'current_value': currentValue,
      if (longTermTarget != null) 'long_term_target': longTermTarget,
      if (unit != null) 'unit': unit,
      if (platform != null) 'platform': platform,
      if (metricCategory != null) 'metric_category': metricCategory,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KpiDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? labelId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? kpiType,
    Value<double>? targetValue,
    Value<double>? currentValue,
    Value<double?>? longTermTarget,
    Value<String>? unit,
    Value<String>? platform,
    Value<String>? metricCategory,
    Value<String>? period,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return KpiDefinitionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      labelId: labelId ?? this.labelId,
      name: name ?? this.name,
      description: description ?? this.description,
      kpiType: kpiType ?? this.kpiType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      longTermTarget: longTermTarget ?? this.longTermTarget,
      unit: unit ?? this.unit,
      platform: platform ?? this.platform,
      metricCategory: metricCategory ?? this.metricCategory,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<String>(labelId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (kpiType.present) {
      map['kpi_type'] = Variable<String>(kpiType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (longTermTarget.present) {
      map['long_term_target'] = Variable<double>(longTermTarget.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (metricCategory.present) {
      map['metric_category'] = Variable<String>(metricCategory.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KpiDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('labelId: $labelId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('kpiType: $kpiType, ')
          ..write('targetValue: $targetValue, ')
          ..write('currentValue: $currentValue, ')
          ..write('longTermTarget: $longTermTarget, ')
          ..write('unit: $unit, ')
          ..write('platform: $platform, ')
          ..write('metricCategory: $metricCategory, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskId,
    fileName,
    filePath,
    remoteUrl,
    mimeType,
    fileSize,
    syncStatus,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String userId;
  final String taskId;
  final String fileName;
  final String filePath;
  final String? remoteUrl;
  final String mimeType;
  final int fileSize;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const Attachment({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.fileName,
    required this.filePath,
    this.remoteUrl,
    required this.mimeType,
    required this.fileSize,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_id'] = Variable<String>(taskId);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['file_size'] = Variable<int>(fileSize);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      taskId: Value(taskId),
      fileName: Value(fileName),
      filePath: Value(filePath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      mimeType: Value(mimeType),
      fileSize: Value(fileSize),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskId': serializer.toJson<String>(taskId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileSize': serializer.toJson<int>(fileSize),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Attachment copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? fileName,
    String? filePath,
    Value<String?> remoteUrl = const Value.absent(),
    String? mimeType,
    int? fileSize,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => Attachment(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskId: taskId ?? this.taskId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    mimeType: mimeType ?? this.mimeType,
    fileSize: fileSize ?? this.fileSize,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskId,
    fileName,
    filePath,
    remoteUrl,
    mimeType,
    fileSize,
    syncStatus,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskId == this.taskId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.remoteUrl == this.remoteUrl &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskId;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String?> remoteUrl;
  final Value<String> mimeType;
  final Value<int> fileSize;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String userId,
    required String taskId,
    required String fileName,
    required String filePath,
    this.remoteUrl = const Value.absent(),
    required String mimeType,
    required int fileSize,
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskId = Value(taskId),
       fileName = Value(fileName),
       filePath = Value(filePath),
       mimeType = Value(mimeType),
       fileSize = Value(fileSize),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? remoteUrl,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskId,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String?>? remoteUrl,
    Value<String>? mimeType,
    Value<int>? fileSize,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskId: $taskId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncTableNameMeta = const VerificationMeta(
    'syncTableName',
  );
  @override
  late final GeneratedColumn<String> syncTableName = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptedAtMeta = const VerificationMeta(
    'lastAttemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptedAt =
      GeneratedColumn<DateTime>(
        'last_attempted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncTableName,
    recordId,
    operation,
    payloadJson,
    retryCount,
    createdAt,
    lastAttemptedAt,
    errorMessage,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _syncTableNameMeta,
        syncTableName.isAcceptableOrUnknown(
          data['table_name']!,
          _syncTableNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncTableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempted_at')) {
      context.handle(
        _lastAttemptedAtMeta,
        lastAttemptedAt.isAcceptableOrUnknown(
          data['last_attempted_at']!,
          _lastAttemptedAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncTableName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempted_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final String id;
  final String syncTableName;
  final String recordId;
  final String operation;
  final String payloadJson;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptedAt;
  final String? errorMessage;
  final String status;
  const SyncQueueItem({
    required this.id,
    required this.syncTableName,
    required this.recordId,
    required this.operation,
    required this.payloadJson,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptedAt,
    this.errorMessage,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(syncTableName);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptedAt != null) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      syncTableName: Value(syncTableName),
      recordId: Value(recordId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptedAt: lastAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptedAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      status: Value(status),
    );
  }

  factory SyncQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<String>(json['id']),
      syncTableName: serializer.fromJson<String>(json['syncTableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptedAt: serializer.fromJson<DateTime?>(json['lastAttemptedAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncTableName': serializer.toJson<String>(syncTableName),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptedAt': serializer.toJson<DateTime?>(lastAttemptedAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueItem copyWith({
    String? id,
    String? syncTableName,
    String? recordId,
    String? operation,
    String? payloadJson,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttemptedAt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    String? status,
  }) => SyncQueueItem(
    id: id ?? this.id,
    syncTableName: syncTableName ?? this.syncTableName,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptedAt: lastAttemptedAt.present
        ? lastAttemptedAt.value
        : this.lastAttemptedAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    status: status ?? this.status,
  );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      syncTableName: data.syncTableName.present
          ? data.syncTableName.value
          : this.syncTableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptedAt: data.lastAttemptedAt.present
          ? data.lastAttemptedAt.value
          : this.lastAttemptedAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncTableName,
    recordId,
    operation,
    payloadJson,
    retryCount,
    createdAt,
    lastAttemptedAt,
    errorMessage,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.syncTableName == this.syncTableName &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptedAt == this.lastAttemptedAt &&
          other.errorMessage == this.errorMessage &&
          other.status == this.status);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<String> id;
  final Value<String> syncTableName;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptedAt;
  final Value<String?> errorMessage;
  final Value<String> status;
  final Value<int> rowid;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.syncTableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptedAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    required String id,
    required String syncTableName,
    required String recordId,
    required String operation,
    required String payloadJson,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptedAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       syncTableName = Value(syncTableName),
       recordId = Value(recordId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<String>? id,
    Expression<String>? syncTableName,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptedAt,
    Expression<String>? errorMessage,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncTableName != null) 'table_name': syncTableName,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptedAt != null) 'last_attempted_at': lastAttemptedAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? syncTableName,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptedAt,
    Value<String?>? errorMessage,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      syncTableName: syncTableName ?? this.syncTableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncTableName.present) {
      map['table_name'] = Variable<String>(syncTableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptedAt.present) {
      map['last_attempted_at'] = Variable<DateTime>(lastAttemptedAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTableTable extends NotificationSettingsTable
    with
        TableInfo<
          $NotificationSettingsTableTable,
          NotificationSettingsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourlyRemindersEnabledMeta =
      const VerificationMeta('hourlyRemindersEnabled');
  @override
  late final GeneratedColumn<bool> hourlyRemindersEnabled =
      GeneratedColumn<bool>(
        'hourly_reminders_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hourly_reminders_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _activeHoursStartMeta = const VerificationMeta(
    'activeHoursStart',
  );
  @override
  late final GeneratedColumn<String> activeHoursStart = GeneratedColumn<String>(
    'active_hours_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _activeHoursEndMeta = const VerificationMeta(
    'activeHoursEnd',
  );
  @override
  late final GeneratedColumn<String> activeHoursEnd = GeneratedColumn<String>(
    'active_hours_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _activeDaysMeta = const VerificationMeta(
    'activeDays',
  );
  @override
  late final GeneratedColumn<String> activeDays = GeneratedColumn<String>(
    'active_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1,2,3,4,5,6,7'),
  );
  static const VerificationMeta _quietHoursEnabledMeta = const VerificationMeta(
    'quietHoursEnabled',
  );
  @override
  late final GeneratedColumn<bool> quietHoursEnabled = GeneratedColumn<bool>(
    'quiet_hours_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_hours_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _quietStartMeta = const VerificationMeta(
    'quietStart',
  );
  @override
  late final GeneratedColumn<String> quietStart = GeneratedColumn<String>(
    'quiet_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _quietEndMeta = const VerificationMeta(
    'quietEnd',
  );
  @override
  late final GeneratedColumn<String> quietEnd = GeneratedColumn<String>(
    'quiet_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00'),
  );
  static const VerificationMeta _dailyReportEnabledMeta =
      const VerificationMeta('dailyReportEnabled');
  @override
  late final GeneratedColumn<bool> dailyReportEnabled = GeneratedColumn<bool>(
    'daily_report_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_report_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyReportTimeMeta = const VerificationMeta(
    'dailyReportTime',
  );
  @override
  late final GeneratedColumn<String> dailyReportTime = GeneratedColumn<String>(
    'daily_report_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('21:00'),
  );
  static const VerificationMeta _motivationEnabledMeta = const VerificationMeta(
    'motivationEnabled',
  );
  @override
  late final GeneratedColumn<bool> motivationEnabled = GeneratedColumn<bool>(
    'motivation_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("motivation_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    hourlyRemindersEnabled,
    activeHoursStart,
    activeHoursEnd,
    activeDays,
    quietHoursEnabled,
    quietStart,
    quietEnd,
    dailyReportEnabled,
    dailyReportTime,
    motivationEnabled,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('hourly_reminders_enabled')) {
      context.handle(
        _hourlyRemindersEnabledMeta,
        hourlyRemindersEnabled.isAcceptableOrUnknown(
          data['hourly_reminders_enabled']!,
          _hourlyRemindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('active_hours_start')) {
      context.handle(
        _activeHoursStartMeta,
        activeHoursStart.isAcceptableOrUnknown(
          data['active_hours_start']!,
          _activeHoursStartMeta,
        ),
      );
    }
    if (data.containsKey('active_hours_end')) {
      context.handle(
        _activeHoursEndMeta,
        activeHoursEnd.isAcceptableOrUnknown(
          data['active_hours_end']!,
          _activeHoursEndMeta,
        ),
      );
    }
    if (data.containsKey('active_days')) {
      context.handle(
        _activeDaysMeta,
        activeDays.isAcceptableOrUnknown(data['active_days']!, _activeDaysMeta),
      );
    }
    if (data.containsKey('quiet_hours_enabled')) {
      context.handle(
        _quietHoursEnabledMeta,
        quietHoursEnabled.isAcceptableOrUnknown(
          data['quiet_hours_enabled']!,
          _quietHoursEnabledMeta,
        ),
      );
    }
    if (data.containsKey('quiet_start')) {
      context.handle(
        _quietStartMeta,
        quietStart.isAcceptableOrUnknown(data['quiet_start']!, _quietStartMeta),
      );
    }
    if (data.containsKey('quiet_end')) {
      context.handle(
        _quietEndMeta,
        quietEnd.isAcceptableOrUnknown(data['quiet_end']!, _quietEndMeta),
      );
    }
    if (data.containsKey('daily_report_enabled')) {
      context.handle(
        _dailyReportEnabledMeta,
        dailyReportEnabled.isAcceptableOrUnknown(
          data['daily_report_enabled']!,
          _dailyReportEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_report_time')) {
      context.handle(
        _dailyReportTimeMeta,
        dailyReportTime.isAcceptableOrUnknown(
          data['daily_report_time']!,
          _dailyReportTimeMeta,
        ),
      );
    }
    if (data.containsKey('motivation_enabled')) {
      context.handle(
        _motivationEnabledMeta,
        motivationEnabled.isAcceptableOrUnknown(
          data['motivation_enabled']!,
          _motivationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSettingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      hourlyRemindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hourly_reminders_enabled'],
      )!,
      activeHoursStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_hours_start'],
      )!,
      activeHoursEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_hours_end'],
      )!,
      activeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_days'],
      )!,
      quietHoursEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_hours_enabled'],
      )!,
      quietStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_start'],
      )!,
      quietEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_end'],
      )!,
      dailyReportEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_report_enabled'],
      )!,
      dailyReportTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_report_time'],
      )!,
      motivationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}motivation_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $NotificationSettingsTableTable createAlias(String alias) {
    return $NotificationSettingsTableTable(attachedDatabase, alias);
  }
}

class NotificationSettingsTableData extends DataClass
    implements Insertable<NotificationSettingsTableData> {
  final String id;
  final String userId;
  final bool hourlyRemindersEnabled;
  final String activeHoursStart;
  final String activeHoursEnd;
  final String activeDays;
  final bool quietHoursEnabled;
  final String quietStart;
  final String quietEnd;
  final bool dailyReportEnabled;
  final String dailyReportTime;
  final bool motivationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const NotificationSettingsTableData({
    required this.id,
    required this.userId,
    required this.hourlyRemindersEnabled,
    required this.activeHoursStart,
    required this.activeHoursEnd,
    required this.activeDays,
    required this.quietHoursEnabled,
    required this.quietStart,
    required this.quietEnd,
    required this.dailyReportEnabled,
    required this.dailyReportTime,
    required this.motivationEnabled,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['hourly_reminders_enabled'] = Variable<bool>(hourlyRemindersEnabled);
    map['active_hours_start'] = Variable<String>(activeHoursStart);
    map['active_hours_end'] = Variable<String>(activeHoursEnd);
    map['active_days'] = Variable<String>(activeDays);
    map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled);
    map['quiet_start'] = Variable<String>(quietStart);
    map['quiet_end'] = Variable<String>(quietEnd);
    map['daily_report_enabled'] = Variable<bool>(dailyReportEnabled);
    map['daily_report_time'] = Variable<String>(dailyReportTime);
    map['motivation_enabled'] = Variable<bool>(motivationEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  NotificationSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      hourlyRemindersEnabled: Value(hourlyRemindersEnabled),
      activeHoursStart: Value(activeHoursStart),
      activeHoursEnd: Value(activeHoursEnd),
      activeDays: Value(activeDays),
      quietHoursEnabled: Value(quietHoursEnabled),
      quietStart: Value(quietStart),
      quietEnd: Value(quietEnd),
      dailyReportEnabled: Value(dailyReportEnabled),
      dailyReportTime: Value(dailyReportTime),
      motivationEnabled: Value(motivationEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory NotificationSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      hourlyRemindersEnabled: serializer.fromJson<bool>(
        json['hourlyRemindersEnabled'],
      ),
      activeHoursStart: serializer.fromJson<String>(json['activeHoursStart']),
      activeHoursEnd: serializer.fromJson<String>(json['activeHoursEnd']),
      activeDays: serializer.fromJson<String>(json['activeDays']),
      quietHoursEnabled: serializer.fromJson<bool>(json['quietHoursEnabled']),
      quietStart: serializer.fromJson<String>(json['quietStart']),
      quietEnd: serializer.fromJson<String>(json['quietEnd']),
      dailyReportEnabled: serializer.fromJson<bool>(json['dailyReportEnabled']),
      dailyReportTime: serializer.fromJson<String>(json['dailyReportTime']),
      motivationEnabled: serializer.fromJson<bool>(json['motivationEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'hourlyRemindersEnabled': serializer.toJson<bool>(hourlyRemindersEnabled),
      'activeHoursStart': serializer.toJson<String>(activeHoursStart),
      'activeHoursEnd': serializer.toJson<String>(activeHoursEnd),
      'activeDays': serializer.toJson<String>(activeDays),
      'quietHoursEnabled': serializer.toJson<bool>(quietHoursEnabled),
      'quietStart': serializer.toJson<String>(quietStart),
      'quietEnd': serializer.toJson<String>(quietEnd),
      'dailyReportEnabled': serializer.toJson<bool>(dailyReportEnabled),
      'dailyReportTime': serializer.toJson<String>(dailyReportTime),
      'motivationEnabled': serializer.toJson<bool>(motivationEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  NotificationSettingsTableData copyWith({
    String? id,
    String? userId,
    bool? hourlyRemindersEnabled,
    String? activeHoursStart,
    String? activeHoursEnd,
    String? activeDays,
    bool? quietHoursEnabled,
    String? quietStart,
    String? quietEnd,
    bool? dailyReportEnabled,
    String? dailyReportTime,
    bool? motivationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => NotificationSettingsTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    hourlyRemindersEnabled:
        hourlyRemindersEnabled ?? this.hourlyRemindersEnabled,
    activeHoursStart: activeHoursStart ?? this.activeHoursStart,
    activeHoursEnd: activeHoursEnd ?? this.activeHoursEnd,
    activeDays: activeDays ?? this.activeDays,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    dailyReportEnabled: dailyReportEnabled ?? this.dailyReportEnabled,
    dailyReportTime: dailyReportTime ?? this.dailyReportTime,
    motivationEnabled: motivationEnabled ?? this.motivationEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  NotificationSettingsTableData copyWithCompanion(
    NotificationSettingsTableCompanion data,
  ) {
    return NotificationSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      hourlyRemindersEnabled: data.hourlyRemindersEnabled.present
          ? data.hourlyRemindersEnabled.value
          : this.hourlyRemindersEnabled,
      activeHoursStart: data.activeHoursStart.present
          ? data.activeHoursStart.value
          : this.activeHoursStart,
      activeHoursEnd: data.activeHoursEnd.present
          ? data.activeHoursEnd.value
          : this.activeHoursEnd,
      activeDays: data.activeDays.present
          ? data.activeDays.value
          : this.activeDays,
      quietHoursEnabled: data.quietHoursEnabled.present
          ? data.quietHoursEnabled.value
          : this.quietHoursEnabled,
      quietStart: data.quietStart.present
          ? data.quietStart.value
          : this.quietStart,
      quietEnd: data.quietEnd.present ? data.quietEnd.value : this.quietEnd,
      dailyReportEnabled: data.dailyReportEnabled.present
          ? data.dailyReportEnabled.value
          : this.dailyReportEnabled,
      dailyReportTime: data.dailyReportTime.present
          ? data.dailyReportTime.value
          : this.dailyReportTime,
      motivationEnabled: data.motivationEnabled.present
          ? data.motivationEnabled.value
          : this.motivationEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hourlyRemindersEnabled: $hourlyRemindersEnabled, ')
          ..write('activeHoursStart: $activeHoursStart, ')
          ..write('activeHoursEnd: $activeHoursEnd, ')
          ..write('activeDays: $activeDays, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('dailyReportEnabled: $dailyReportEnabled, ')
          ..write('dailyReportTime: $dailyReportTime, ')
          ..write('motivationEnabled: $motivationEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    hourlyRemindersEnabled,
    activeHoursStart,
    activeHoursEnd,
    activeDays,
    quietHoursEnabled,
    quietStart,
    quietEnd,
    dailyReportEnabled,
    dailyReportTime,
    motivationEnabled,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSettingsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.hourlyRemindersEnabled == this.hourlyRemindersEnabled &&
          other.activeHoursStart == this.activeHoursStart &&
          other.activeHoursEnd == this.activeHoursEnd &&
          other.activeDays == this.activeDays &&
          other.quietHoursEnabled == this.quietHoursEnabled &&
          other.quietStart == this.quietStart &&
          other.quietEnd == this.quietEnd &&
          other.dailyReportEnabled == this.dailyReportEnabled &&
          other.dailyReportTime == this.dailyReportTime &&
          other.motivationEnabled == this.motivationEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class NotificationSettingsTableCompanion
    extends UpdateCompanion<NotificationSettingsTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<bool> hourlyRemindersEnabled;
  final Value<String> activeHoursStart;
  final Value<String> activeHoursEnd;
  final Value<String> activeDays;
  final Value<bool> quietHoursEnabled;
  final Value<String> quietStart;
  final Value<String> quietEnd;
  final Value<bool> dailyReportEnabled;
  final Value<String> dailyReportTime;
  final Value<bool> motivationEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const NotificationSettingsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.hourlyRemindersEnabled = const Value.absent(),
    this.activeHoursStart = const Value.absent(),
    this.activeHoursEnd = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.dailyReportEnabled = const Value.absent(),
    this.dailyReportTime = const Value.absent(),
    this.motivationEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSettingsTableCompanion.insert({
    required String id,
    required String userId,
    this.hourlyRemindersEnabled = const Value.absent(),
    this.activeHoursStart = const Value.absent(),
    this.activeHoursEnd = const Value.absent(),
    this.activeDays = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.dailyReportEnabled = const Value.absent(),
    this.dailyReportTime = const Value.absent(),
    this.motivationEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotificationSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<bool>? hourlyRemindersEnabled,
    Expression<String>? activeHoursStart,
    Expression<String>? activeHoursEnd,
    Expression<String>? activeDays,
    Expression<bool>? quietHoursEnabled,
    Expression<String>? quietStart,
    Expression<String>? quietEnd,
    Expression<bool>? dailyReportEnabled,
    Expression<String>? dailyReportTime,
    Expression<bool>? motivationEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (hourlyRemindersEnabled != null)
        'hourly_reminders_enabled': hourlyRemindersEnabled,
      if (activeHoursStart != null) 'active_hours_start': activeHoursStart,
      if (activeHoursEnd != null) 'active_hours_end': activeHoursEnd,
      if (activeDays != null) 'active_days': activeDays,
      if (quietHoursEnabled != null) 'quiet_hours_enabled': quietHoursEnabled,
      if (quietStart != null) 'quiet_start': quietStart,
      if (quietEnd != null) 'quiet_end': quietEnd,
      if (dailyReportEnabled != null)
        'daily_report_enabled': dailyReportEnabled,
      if (dailyReportTime != null) 'daily_report_time': dailyReportTime,
      if (motivationEnabled != null) 'motivation_enabled': motivationEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<bool>? hourlyRemindersEnabled,
    Value<String>? activeHoursStart,
    Value<String>? activeHoursEnd,
    Value<String>? activeDays,
    Value<bool>? quietHoursEnabled,
    Value<String>? quietStart,
    Value<String>? quietEnd,
    Value<bool>? dailyReportEnabled,
    Value<String>? dailyReportTime,
    Value<bool>? motivationEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return NotificationSettingsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hourlyRemindersEnabled:
          hourlyRemindersEnabled ?? this.hourlyRemindersEnabled,
      activeHoursStart: activeHoursStart ?? this.activeHoursStart,
      activeHoursEnd: activeHoursEnd ?? this.activeHoursEnd,
      activeDays: activeDays ?? this.activeDays,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      dailyReportEnabled: dailyReportEnabled ?? this.dailyReportEnabled,
      dailyReportTime: dailyReportTime ?? this.dailyReportTime,
      motivationEnabled: motivationEnabled ?? this.motivationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hourlyRemindersEnabled.present) {
      map['hourly_reminders_enabled'] = Variable<bool>(
        hourlyRemindersEnabled.value,
      );
    }
    if (activeHoursStart.present) {
      map['active_hours_start'] = Variable<String>(activeHoursStart.value);
    }
    if (activeHoursEnd.present) {
      map['active_hours_end'] = Variable<String>(activeHoursEnd.value);
    }
    if (activeDays.present) {
      map['active_days'] = Variable<String>(activeDays.value);
    }
    if (quietHoursEnabled.present) {
      map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled.value);
    }
    if (quietStart.present) {
      map['quiet_start'] = Variable<String>(quietStart.value);
    }
    if (quietEnd.present) {
      map['quiet_end'] = Variable<String>(quietEnd.value);
    }
    if (dailyReportEnabled.present) {
      map['daily_report_enabled'] = Variable<bool>(dailyReportEnabled.value);
    }
    if (dailyReportTime.present) {
      map['daily_report_time'] = Variable<String>(dailyReportTime.value);
    }
    if (motivationEnabled.present) {
      map['motivation_enabled'] = Variable<bool>(motivationEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hourlyRemindersEnabled: $hourlyRemindersEnabled, ')
          ..write('activeHoursStart: $activeHoursStart, ')
          ..write('activeHoursEnd: $activeHoursEnd, ')
          ..write('activeDays: $activeDays, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('dailyReportEnabled: $dailyReportEnabled, ')
          ..write('dailyReportTime: $dailyReportTime, ')
          ..write('motivationEnabled: $motivationEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    avatarUrl,
    timezone,
    settingsJson,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String timezone;
  final String? settingsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;
  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    required this.timezone,
    this.settingsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || settingsJson != null) {
      map['settings_json'] = Variable<String>(settingsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      timezone: Value(timezone),
      settingsJson: settingsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(settingsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isDeleted: Value(isDeleted),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      timezone: serializer.fromJson<String>(json['timezone']),
      settingsJson: serializer.fromJson<String?>(json['settingsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'timezone': serializer.toJson<String>(timezone),
      'settingsJson': serializer.toJson<String?>(settingsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  UserProfile copyWith({
    String? id,
    Value<String?> email = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    String? timezone,
    Value<String?> settingsJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) => UserProfile(
    id: id ?? this.id,
    email: email.present ? email.value : this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    timezone: timezone ?? this.timezone,
    settingsJson: settingsJson.present ? settingsJson.value : this.settingsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('timezone: $timezone, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    displayName,
    avatarUrl,
    timezone,
    settingsJson,
    createdAt,
    updatedAt,
    version,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.timezone == this.timezone &&
          other.settingsJson == this.settingsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isDeleted == this.isDeleted);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String?> email;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<String> timezone;
  final Value<String?> settingsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.timezone = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.timezone = const Value.absent(),
    this.settingsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? timezone,
    Expression<String>? settingsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (timezone != null) 'timezone': timezone,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String?>? email,
    Value<String?>? displayName,
    Value<String?>? avatarUrl,
    Value<String>? timezone,
    Value<String?>? settingsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('timezone: $timezone, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $RecurrenceRulesTable recurrenceRules = $RecurrenceRulesTable(
    this,
  );
  late final $TaskOccurrencesTable taskOccurrences = $TaskOccurrencesTable(
    this,
  );
  late final $CompletionEventsTable completionEvents = $CompletionEventsTable(
    this,
  );
  late final $TimerSessionsTable timerSessions = $TimerSessionsTable(this);
  late final $KpiDefinitionsTable kpiDefinitions = $KpiDefinitionsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $NotificationSettingsTableTable notificationSettingsTable =
      $NotificationSettingsTableTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final LabelsDao labelsDao = LabelsDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final OccurrencesDao occurrencesDao = OccurrencesDao(
    this as AppDatabase,
  );
  late final TimerDao timerDao = TimerDao(this as AppDatabase);
  late final KpiDao kpiDao = KpiDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    labels,
    tasks,
    recurrenceRules,
    taskOccurrences,
    completionEvents,
    timerSessions,
    kpiDefinitions,
    attachments,
    syncQueueItems,
    notificationSettingsTable,
    userProfiles,
  ];
}

typedef $$LabelsTableCreateCompanionBuilder = LabelsCompanion Function({
  required String id,
  required String userId,
  Value<String?> parentId,
  required String name,
  Value<String> iconName,
  Value<String> color,
  Value<int> sortOrder,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$LabelsTableUpdateCompanionBuilder = LabelsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> parentId,
  Value<String> name,
  Value<String> iconName,
  Value<String> color,
  Value<int> sortOrder,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$LabelsTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTable,
          Label,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (Label, BaseReferences<_$AppDatabase, $LabelsTable, Label>),
          Label,
          PrefetchHooks Function()
        > {
  $$LabelsTableTableManager(_$AppDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion(
                id: id,
                userId: userId,
                parentId: parentId,
                name: name,
                iconName: iconName,
                color: color,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> parentId = const Value.absent(),
                required String name,
                Value<String> iconName = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion.insert(
                id: id,
                userId: userId,
                parentId: parentId,
                name: name,
                iconName: iconName,
                color: color,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LabelsTable, Label>(table),
                  BaseReferences<_$AppDatabase, $LabelsTable, Label>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTable,
      Label,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (Label, BaseReferences<_$AppDatabase, $LabelsTable, Label>),
      Label,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String userId,
  Value<String?> labelId,
  required String title,
  Value<String?> description,
  Value<String?> iconName,
  Value<String?> imagePath,
  Value<String?> url,
  Value<String?> category,
  Value<String> status,
  Value<String> priority,
  Value<bool> hasTimeTracking,
  Value<int?> estimatedMinutes,
  Value<String?> recurrenceRuleId,
  Value<DateTime?> scheduledDate,
  Value<DateTime?> dueDate,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> labelId,
  Value<String> title,
  Value<String?> description,
  Value<String?> iconName,
  Value<String?> imagePath,
  Value<String?> url,
  Value<String?> category,
  Value<String> status,
  Value<String> priority,
  Value<bool> hasTimeTracking,
  Value<int?> estimatedMinutes,
  Value<String?> recurrenceRuleId,
  Value<DateTime?> scheduledDate,
  Value<DateTime?> dueDate,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> version,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasTimeTracking => $composableBuilder(
    column: $table.hasTimeTracking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasTimeTracking => $composableBuilder(
    column: $table.hasTimeTracking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get hasTimeTracking => $composableBuilder(
    column: $table.hasTimeTracking,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> labelId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> hasTimeTracking = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                userId: userId,
                labelId: labelId,
                title: title,
                description: description,
                iconName: iconName,
                imagePath: imagePath,
                url: url,
                category: category,
                status: status,
                priority: priority,
                hasTimeTracking: hasTimeTracking,
                estimatedMinutes: estimatedMinutes,
                recurrenceRuleId: recurrenceRuleId,
                scheduledDate: scheduledDate,
                dueDate: dueDate,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> labelId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> hasTimeTracking = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                userId: userId,
                labelId: labelId,
                title: title,
                description: description,
                iconName: iconName,
                imagePath: imagePath,
                url: url,
                category: category,
                status: status,
                priority: priority,
                hasTimeTracking: hasTimeTracking,
                estimatedMinutes: estimatedMinutes,
                recurrenceRuleId: recurrenceRuleId,
                scheduledDate: scheduledDate,
                dueDate: dueDate,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$RecurrenceRulesTableCreateCompanionBuilder =
    RecurrenceRulesCompanion Function({
      required String id,
      required String userId,
      required String type,
      Value<String?> daysOfWeek,
      Value<int?> intervalDays,
      Value<int?> intervalMonths,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<int?> maxOccurrences,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$RecurrenceRulesTableUpdateCompanionBuilder =
    RecurrenceRulesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String?> daysOfWeek,
      Value<int?> intervalDays,
      Value<int?> intervalMonths,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<int?> maxOccurrences,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$RecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxOccurrences => $composableBuilder(
    column: $table.maxOccurrences,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxOccurrences => $composableBuilder(
    column: $table.maxOccurrences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get maxOccurrences => $composableBuilder(
    column: $table.maxOccurrences,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$RecurrenceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurrenceRulesTable,
          RecurrenceRule,
          $$RecurrenceRulesTableFilterComposer,
          $$RecurrenceRulesTableOrderingComposer,
          $$RecurrenceRulesTableAnnotationComposer,
          $$RecurrenceRulesTableCreateCompanionBuilder,
          $$RecurrenceRulesTableUpdateCompanionBuilder,
          (
            RecurrenceRule,
            BaseReferences<
              _$AppDatabase,
              $RecurrenceRulesTable,
              RecurrenceRule
            >,
          ),
          RecurrenceRule,
          PrefetchHooks Function()
        > {
  $$RecurrenceRulesTableTableManager(
    _$AppDatabase db,
    $RecurrenceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> daysOfWeek = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> maxOccurrences = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRulesCompanion(
                id: id,
                userId: userId,
                type: type,
                daysOfWeek: daysOfWeek,
                intervalDays: intervalDays,
                intervalMonths: intervalMonths,
                startDate: startDate,
                endDate: endDate,
                maxOccurrences: maxOccurrences,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                Value<String?> daysOfWeek = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> maxOccurrences = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRulesCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                daysOfWeek: daysOfWeek,
                intervalDays: intervalDays,
                intervalMonths: intervalMonths,
                startDate: startDate,
                endDate: endDate,
                maxOccurrences: maxOccurrences,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurrenceRulesTable, RecurrenceRule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecurrenceRulesTable,
                    RecurrenceRule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurrenceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurrenceRulesTable,
      RecurrenceRule,
      $$RecurrenceRulesTableFilterComposer,
      $$RecurrenceRulesTableOrderingComposer,
      $$RecurrenceRulesTableAnnotationComposer,
      $$RecurrenceRulesTableCreateCompanionBuilder,
      $$RecurrenceRulesTableUpdateCompanionBuilder,
      (
        RecurrenceRule,
        BaseReferences<_$AppDatabase, $RecurrenceRulesTable, RecurrenceRule>,
      ),
      RecurrenceRule,
      PrefetchHooks Function()
    >;
typedef $$TaskOccurrencesTableCreateCompanionBuilder =
    TaskOccurrencesCompanion Function({
      required String id,
      required String userId,
      required String taskId,
      required DateTime occurrenceDate,
      Value<String> status,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TaskOccurrencesTableUpdateCompanionBuilder =
    TaskOccurrencesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> taskId,
      Value<DateTime> occurrenceDate,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$TaskOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskOccurrencesTable> {
  $$TaskOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskOccurrencesTable> {
  $$TaskOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskOccurrencesTable> {
  $$TaskOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TaskOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskOccurrencesTable,
          TaskOccurrence,
          $$TaskOccurrencesTableFilterComposer,
          $$TaskOccurrencesTableOrderingComposer,
          $$TaskOccurrencesTableAnnotationComposer,
          $$TaskOccurrencesTableCreateCompanionBuilder,
          $$TaskOccurrencesTableUpdateCompanionBuilder,
          (
            TaskOccurrence,
            BaseReferences<
              _$AppDatabase,
              $TaskOccurrencesTable,
              TaskOccurrence
            >,
          ),
          TaskOccurrence,
          PrefetchHooks Function()
        > {
  $$TaskOccurrencesTableTableManager(
    _$AppDatabase db,
    $TaskOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskOccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<DateTime> occurrenceDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskOccurrencesCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceDate: occurrenceDate,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskId,
                required DateTime occurrenceDate,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskOccurrencesCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceDate: occurrenceDate,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskOccurrencesTable, TaskOccurrence>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TaskOccurrencesTable,
                    TaskOccurrence
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskOccurrencesTable,
      TaskOccurrence,
      $$TaskOccurrencesTableFilterComposer,
      $$TaskOccurrencesTableOrderingComposer,
      $$TaskOccurrencesTableAnnotationComposer,
      $$TaskOccurrencesTableCreateCompanionBuilder,
      $$TaskOccurrencesTableUpdateCompanionBuilder,
      (
        TaskOccurrence,
        BaseReferences<_$AppDatabase, $TaskOccurrencesTable, TaskOccurrence>,
      ),
      TaskOccurrence,
      PrefetchHooks Function()
    >;
typedef $$CompletionEventsTableCreateCompanionBuilder =
    CompletionEventsCompanion Function({
      required String id,
      required String userId,
      required String taskId,
      Value<String?> occurrenceId,
      required DateTime completedAt,
      Value<String?> notes,
      required DateTime createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CompletionEventsTableUpdateCompanionBuilder =
    CompletionEventsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> taskId,
      Value<String?> occurrenceId,
      Value<DateTime> completedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$CompletionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CompletionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionEventsTable,
          CompletionEvent,
          $$CompletionEventsTableFilterComposer,
          $$CompletionEventsTableOrderingComposer,
          $$CompletionEventsTableAnnotationComposer,
          $$CompletionEventsTableCreateCompanionBuilder,
          $$CompletionEventsTableUpdateCompanionBuilder,
          (
            CompletionEvent,
            BaseReferences<
              _$AppDatabase,
              $CompletionEventsTable,
              CompletionEvent
            >,
          ),
          CompletionEvent,
          PrefetchHooks Function()
        > {
  $$CompletionEventsTableTableManager(
    _$AppDatabase db,
    $CompletionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceId: occurrenceId,
                completedAt: completedAt,
                notes: notes,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskId,
                Value<String?> occurrenceId = const Value.absent(),
                required DateTime completedAt,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceId: occurrenceId,
                completedAt: completedAt,
                notes: notes,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionEventsTable, CompletionEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionEventsTable,
                    CompletionEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionEventsTable,
      CompletionEvent,
      $$CompletionEventsTableFilterComposer,
      $$CompletionEventsTableOrderingComposer,
      $$CompletionEventsTableAnnotationComposer,
      $$CompletionEventsTableCreateCompanionBuilder,
      $$CompletionEventsTableUpdateCompanionBuilder,
      (
        CompletionEvent,
        BaseReferences<_$AppDatabase, $CompletionEventsTable, CompletionEvent>,
      ),
      CompletionEvent,
      PrefetchHooks Function()
    >;
typedef $$TimerSessionsTableCreateCompanionBuilder =
    TimerSessionsCompanion Function({
      required String id,
      required String userId,
      required String taskId,
      Value<String?> occurrenceId,
      required DateTime startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> endedAt,
      Value<int> elapsedSeconds,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TimerSessionsTableUpdateCompanionBuilder =
    TimerSessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> taskId,
      Value<String?> occurrenceId,
      Value<DateTime> startedAt,
      Value<DateTime?> pausedAt,
      Value<DateTime?> endedAt,
      Value<int> elapsedSeconds,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$TimerSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TimerSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerSessionsTable,
          TimerSession,
          $$TimerSessionsTableFilterComposer,
          $$TimerSessionsTableOrderingComposer,
          $$TimerSessionsTableAnnotationComposer,
          $$TimerSessionsTableCreateCompanionBuilder,
          $$TimerSessionsTableUpdateCompanionBuilder,
          (
            TimerSession,
            BaseReferences<_$AppDatabase, $TimerSessionsTable, TimerSession>,
          ),
          TimerSession,
          PrefetchHooks Function()
        > {
  $$TimerSessionsTableTableManager(_$AppDatabase db, $TimerSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerSessionsCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceId: occurrenceId,
                startedAt: startedAt,
                pausedAt: pausedAt,
                endedAt: endedAt,
                elapsedSeconds: elapsedSeconds,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskId,
                Value<String?> occurrenceId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerSessionsCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                occurrenceId: occurrenceId,
                startedAt: startedAt,
                pausedAt: pausedAt,
                endedAt: endedAt,
                elapsedSeconds: elapsedSeconds,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerSessionsTable, TimerSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TimerSessionsTable,
                    TimerSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerSessionsTable,
      TimerSession,
      $$TimerSessionsTableFilterComposer,
      $$TimerSessionsTableOrderingComposer,
      $$TimerSessionsTableAnnotationComposer,
      $$TimerSessionsTableCreateCompanionBuilder,
      $$TimerSessionsTableUpdateCompanionBuilder,
      (
        TimerSession,
        BaseReferences<_$AppDatabase, $TimerSessionsTable, TimerSession>,
      ),
      TimerSession,
      PrefetchHooks Function()
    >;
typedef $$KpiDefinitionsTableCreateCompanionBuilder =
    KpiDefinitionsCompanion Function({
      required String id,
      required String userId,
      Value<String?> labelId,
      required String name,
      Value<String?> description,
      required String kpiType,
      required double targetValue,
      Value<double> currentValue,
      Value<double?> longTermTarget,
      Value<String> unit,
      Value<String> platform,
      Value<String> metricCategory,
      required String period,
      required DateTime startDate,
      Value<DateTime?> endDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$KpiDefinitionsTableUpdateCompanionBuilder =
    KpiDefinitionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> labelId,
      Value<String> name,
      Value<String?> description,
      Value<String> kpiType,
      Value<double> targetValue,
      Value<double> currentValue,
      Value<double?> longTermTarget,
      Value<String> unit,
      Value<String> platform,
      Value<String> metricCategory,
      Value<String> period,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$KpiDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $KpiDefinitionsTable> {
  $$KpiDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kpiType => $composableBuilder(
    column: $table.kpiType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longTermTarget => $composableBuilder(
    column: $table.longTermTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricCategory => $composableBuilder(
    column: $table.metricCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KpiDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $KpiDefinitionsTable> {
  $$KpiDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kpiType => $composableBuilder(
    column: $table.kpiType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longTermTarget => $composableBuilder(
    column: $table.longTermTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricCategory => $composableBuilder(
    column: $table.metricCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KpiDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KpiDefinitionsTable> {
  $$KpiDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kpiType =>
      $composableBuilder(column: $table.kpiType, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get longTermTarget => $composableBuilder(
    column: $table.longTermTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get metricCategory => $composableBuilder(
    column: $table.metricCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$KpiDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KpiDefinitionsTable,
          KpiDefinition,
          $$KpiDefinitionsTableFilterComposer,
          $$KpiDefinitionsTableOrderingComposer,
          $$KpiDefinitionsTableAnnotationComposer,
          $$KpiDefinitionsTableCreateCompanionBuilder,
          $$KpiDefinitionsTableUpdateCompanionBuilder,
          (
            KpiDefinition,
            BaseReferences<_$AppDatabase, $KpiDefinitionsTable, KpiDefinition>,
          ),
          KpiDefinition,
          PrefetchHooks Function()
        > {
  $$KpiDefinitionsTableTableManager(
    _$AppDatabase db,
    $KpiDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KpiDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KpiDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KpiDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> labelId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> kpiType = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<double?> longTermTarget = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> metricCategory = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KpiDefinitionsCompanion(
                id: id,
                userId: userId,
                labelId: labelId,
                name: name,
                description: description,
                kpiType: kpiType,
                targetValue: targetValue,
                currentValue: currentValue,
                longTermTarget: longTermTarget,
                unit: unit,
                platform: platform,
                metricCategory: metricCategory,
                period: period,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> labelId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required String kpiType,
                required double targetValue,
                Value<double> currentValue = const Value.absent(),
                Value<double?> longTermTarget = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> metricCategory = const Value.absent(),
                required String period,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KpiDefinitionsCompanion.insert(
                id: id,
                userId: userId,
                labelId: labelId,
                name: name,
                description: description,
                kpiType: kpiType,
                targetValue: targetValue,
                currentValue: currentValue,
                longTermTarget: longTermTarget,
                unit: unit,
                platform: platform,
                metricCategory: metricCategory,
                period: period,
                startDate: startDate,
                endDate: endDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KpiDefinitionsTable, KpiDefinition>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $KpiDefinitionsTable,
                    KpiDefinition
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KpiDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KpiDefinitionsTable,
      KpiDefinition,
      $$KpiDefinitionsTableFilterComposer,
      $$KpiDefinitionsTableOrderingComposer,
      $$KpiDefinitionsTableAnnotationComposer,
      $$KpiDefinitionsTableCreateCompanionBuilder,
      $$KpiDefinitionsTableUpdateCompanionBuilder,
      (
        KpiDefinition,
        BaseReferences<_$AppDatabase, $KpiDefinitionsTable, KpiDefinition>,
      ),
      KpiDefinition,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String userId,
      required String taskId,
      required String fileName,
      required String filePath,
      Value<String?> remoteUrl,
      required String mimeType,
      required int fileSize,
      Value<String> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> taskId,
      Value<String> fileName,
      Value<String> filePath,
      Value<String?> remoteUrl,
      Value<String> mimeType,
      Value<int> fileSize,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                userId: userId,
                taskId: taskId,
                fileName: fileName,
                filePath: filePath,
                remoteUrl: remoteUrl,
                mimeType: mimeType,
                fileSize: fileSize,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskId,
                required String fileName,
                required String filePath,
                Value<String?> remoteUrl = const Value.absent(),
                required String mimeType,
                required int fileSize,
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                userId: userId,
                taskId: taskId,
                fileName: fileName,
                filePath: filePath,
                remoteUrl: remoteUrl,
                mimeType: mimeType,
                fileSize: fileSize,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, Attachment>(table),
                  BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueItemsTableCreateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      required String id,
      required String syncTableName,
      required String recordId,
      required String operation,
      required String payloadJson,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<DateTime?> lastAttemptedAt,
      Value<String?> errorMessage,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$SyncQueueItemsTableUpdateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      Value<String> id,
      Value<String> syncTableName,
      Value<String> recordId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptedAt,
      Value<String?> errorMessage,
      Value<String> status,
      Value<int> rowid,
    });

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptedAt => $composableBuilder(
    column: $table.lastAttemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueItemsTable,
          SyncQueueItem,
          $$SyncQueueItemsTableFilterComposer,
          $$SyncQueueItemsTableOrderingComposer,
          $$SyncQueueItemsTableAnnotationComposer,
          $$SyncQueueItemsTableCreateCompanionBuilder,
          $$SyncQueueItemsTableUpdateCompanionBuilder,
          (
            SyncQueueItem,
            BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
          ),
          SyncQueueItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueItemsTableTableManager(
    _$AppDatabase db,
    $SyncQueueItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> syncTableName = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptedAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueItemsCompanion(
                id: id,
                syncTableName: syncTableName,
                recordId: recordId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptedAt: lastAttemptedAt,
                errorMessage: errorMessage,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String syncTableName,
                required String recordId,
                required String operation,
                required String payloadJson,
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptedAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueItemsCompanion.insert(
                id: id,
                syncTableName: syncTableName,
                recordId: recordId,
                operation: operation,
                payloadJson: payloadJson,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptedAt: lastAttemptedAt,
                errorMessage: errorMessage,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueItemsTable, SyncQueueItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncQueueItemsTable,
                    SyncQueueItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueItemsTable,
      SyncQueueItem,
      $$SyncQueueItemsTableFilterComposer,
      $$SyncQueueItemsTableOrderingComposer,
      $$SyncQueueItemsTableAnnotationComposer,
      $$SyncQueueItemsTableCreateCompanionBuilder,
      $$SyncQueueItemsTableUpdateCompanionBuilder,
      (
        SyncQueueItem,
        BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
      ),
      SyncQueueItem,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableTableCreateCompanionBuilder =
    NotificationSettingsTableCompanion Function({
      required String id,
      required String userId,
      Value<bool> hourlyRemindersEnabled,
      Value<String> activeHoursStart,
      Value<String> activeHoursEnd,
      Value<String> activeDays,
      Value<bool> quietHoursEnabled,
      Value<String> quietStart,
      Value<String> quietEnd,
      Value<bool> dailyReportEnabled,
      Value<String> dailyReportTime,
      Value<bool> motivationEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$NotificationSettingsTableTableUpdateCompanionBuilder =
    NotificationSettingsTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<bool> hourlyRemindersEnabled,
      Value<String> activeHoursStart,
      Value<String> activeHoursEnd,
      Value<String> activeDays,
      Value<bool> quietHoursEnabled,
      Value<String> quietStart,
      Value<String> quietEnd,
      Value<bool> dailyReportEnabled,
      Value<String> dailyReportTime,
      Value<bool> motivationEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$NotificationSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hourlyRemindersEnabled => $composableBuilder(
    column: $table.hourlyRemindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeHoursStart => $composableBuilder(
    column: $table.activeHoursStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeHoursEnd => $composableBuilder(
    column: $table.activeHoursEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietEnd => $composableBuilder(
    column: $table.quietEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyReportEnabled => $composableBuilder(
    column: $table.dailyReportEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyReportTime => $composableBuilder(
    column: $table.dailyReportTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get motivationEnabled => $composableBuilder(
    column: $table.motivationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hourlyRemindersEnabled => $composableBuilder(
    column: $table.hourlyRemindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeHoursStart => $composableBuilder(
    column: $table.activeHoursStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeHoursEnd => $composableBuilder(
    column: $table.activeHoursEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietEnd => $composableBuilder(
    column: $table.quietEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyReportEnabled => $composableBuilder(
    column: $table.dailyReportEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyReportTime => $composableBuilder(
    column: $table.dailyReportTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get motivationEnabled => $composableBuilder(
    column: $table.motivationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTableTable> {
  $$NotificationSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get hourlyRemindersEnabled => $composableBuilder(
    column: $table.hourlyRemindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeHoursStart => $composableBuilder(
    column: $table.activeHoursStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeHoursEnd => $composableBuilder(
    column: $table.activeHoursEnd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeDays => $composableBuilder(
    column: $table.activeDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quietStart => $composableBuilder(
    column: $table.quietStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quietEnd =>
      $composableBuilder(column: $table.quietEnd, builder: (column) => column);

  GeneratedColumn<bool> get dailyReportEnabled => $composableBuilder(
    column: $table.dailyReportEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyReportTime => $composableBuilder(
    column: $table.dailyReportTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get motivationEnabled => $composableBuilder(
    column: $table.motivationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$NotificationSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTableTable,
          NotificationSettingsTableData,
          $$NotificationSettingsTableTableFilterComposer,
          $$NotificationSettingsTableTableOrderingComposer,
          $$NotificationSettingsTableTableAnnotationComposer,
          $$NotificationSettingsTableTableCreateCompanionBuilder,
          $$NotificationSettingsTableTableUpdateCompanionBuilder,
          (
            NotificationSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTableTable,
              NotificationSettingsTableData
            >,
          ),
          NotificationSettingsTableData,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> hourlyRemindersEnabled = const Value.absent(),
                Value<String> activeHoursStart = const Value.absent(),
                Value<String> activeHoursEnd = const Value.absent(),
                Value<String> activeDays = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<String> quietStart = const Value.absent(),
                Value<String> quietEnd = const Value.absent(),
                Value<bool> dailyReportEnabled = const Value.absent(),
                Value<String> dailyReportTime = const Value.absent(),
                Value<bool> motivationEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsTableCompanion(
                id: id,
                userId: userId,
                hourlyRemindersEnabled: hourlyRemindersEnabled,
                activeHoursStart: activeHoursStart,
                activeHoursEnd: activeHoursEnd,
                activeDays: activeDays,
                quietHoursEnabled: quietHoursEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                dailyReportEnabled: dailyReportEnabled,
                dailyReportTime: dailyReportTime,
                motivationEnabled: motivationEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<bool> hourlyRemindersEnabled = const Value.absent(),
                Value<String> activeHoursStart = const Value.absent(),
                Value<String> activeHoursEnd = const Value.absent(),
                Value<String> activeDays = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<String> quietStart = const Value.absent(),
                Value<String> quietEnd = const Value.absent(),
                Value<bool> dailyReportEnabled = const Value.absent(),
                Value<String> dailyReportTime = const Value.absent(),
                Value<bool> motivationEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsTableCompanion.insert(
                id: id,
                userId: userId,
                hourlyRemindersEnabled: hourlyRemindersEnabled,
                activeHoursStart: activeHoursStart,
                activeHoursEnd: activeHoursEnd,
                activeDays: activeDays,
                quietHoursEnabled: quietHoursEnabled,
                quietStart: quietStart,
                quietEnd: quietEnd,
                dailyReportEnabled: dailyReportEnabled,
                dailyReportTime: dailyReportTime,
                motivationEnabled: motivationEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $NotificationSettingsTableTable,
                    NotificationSettingsTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationSettingsTableTable,
                    NotificationSettingsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTableTable,
      NotificationSettingsTableData,
      $$NotificationSettingsTableTableFilterComposer,
      $$NotificationSettingsTableTableOrderingComposer,
      $$NotificationSettingsTableTableAnnotationComposer,
      $$NotificationSettingsTableTableCreateCompanionBuilder,
      $$NotificationSettingsTableTableUpdateCompanionBuilder,
      (
        NotificationSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTableTable,
          NotificationSettingsTableData
        >,
      ),
      NotificationSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      Value<String?> email,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<String> timezone,
      Value<String?> settingsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String?> email,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<String> timezone,
      Value<String?> settingsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> settingsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                timezone: timezone,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> settingsJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                avatarUrl: avatarUrl,
                timezone: timezone,
                settingsJson: settingsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$RecurrenceRulesTableTableManager get recurrenceRules =>
      $$RecurrenceRulesTableTableManager(_db, _db.recurrenceRules);
  $$TaskOccurrencesTableTableManager get taskOccurrences =>
      $$TaskOccurrencesTableTableManager(_db, _db.taskOccurrences);
  $$CompletionEventsTableTableManager get completionEvents =>
      $$CompletionEventsTableTableManager(_db, _db.completionEvents);
  $$TimerSessionsTableTableManager get timerSessions =>
      $$TimerSessionsTableTableManager(_db, _db.timerSessions);
  $$KpiDefinitionsTableTableManager get kpiDefinitions =>
      $$KpiDefinitionsTableTableManager(_db, _db.kpiDefinitions);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$NotificationSettingsTableTableTableManager get notificationSettingsTable =>
      $$NotificationSettingsTableTableTableManager(
        _db,
        _db.notificationSettingsTable,
      );
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
