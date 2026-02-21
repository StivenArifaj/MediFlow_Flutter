// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('patient'));
  static const VerificationMeta _isPremiumMeta =
      const VerificationMeta('isPremium');
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
      'is_premium', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_premium" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _isDarkModeMeta =
      const VerificationMeta('isDarkMode');
  @override
  late final GeneratedColumn<bool> isDarkMode = GeneratedColumn<bool>(
      'is_dark_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_dark_mode" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _firebaseUidMeta =
      const VerificationMeta('firebaseUid');
  @override
  late final GeneratedColumn<String> firebaseUid = GeneratedColumn<String>(
      'firebase_uid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        passwordHash,
        role,
        isPremium,
        language,
        isDarkMode,
        notificationsEnabled,
        createdAt,
        firebaseUid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_premium')) {
      context.handle(_isPremiumMeta,
          isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
          _isDarkModeMeta,
          isDarkMode.isAcceptableOrUnknown(
              data['is_dark_mode']!, _isDarkModeMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('firebase_uid')) {
      context.handle(
          _firebaseUidMeta,
          firebaseUid.isAcceptableOrUnknown(
              data['firebase_uid']!, _firebaseUidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isPremium: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_premium'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      isDarkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dark_mode'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      firebaseUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firebase_uid']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final String role;
  final bool isPremium;
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final String? firebaseUid;
  const User(
      {required this.id,
      required this.name,
      required this.email,
      required this.passwordHash,
      required this.role,
      required this.isPremium,
      required this.language,
      required this.isDarkMode,
      required this.notificationsEnabled,
      required this.createdAt,
      this.firebaseUid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['role'] = Variable<String>(role);
    map['is_premium'] = Variable<bool>(isPremium);
    map['language'] = Variable<String>(language);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || firebaseUid != null) {
      map['firebase_uid'] = Variable<String>(firebaseUid);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      passwordHash: Value(passwordHash),
      role: Value(role),
      isPremium: Value(isPremium),
      language: Value(language),
      isDarkMode: Value(isDarkMode),
      notificationsEnabled: Value(notificationsEnabled),
      createdAt: Value(createdAt),
      firebaseUid: firebaseUid == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseUid),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      role: serializer.fromJson<String>(json['role']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      language: serializer.fromJson<String>(json['language']),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      firebaseUid: serializer.fromJson<String?>(json['firebaseUid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'role': serializer.toJson<String>(role),
      'isPremium': serializer.toJson<bool>(isPremium),
      'language': serializer.toJson<String>(language),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'firebaseUid': serializer.toJson<String?>(firebaseUid),
    };
  }

  User copyWith(
          {int? id,
          String? name,
          String? email,
          String? passwordHash,
          String? role,
          bool? isPremium,
          String? language,
          bool? isDarkMode,
          bool? notificationsEnabled,
          DateTime? createdAt,
          Value<String?> firebaseUid = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        role: role ?? this.role,
        isPremium: isPremium ?? this.isPremium,
        language: language ?? this.language,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        createdAt: createdAt ?? this.createdAt,
        firebaseUid: firebaseUid.present ? firebaseUid.value : this.firebaseUid,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      role: data.role.present ? data.role.value : this.role,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      language: data.language.present ? data.language.value : this.language,
      isDarkMode:
          data.isDarkMode.present ? data.isDarkMode.value : this.isDarkMode,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      firebaseUid:
          data.firebaseUid.present ? data.firebaseUid.value : this.firebaseUid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('isPremium: $isPremium, ')
          ..write('language: $language, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('firebaseUid: $firebaseUid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      email,
      passwordHash,
      role,
      isPremium,
      language,
      isDarkMode,
      notificationsEnabled,
      createdAt,
      firebaseUid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.role == this.role &&
          other.isPremium == this.isPremium &&
          other.language == this.language &&
          other.isDarkMode == this.isDarkMode &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.createdAt == this.createdAt &&
          other.firebaseUid == this.firebaseUid);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> role;
  final Value<bool> isPremium;
  final Value<String> language;
  final Value<bool> isDarkMode;
  final Value<bool> notificationsEnabled;
  final Value<DateTime> createdAt;
  final Value<String?> firebaseUid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.role = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.language = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.firebaseUid = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String passwordHash,
    this.role = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.language = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    required DateTime createdAt,
    this.firebaseUid = const Value.absent(),
  })  : name = Value(name),
        email = Value(email),
        passwordHash = Value(passwordHash),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? role,
    Expression<bool>? isPremium,
    Expression<String>? language,
    Expression<bool>? isDarkMode,
    Expression<bool>? notificationsEnabled,
    Expression<DateTime>? createdAt,
    Expression<String>? firebaseUid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (role != null) 'role': role,
      if (isPremium != null) 'is_premium': isPremium,
      if (language != null) 'language': language,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (firebaseUid != null) 'firebase_uid': firebaseUid,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<String>? role,
      Value<bool>? isPremium,
      Value<String>? language,
      Value<bool>? isDarkMode,
      Value<bool>? notificationsEnabled,
      Value<DateTime>? createdAt,
      Value<String?>? firebaseUid}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (firebaseUid.present) {
      map['firebase_uid'] = Variable<String>(firebaseUid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('role: $role, ')
          ..write('isPremium: $isPremium, ')
          ..write('language: $language, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('firebaseUid: $firebaseUid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verifiedNameMeta =
      const VerificationMeta('verifiedName');
  @override
  late final GeneratedColumn<String> verifiedName = GeneratedColumn<String>(
      'verified_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandNameMeta =
      const VerificationMeta('brandName');
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
      'brand_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genericNameMeta =
      const VerificationMeta('genericName');
  @override
  late final GeneratedColumn<String> genericName = GeneratedColumn<String>(
      'generic_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
      'strength', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
      'form', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _apiSourceMeta =
      const VerificationMeta('apiSource');
  @override
  late final GeneratedColumn<String> apiSource = GeneratedColumn<String>(
      'api_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        verifiedName,
        brandName,
        genericName,
        manufacturer,
        strength,
        form,
        category,
        quantity,
        notes,
        imageUrl,
        apiSource,
        expiryDate,
        createdAt,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(Insertable<Medicine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('verified_name')) {
      context.handle(
          _verifiedNameMeta,
          verifiedName.isAcceptableOrUnknown(
              data['verified_name']!, _verifiedNameMeta));
    } else if (isInserting) {
      context.missing(_verifiedNameMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(_brandNameMeta,
          brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta));
    }
    if (data.containsKey('generic_name')) {
      context.handle(
          _genericNameMeta,
          genericName.isAcceptableOrUnknown(
              data['generic_name']!, _genericNameMeta));
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
    }
    if (data.containsKey('form')) {
      context.handle(
          _formMeta, form.isAcceptableOrUnknown(data['form']!, _formMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('api_source')) {
      context.handle(_apiSourceMeta,
          apiSource.isAcceptableOrUnknown(data['api_source']!, _apiSourceMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      verifiedName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verified_name'])!,
      brandName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand_name']),
      genericName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}generic_name']),
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strength']),
      form: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}form']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      apiSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_source'])!,
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final int id;
  final int userId;
  final String verifiedName;
  final String? brandName;
  final String? genericName;
  final String? manufacturer;
  final String? strength;
  final String? form;
  final String? category;
  final int? quantity;
  final String? notes;
  final String? imageUrl;
  final String apiSource;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final bool isActive;
  const Medicine(
      {required this.id,
      required this.userId,
      required this.verifiedName,
      this.brandName,
      this.genericName,
      this.manufacturer,
      this.strength,
      this.form,
      this.category,
      this.quantity,
      this.notes,
      this.imageUrl,
      required this.apiSource,
      this.expiryDate,
      required this.createdAt,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['verified_name'] = Variable<String>(verifiedName);
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    if (!nullToAbsent || genericName != null) {
      map['generic_name'] = Variable<String>(genericName);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || form != null) {
      map['form'] = Variable<String>(form);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<int>(quantity);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['api_source'] = Variable<String>(apiSource);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      userId: Value(userId),
      verifiedName: Value(verifiedName),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      genericName: genericName == null && nullToAbsent
          ? const Value.absent()
          : Value(genericName),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      form: form == null && nullToAbsent ? const Value.absent() : Value(form),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      apiSource: Value(apiSource),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      createdAt: Value(createdAt),
      isActive: Value(isActive),
    );
  }

  factory Medicine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      verifiedName: serializer.fromJson<String>(json['verifiedName']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      genericName: serializer.fromJson<String?>(json['genericName']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      strength: serializer.fromJson<String?>(json['strength']),
      form: serializer.fromJson<String?>(json['form']),
      category: serializer.fromJson<String?>(json['category']),
      quantity: serializer.fromJson<int?>(json['quantity']),
      notes: serializer.fromJson<String?>(json['notes']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      apiSource: serializer.fromJson<String>(json['apiSource']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'verifiedName': serializer.toJson<String>(verifiedName),
      'brandName': serializer.toJson<String?>(brandName),
      'genericName': serializer.toJson<String?>(genericName),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'strength': serializer.toJson<String?>(strength),
      'form': serializer.toJson<String?>(form),
      'category': serializer.toJson<String?>(category),
      'quantity': serializer.toJson<int?>(quantity),
      'notes': serializer.toJson<String?>(notes),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'apiSource': serializer.toJson<String>(apiSource),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Medicine copyWith(
          {int? id,
          int? userId,
          String? verifiedName,
          Value<String?> brandName = const Value.absent(),
          Value<String?> genericName = const Value.absent(),
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> strength = const Value.absent(),
          Value<String?> form = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<int?> quantity = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          String? apiSource,
          Value<DateTime?> expiryDate = const Value.absent(),
          DateTime? createdAt,
          bool? isActive}) =>
      Medicine(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        verifiedName: verifiedName ?? this.verifiedName,
        brandName: brandName.present ? brandName.value : this.brandName,
        genericName: genericName.present ? genericName.value : this.genericName,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        strength: strength.present ? strength.value : this.strength,
        form: form.present ? form.value : this.form,
        category: category.present ? category.value : this.category,
        quantity: quantity.present ? quantity.value : this.quantity,
        notes: notes.present ? notes.value : this.notes,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        apiSource: apiSource ?? this.apiSource,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
      );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      verifiedName: data.verifiedName.present
          ? data.verifiedName.value
          : this.verifiedName,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      genericName:
          data.genericName.present ? data.genericName.value : this.genericName,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      strength: data.strength.present ? data.strength.value : this.strength,
      form: data.form.present ? data.form.value : this.form,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      apiSource: data.apiSource.present ? data.apiSource.value : this.apiSource,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('verifiedName: $verifiedName, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('strength: $strength, ')
          ..write('form: $form, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('apiSource: $apiSource, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      verifiedName,
      brandName,
      genericName,
      manufacturer,
      strength,
      form,
      category,
      quantity,
      notes,
      imageUrl,
      apiSource,
      expiryDate,
      createdAt,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.verifiedName == this.verifiedName &&
          other.brandName == this.brandName &&
          other.genericName == this.genericName &&
          other.manufacturer == this.manufacturer &&
          other.strength == this.strength &&
          other.form == this.form &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.notes == this.notes &&
          other.imageUrl == this.imageUrl &&
          other.apiSource == this.apiSource &&
          other.expiryDate == this.expiryDate &&
          other.createdAt == this.createdAt &&
          other.isActive == this.isActive);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> verifiedName;
  final Value<String?> brandName;
  final Value<String?> genericName;
  final Value<String?> manufacturer;
  final Value<String?> strength;
  final Value<String?> form;
  final Value<String?> category;
  final Value<int?> quantity;
  final Value<String?> notes;
  final Value<String?> imageUrl;
  final Value<String> apiSource;
  final Value<DateTime?> expiryDate;
  final Value<DateTime> createdAt;
  final Value<bool> isActive;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.verifiedName = const Value.absent(),
    this.brandName = const Value.absent(),
    this.genericName = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.strength = const Value.absent(),
    this.form = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.apiSource = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MedicinesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String verifiedName,
    this.brandName = const Value.absent(),
    this.genericName = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.strength = const Value.absent(),
    this.form = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.apiSource = const Value.absent(),
    this.expiryDate = const Value.absent(),
    required DateTime createdAt,
    this.isActive = const Value.absent(),
  })  : userId = Value(userId),
        verifiedName = Value(verifiedName),
        createdAt = Value(createdAt);
  static Insertable<Medicine> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? verifiedName,
    Expression<String>? brandName,
    Expression<String>? genericName,
    Expression<String>? manufacturer,
    Expression<String>? strength,
    Expression<String>? form,
    Expression<String>? category,
    Expression<int>? quantity,
    Expression<String>? notes,
    Expression<String>? imageUrl,
    Expression<String>? apiSource,
    Expression<DateTime>? expiryDate,
    Expression<DateTime>? createdAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (verifiedName != null) 'verified_name': verifiedName,
      if (brandName != null) 'brand_name': brandName,
      if (genericName != null) 'generic_name': genericName,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (strength != null) 'strength': strength,
      if (form != null) 'form': form,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (imageUrl != null) 'image_url': imageUrl,
      if (apiSource != null) 'api_source': apiSource,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MedicinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? verifiedName,
      Value<String?>? brandName,
      Value<String?>? genericName,
      Value<String?>? manufacturer,
      Value<String?>? strength,
      Value<String?>? form,
      Value<String?>? category,
      Value<int?>? quantity,
      Value<String?>? notes,
      Value<String?>? imageUrl,
      Value<String>? apiSource,
      Value<DateTime?>? expiryDate,
      Value<DateTime>? createdAt,
      Value<bool>? isActive}) {
    return MedicinesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      verifiedName: verifiedName ?? this.verifiedName,
      brandName: brandName ?? this.brandName,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      apiSource: apiSource ?? this.apiSource,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (verifiedName.present) {
      map['verified_name'] = Variable<String>(verifiedName.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (genericName.present) {
      map['generic_name'] = Variable<String>(genericName.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (apiSource.present) {
      map['api_source'] = Variable<String>(apiSource.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('verifiedName: $verifiedName, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('strength: $strength, ')
          ..write('form: $form, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('apiSource: $apiSource, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('daily'));
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<String> days = GeneratedColumn<String>(
      'days', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationTypeMeta =
      const VerificationMeta('durationType');
  @override
  late final GeneratedColumn<String> durationType = GeneratedColumn<String>(
      'duration_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ongoing'));
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationDaysMeta =
      const VerificationMeta('durationDays');
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
      'duration_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _snoozeDurationMeta =
      const VerificationMeta('snoozeDuration');
  @override
  late final GeneratedColumn<int> snoozeDuration = GeneratedColumn<int>(
      'snooze_duration', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        medicineId,
        userId,
        time,
        frequency,
        days,
        intervalDays,
        durationType,
        endDate,
        durationDays,
        isActive,
        snoozeDuration,
        notificationId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    }
    if (data.containsKey('days')) {
      context.handle(
          _daysMeta, days.isAcceptableOrUnknown(data['days']!, _daysMeta));
    }
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    }
    if (data.containsKey('duration_type')) {
      context.handle(
          _durationTypeMeta,
          durationType.isAcceptableOrUnknown(
              data['duration_type']!, _durationTypeMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('duration_days')) {
      context.handle(
          _durationDaysMeta,
          durationDays.isAcceptableOrUnknown(
              data['duration_days']!, _durationDaysMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('snooze_duration')) {
      context.handle(
          _snoozeDurationMeta,
          snoozeDuration.isAcceptableOrUnknown(
              data['snooze_duration']!, _snoozeDurationMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}medicine_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      days: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}days']),
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days']),
      durationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}duration_type'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      durationDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_days']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      snoozeDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snooze_duration'])!,
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int medicineId;
  final int userId;
  final String time;
  final String frequency;
  final String? days;
  final int? intervalDays;
  final String durationType;
  final DateTime? endDate;
  final int? durationDays;
  final bool isActive;
  final int snoozeDuration;
  final int? notificationId;
  final DateTime createdAt;
  const Reminder(
      {required this.id,
      required this.medicineId,
      required this.userId,
      required this.time,
      required this.frequency,
      this.days,
      this.intervalDays,
      required this.durationType,
      this.endDate,
      this.durationDays,
      required this.isActive,
      required this.snoozeDuration,
      this.notificationId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medicine_id'] = Variable<int>(medicineId);
    map['user_id'] = Variable<int>(userId);
    map['time'] = Variable<String>(time);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || days != null) {
      map['days'] = Variable<String>(days);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    map['duration_type'] = Variable<String>(durationType);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || durationDays != null) {
      map['duration_days'] = Variable<int>(durationDays);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['snooze_duration'] = Variable<int>(snoozeDuration);
    if (!nullToAbsent || notificationId != null) {
      map['notification_id'] = Variable<int>(notificationId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      userId: Value(userId),
      time: Value(time),
      frequency: Value(frequency),
      days: days == null && nullToAbsent ? const Value.absent() : Value(days),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      durationType: Value(durationType),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      durationDays: durationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(durationDays),
      isActive: Value(isActive),
      snoozeDuration: Value(snoozeDuration),
      notificationId: notificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationId),
      createdAt: Value(createdAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      medicineId: serializer.fromJson<int>(json['medicineId']),
      userId: serializer.fromJson<int>(json['userId']),
      time: serializer.fromJson<String>(json['time']),
      frequency: serializer.fromJson<String>(json['frequency']),
      days: serializer.fromJson<String?>(json['days']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      durationType: serializer.fromJson<String>(json['durationType']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      durationDays: serializer.fromJson<int?>(json['durationDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      snoozeDuration: serializer.fromJson<int>(json['snoozeDuration']),
      notificationId: serializer.fromJson<int?>(json['notificationId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineId': serializer.toJson<int>(medicineId),
      'userId': serializer.toJson<int>(userId),
      'time': serializer.toJson<String>(time),
      'frequency': serializer.toJson<String>(frequency),
      'days': serializer.toJson<String?>(days),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'durationType': serializer.toJson<String>(durationType),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'durationDays': serializer.toJson<int?>(durationDays),
      'isActive': serializer.toJson<bool>(isActive),
      'snoozeDuration': serializer.toJson<int>(snoozeDuration),
      'notificationId': serializer.toJson<int?>(notificationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reminder copyWith(
          {int? id,
          int? medicineId,
          int? userId,
          String? time,
          String? frequency,
          Value<String?> days = const Value.absent(),
          Value<int?> intervalDays = const Value.absent(),
          String? durationType,
          Value<DateTime?> endDate = const Value.absent(),
          Value<int?> durationDays = const Value.absent(),
          bool? isActive,
          int? snoozeDuration,
          Value<int?> notificationId = const Value.absent(),
          DateTime? createdAt}) =>
      Reminder(
        id: id ?? this.id,
        medicineId: medicineId ?? this.medicineId,
        userId: userId ?? this.userId,
        time: time ?? this.time,
        frequency: frequency ?? this.frequency,
        days: days.present ? days.value : this.days,
        intervalDays:
            intervalDays.present ? intervalDays.value : this.intervalDays,
        durationType: durationType ?? this.durationType,
        endDate: endDate.present ? endDate.value : this.endDate,
        durationDays:
            durationDays.present ? durationDays.value : this.durationDays,
        isActive: isActive ?? this.isActive,
        snoozeDuration: snoozeDuration ?? this.snoozeDuration,
        notificationId:
            notificationId.present ? notificationId.value : this.notificationId,
        createdAt: createdAt ?? this.createdAt,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      userId: data.userId.present ? data.userId.value : this.userId,
      time: data.time.present ? data.time.value : this.time,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      days: data.days.present ? data.days.value : this.days,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      durationType: data.durationType.present
          ? data.durationType.value
          : this.durationType,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      snoozeDuration: data.snoozeDuration.present
          ? data.snoozeDuration.value
          : this.snoozeDuration,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('time: $time, ')
          ..write('frequency: $frequency, ')
          ..write('days: $days, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('durationType: $durationType, ')
          ..write('endDate: $endDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('isActive: $isActive, ')
          ..write('snoozeDuration: $snoozeDuration, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      medicineId,
      userId,
      time,
      frequency,
      days,
      intervalDays,
      durationType,
      endDate,
      durationDays,
      isActive,
      snoozeDuration,
      notificationId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.userId == this.userId &&
          other.time == this.time &&
          other.frequency == this.frequency &&
          other.days == this.days &&
          other.intervalDays == this.intervalDays &&
          other.durationType == this.durationType &&
          other.endDate == this.endDate &&
          other.durationDays == this.durationDays &&
          other.isActive == this.isActive &&
          other.snoozeDuration == this.snoozeDuration &&
          other.notificationId == this.notificationId &&
          other.createdAt == this.createdAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> medicineId;
  final Value<int> userId;
  final Value<String> time;
  final Value<String> frequency;
  final Value<String?> days;
  final Value<int?> intervalDays;
  final Value<String> durationType;
  final Value<DateTime?> endDate;
  final Value<int?> durationDays;
  final Value<bool> isActive;
  final Value<int> snoozeDuration;
  final Value<int?> notificationId;
  final Value<DateTime> createdAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.userId = const Value.absent(),
    this.time = const Value.absent(),
    this.frequency = const Value.absent(),
    this.days = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.durationType = const Value.absent(),
    this.endDate = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.snoozeDuration = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int medicineId,
    required int userId,
    required String time,
    this.frequency = const Value.absent(),
    this.days = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.durationType = const Value.absent(),
    this.endDate = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.snoozeDuration = const Value.absent(),
    this.notificationId = const Value.absent(),
    required DateTime createdAt,
  })  : medicineId = Value(medicineId),
        userId = Value(userId),
        time = Value(time),
        createdAt = Value(createdAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? medicineId,
    Expression<int>? userId,
    Expression<String>? time,
    Expression<String>? frequency,
    Expression<String>? days,
    Expression<int>? intervalDays,
    Expression<String>? durationType,
    Expression<DateTime>? endDate,
    Expression<int>? durationDays,
    Expression<bool>? isActive,
    Expression<int>? snoozeDuration,
    Expression<int>? notificationId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (userId != null) 'user_id': userId,
      if (time != null) 'time': time,
      if (frequency != null) 'frequency': frequency,
      if (days != null) 'days': days,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (durationType != null) 'duration_type': durationType,
      if (endDate != null) 'end_date': endDate,
      if (durationDays != null) 'duration_days': durationDays,
      if (isActive != null) 'is_active': isActive,
      if (snoozeDuration != null) 'snooze_duration': snoozeDuration,
      if (notificationId != null) 'notification_id': notificationId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<int>? medicineId,
      Value<int>? userId,
      Value<String>? time,
      Value<String>? frequency,
      Value<String?>? days,
      Value<int?>? intervalDays,
      Value<String>? durationType,
      Value<DateTime?>? endDate,
      Value<int?>? durationDays,
      Value<bool>? isActive,
      Value<int>? snoozeDuration,
      Value<int?>? notificationId,
      Value<DateTime>? createdAt}) {
    return RemindersCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      userId: userId ?? this.userId,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      days: days ?? this.days,
      intervalDays: intervalDays ?? this.intervalDays,
      durationType: durationType ?? this.durationType,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (days.present) {
      map['days'] = Variable<String>(days.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (durationType.present) {
      map['duration_type'] = Variable<String>(durationType.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (snoozeDuration.present) {
      map['snooze_duration'] = Variable<int>(snoozeDuration.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('time: $time, ')
          ..write('frequency: $frequency, ')
          ..write('days: $days, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('durationType: $durationType, ')
          ..write('endDate: $endDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('isActive: $isActive, ')
          ..write('snoozeDuration: $snoozeDuration, ')
          ..write('notificationId: $notificationId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _reminderIdMeta =
      const VerificationMeta('reminderId');
  @override
  late final GeneratedColumn<int> reminderId = GeneratedColumn<int>(
      'reminder_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _medicineIdMeta =
      const VerificationMeta('medicineId');
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
      'medicine_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledTimeMeta =
      const VerificationMeta('scheduledTime');
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>('scheduled_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _actualTimeMeta =
      const VerificationMeta('actualTime');
  @override
  late final GeneratedColumn<DateTime> actualTime = GeneratedColumn<DateTime>(
      'actual_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        reminderId,
        medicineId,
        userId,
        status,
        scheduledTime,
        actualTime,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
          _reminderIdMeta,
          reminderId.isAcceptableOrUnknown(
              data['reminder_id']!, _reminderIdMeta));
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
          _medicineIdMeta,
          medicineId.isAcceptableOrUnknown(
              data['medicine_id']!, _medicineIdMeta));
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
          _scheduledTimeMeta,
          scheduledTime.isAcceptableOrUnknown(
              data['scheduled_time']!, _scheduledTimeMeta));
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('actual_time')) {
      context.handle(
          _actualTimeMeta,
          actualTime.isAcceptableOrUnknown(
              data['actual_time']!, _actualTimeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      reminderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_id'])!,
      medicineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}medicine_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scheduledTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_time'])!,
      actualTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}actual_time']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final int reminderId;
  final int medicineId;
  final int userId;
  final String status;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final String? notes;
  final DateTime createdAt;
  const HistoryEntry(
      {required this.id,
      required this.reminderId,
      required this.medicineId,
      required this.userId,
      required this.status,
      required this.scheduledTime,
      this.actualTime,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reminder_id'] = Variable<int>(reminderId);
    map['medicine_id'] = Variable<int>(medicineId);
    map['user_id'] = Variable<int>(userId);
    map['status'] = Variable<String>(status);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    if (!nullToAbsent || actualTime != null) {
      map['actual_time'] = Variable<DateTime>(actualTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      medicineId: Value(medicineId),
      userId: Value(userId),
      status: Value(status),
      scheduledTime: Value(scheduledTime),
      actualTime: actualTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTime),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      reminderId: serializer.fromJson<int>(json['reminderId']),
      medicineId: serializer.fromJson<int>(json['medicineId']),
      userId: serializer.fromJson<int>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      actualTime: serializer.fromJson<DateTime?>(json['actualTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reminderId': serializer.toJson<int>(reminderId),
      'medicineId': serializer.toJson<int>(medicineId),
      'userId': serializer.toJson<int>(userId),
      'status': serializer.toJson<String>(status),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'actualTime': serializer.toJson<DateTime?>(actualTime),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HistoryEntry copyWith(
          {int? id,
          int? reminderId,
          int? medicineId,
          int? userId,
          String? status,
          DateTime? scheduledTime,
          Value<DateTime?> actualTime = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      HistoryEntry(
        id: id ?? this.id,
        reminderId: reminderId ?? this.reminderId,
        medicineId: medicineId ?? this.medicineId,
        userId: userId ?? this.userId,
        status: status ?? this.status,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        actualTime: actualTime.present ? actualTime.value : this.actualTime,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      reminderId:
          data.reminderId.present ? data.reminderId.value : this.reminderId,
      medicineId:
          data.medicineId.present ? data.medicineId.value : this.medicineId,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      actualTime:
          data.actualTime.present ? data.actualTime.value : this.actualTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('actualTime: $actualTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reminderId, medicineId, userId, status,
      scheduledTime, actualTime, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.medicineId == this.medicineId &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.scheduledTime == this.scheduledTime &&
          other.actualTime == this.actualTime &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<int> reminderId;
  final Value<int> medicineId;
  final Value<int> userId;
  final Value<String> status;
  final Value<DateTime> scheduledTime;
  final Value<DateTime?> actualTime;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.actualTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int reminderId,
    required int medicineId,
    required int userId,
    required String status,
    required DateTime scheduledTime,
    this.actualTime = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : reminderId = Value(reminderId),
        medicineId = Value(medicineId),
        userId = Value(userId),
        status = Value(status),
        scheduledTime = Value(scheduledTime),
        createdAt = Value(createdAt);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? reminderId,
    Expression<int>? medicineId,
    Expression<int>? userId,
    Expression<String>? status,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? actualTime,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (medicineId != null) 'medicine_id': medicineId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (actualTime != null) 'actual_time': actualTime,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HistoryEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? reminderId,
      Value<int>? medicineId,
      Value<int>? userId,
      Value<String>? status,
      Value<DateTime>? scheduledTime,
      Value<DateTime?>? actualTime,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      medicineId: medicineId ?? this.medicineId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<int>(reminderId.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (actualTime.present) {
      map['actual_time'] = Variable<DateTime>(actualTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('medicineId: $medicineId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('actualTime: $actualTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HealthMeasurementsTable extends HealthMeasurements
    with TableInfo<$HealthMeasurementsTable, HealthMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, value, unit, notes, recordedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<HealthMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HealthMeasurementsTable createAlias(String alias) {
    return $HealthMeasurementsTable(attachedDatabase, alias);
  }
}

class HealthMeasurement extends DataClass
    implements Insertable<HealthMeasurement> {
  final int id;
  final int userId;
  final String type;
  final double value;
  final String unit;
  final String? notes;
  final DateTime recordedAt;
  final DateTime createdAt;
  const HealthMeasurement(
      {required this.id,
      required this.userId,
      required this.type,
      required this.value,
      required this.unit,
      this.notes,
      required this.recordedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return HealthMeasurementsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      value: Value(value),
      unit: Value(unit),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recordedAt: Value(recordedAt),
      createdAt: Value(createdAt),
    );
  }

  factory HealthMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthMeasurement(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'notes': serializer.toJson<String?>(notes),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthMeasurement copyWith(
          {int? id,
          int? userId,
          String? type,
          double? value,
          String? unit,
          Value<String?> notes = const Value.absent(),
          DateTime? recordedAt,
          DateTime? createdAt}) =>
      HealthMeasurement(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        notes: notes.present ? notes.value : this.notes,
        recordedAt: recordedAt ?? this.recordedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  HealthMeasurement copyWithCompanion(HealthMeasurementsCompanion data) {
    return HealthMeasurement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthMeasurement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, value, unit, notes, recordedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthMeasurement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.recordedAt == this.recordedAt &&
          other.createdAt == this.createdAt);
}

class HealthMeasurementsCompanion extends UpdateCompanion<HealthMeasurement> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> type;
  final Value<double> value;
  final Value<String> unit;
  final Value<String?> notes;
  final Value<DateTime> recordedAt;
  final Value<DateTime> createdAt;
  const HealthMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String type,
    required double value,
    required String unit,
    this.notes = const Value.absent(),
    required DateTime recordedAt,
    required DateTime createdAt,
  })  : userId = Value(userId),
        type = Value(type),
        value = Value(value),
        unit = Value(unit),
        recordedAt = Value(recordedAt),
        createdAt = Value(createdAt);
  static Insertable<HealthMeasurement> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<DateTime>? recordedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthMeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? type,
      Value<double>? value,
      Value<String>? unit,
      Value<String?>? notes,
      Value<DateTime>? recordedAt,
      Value<DateTime>? createdAt}) {
    return HealthMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $HealthMeasurementsTable healthMeasurements =
      $HealthMeasurementsTable(this);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final MedicinesDao medicinesDao = MedicinesDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  late final HealthDao healthDao = HealthDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, medicines, reminders, historyEntries, healthMeasurements];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
  required String email,
  required String passwordHash,
  Value<String> role,
  Value<bool> isPremium,
  Value<String> language,
  Value<bool> isDarkMode,
  Value<bool> notificationsEnabled,
  required DateTime createdAt,
  Value<String?> firebaseUid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> email,
  Value<String> passwordHash,
  Value<String> role,
  Value<bool> isPremium,
  Value<String> language,
  Value<bool> isDarkMode,
  Value<bool> notificationsEnabled,
  Value<DateTime> createdAt,
  Value<String?> firebaseUid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get isDarkMode => $composableBuilder(
      column: $table.isDarkMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get firebaseUid => $composableBuilder(
      column: $table.firebaseUid, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isPremium = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<bool> isDarkMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> firebaseUid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            passwordHash: passwordHash,
            role: role,
            isPremium: isPremium,
            language: language,
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            createdAt: createdAt,
            firebaseUid: firebaseUid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String email,
            required String passwordHash,
            Value<String> role = const Value.absent(),
            Value<bool> isPremium = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<bool> isDarkMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            required DateTime createdAt,
            Value<String?> firebaseUid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            passwordHash: passwordHash,
            role: role,
            isPremium: isPremium,
            language: language,
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled,
            createdAt: createdAt,
            firebaseUid: firebaseUid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  Value<int> id,
  required int userId,
  required String verifiedName,
  Value<String?> brandName,
  Value<String?> genericName,
  Value<String?> manufacturer,
  Value<String?> strength,
  Value<String?> form,
  Value<String?> category,
  Value<int?> quantity,
  Value<String?> notes,
  Value<String?> imageUrl,
  Value<String> apiSource,
  Value<DateTime?> expiryDate,
  required DateTime createdAt,
  Value<bool> isActive,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> verifiedName,
  Value<String?> brandName,
  Value<String?> genericName,
  Value<String?> manufacturer,
  Value<String?> strength,
  Value<String?> form,
  Value<String?> category,
  Value<int?> quantity,
  Value<String?> notes,
  Value<String?> imageUrl,
  Value<String> apiSource,
  Value<DateTime?> expiryDate,
  Value<DateTime> createdAt,
  Value<bool> isActive,
});

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verifiedName => $composableBuilder(
      column: $table.verifiedName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get form => $composableBuilder(
      column: $table.form, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apiSource => $composableBuilder(
      column: $table.apiSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verifiedName => $composableBuilder(
      column: $table.verifiedName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandName => $composableBuilder(
      column: $table.brandName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get form => $composableBuilder(
      column: $table.form, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apiSource => $composableBuilder(
      column: $table.apiSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get verifiedName => $composableBuilder(
      column: $table.verifiedName, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get genericName => $composableBuilder(
      column: $table.genericName, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get apiSource =>
      $composableBuilder(column: $table.apiSource, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MedicinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicinesTable,
    Medicine,
    $$MedicinesTableFilterComposer,
    $$MedicinesTableOrderingComposer,
    $$MedicinesTableAnnotationComposer,
    $$MedicinesTableCreateCompanionBuilder,
    $$MedicinesTableUpdateCompanionBuilder,
    (Medicine, BaseReferences<_$AppDatabase, $MedicinesTable, Medicine>),
    Medicine,
    PrefetchHooks Function()> {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> verifiedName = const Value.absent(),
            Value<String?> brandName = const Value.absent(),
            Value<String?> genericName = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String?> form = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int?> quantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String> apiSource = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              MedicinesCompanion(
            id: id,
            userId: userId,
            verifiedName: verifiedName,
            brandName: brandName,
            genericName: genericName,
            manufacturer: manufacturer,
            strength: strength,
            form: form,
            category: category,
            quantity: quantity,
            notes: notes,
            imageUrl: imageUrl,
            apiSource: apiSource,
            expiryDate: expiryDate,
            createdAt: createdAt,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String verifiedName,
            Value<String?> brandName = const Value.absent(),
            Value<String?> genericName = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String?> form = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int?> quantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String> apiSource = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isActive = const Value.absent(),
          }) =>
              MedicinesCompanion.insert(
            id: id,
            userId: userId,
            verifiedName: verifiedName,
            brandName: brandName,
            genericName: genericName,
            manufacturer: manufacturer,
            strength: strength,
            form: form,
            category: category,
            quantity: quantity,
            notes: notes,
            imageUrl: imageUrl,
            apiSource: apiSource,
            expiryDate: expiryDate,
            createdAt: createdAt,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicinesTable,
    Medicine,
    $$MedicinesTableFilterComposer,
    $$MedicinesTableOrderingComposer,
    $$MedicinesTableAnnotationComposer,
    $$MedicinesTableCreateCompanionBuilder,
    $$MedicinesTableUpdateCompanionBuilder,
    (Medicine, BaseReferences<_$AppDatabase, $MedicinesTable, Medicine>),
    Medicine,
    PrefetchHooks Function()>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required int medicineId,
  required int userId,
  required String time,
  Value<String> frequency,
  Value<String?> days,
  Value<int?> intervalDays,
  Value<String> durationType,
  Value<DateTime?> endDate,
  Value<int?> durationDays,
  Value<bool> isActive,
  Value<int> snoozeDuration,
  Value<int?> notificationId,
  required DateTime createdAt,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<int> medicineId,
  Value<int> userId,
  Value<String> time,
  Value<String> frequency,
  Value<String?> days,
  Value<int?> intervalDays,
  Value<String> durationType,
  Value<DateTime?> endDate,
  Value<int?> durationDays,
  Value<bool> isActive,
  Value<int> snoozeDuration,
  Value<int?> notificationId,
  Value<DateTime> createdAt,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get days => $composableBuilder(
      column: $table.days, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get durationType => $composableBuilder(
      column: $table.durationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationDays => $composableBuilder(
      column: $table.durationDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get snoozeDuration => $composableBuilder(
      column: $table.snoozeDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get days => $composableBuilder(
      column: $table.days, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get durationType => $composableBuilder(
      column: $table.durationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationDays => $composableBuilder(
      column: $table.durationDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get snoozeDuration => $composableBuilder(
      column: $table.snoozeDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => column);

  GeneratedColumn<String> get durationType => $composableBuilder(
      column: $table.durationType, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get durationDays => $composableBuilder(
      column: $table.durationDays, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get snoozeDuration => $composableBuilder(
      column: $table.snoozeDuration, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> medicineId = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<String?> days = const Value.absent(),
            Value<int?> intervalDays = const Value.absent(),
            Value<String> durationType = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> durationDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> snoozeDuration = const Value.absent(),
            Value<int?> notificationId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            medicineId: medicineId,
            userId: userId,
            time: time,
            frequency: frequency,
            days: days,
            intervalDays: intervalDays,
            durationType: durationType,
            endDate: endDate,
            durationDays: durationDays,
            isActive: isActive,
            snoozeDuration: snoozeDuration,
            notificationId: notificationId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int medicineId,
            required int userId,
            required String time,
            Value<String> frequency = const Value.absent(),
            Value<String?> days = const Value.absent(),
            Value<int?> intervalDays = const Value.absent(),
            Value<String> durationType = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> durationDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> snoozeDuration = const Value.absent(),
            Value<int?> notificationId = const Value.absent(),
            required DateTime createdAt,
          }) =>
              RemindersCompanion.insert(
            id: id,
            medicineId: medicineId,
            userId: userId,
            time: time,
            frequency: frequency,
            days: days,
            intervalDays: intervalDays,
            durationType: durationType,
            endDate: endDate,
            durationDays: durationDays,
            isActive: isActive,
            snoozeDuration: snoozeDuration,
            notificationId: notificationId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()>;
typedef $$HistoryEntriesTableCreateCompanionBuilder = HistoryEntriesCompanion
    Function({
  Value<int> id,
  required int reminderId,
  required int medicineId,
  required int userId,
  required String status,
  required DateTime scheduledTime,
  Value<DateTime?> actualTime,
  Value<String?> notes,
  required DateTime createdAt,
});
typedef $$HistoryEntriesTableUpdateCompanionBuilder = HistoryEntriesCompanion
    Function({
  Value<int> id,
  Value<int> reminderId,
  Value<int> medicineId,
  Value<int> userId,
  Value<String> status,
  Value<DateTime> scheduledTime,
  Value<DateTime?> actualTime,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get actualTime => $composableBuilder(
      column: $table.actualTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get actualTime => $composableBuilder(
      column: $table.actualTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get reminderId => $composableBuilder(
      column: $table.reminderId, builder: (column) => column);

  GeneratedColumn<int> get medicineId => $composableBuilder(
      column: $table.medicineId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => column);

  GeneratedColumn<DateTime> get actualTime => $composableBuilder(
      column: $table.actualTime, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HistoryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryEntriesTable,
    HistoryEntry,
    $$HistoryEntriesTableFilterComposer,
    $$HistoryEntriesTableOrderingComposer,
    $$HistoryEntriesTableAnnotationComposer,
    $$HistoryEntriesTableCreateCompanionBuilder,
    $$HistoryEntriesTableUpdateCompanionBuilder,
    (
      HistoryEntry,
      BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>
    ),
    HistoryEntry,
    PrefetchHooks Function()> {
  $$HistoryEntriesTableTableManager(
      _$AppDatabase db, $HistoryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> reminderId = const Value.absent(),
            Value<int> medicineId = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> scheduledTime = const Value.absent(),
            Value<DateTime?> actualTime = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HistoryEntriesCompanion(
            id: id,
            reminderId: reminderId,
            medicineId: medicineId,
            userId: userId,
            status: status,
            scheduledTime: scheduledTime,
            actualTime: actualTime,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int reminderId,
            required int medicineId,
            required int userId,
            required String status,
            required DateTime scheduledTime,
            Value<DateTime?> actualTime = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              HistoryEntriesCompanion.insert(
            id: id,
            reminderId: reminderId,
            medicineId: medicineId,
            userId: userId,
            status: status,
            scheduledTime: scheduledTime,
            actualTime: actualTime,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HistoryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryEntriesTable,
    HistoryEntry,
    $$HistoryEntriesTableFilterComposer,
    $$HistoryEntriesTableOrderingComposer,
    $$HistoryEntriesTableAnnotationComposer,
    $$HistoryEntriesTableCreateCompanionBuilder,
    $$HistoryEntriesTableUpdateCompanionBuilder,
    (
      HistoryEntry,
      BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>
    ),
    HistoryEntry,
    PrefetchHooks Function()>;
typedef $$HealthMeasurementsTableCreateCompanionBuilder
    = HealthMeasurementsCompanion Function({
  Value<int> id,
  required int userId,
  required String type,
  required double value,
  required String unit,
  Value<String?> notes,
  required DateTime recordedAt,
  required DateTime createdAt,
});
typedef $$HealthMeasurementsTableUpdateCompanionBuilder
    = HealthMeasurementsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> type,
  Value<double> value,
  Value<String> unit,
  Value<String?> notes,
  Value<DateTime> recordedAt,
  Value<DateTime> createdAt,
});

class $$HealthMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthMeasurementsTable> {
  $$HealthMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HealthMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthMeasurementsTable> {
  $$HealthMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HealthMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthMeasurementsTable> {
  $$HealthMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthMeasurementsTable,
    HealthMeasurement,
    $$HealthMeasurementsTableFilterComposer,
    $$HealthMeasurementsTableOrderingComposer,
    $$HealthMeasurementsTableAnnotationComposer,
    $$HealthMeasurementsTableCreateCompanionBuilder,
    $$HealthMeasurementsTableUpdateCompanionBuilder,
    (
      HealthMeasurement,
      BaseReferences<_$AppDatabase, $HealthMeasurementsTable, HealthMeasurement>
    ),
    HealthMeasurement,
    PrefetchHooks Function()> {
  $$HealthMeasurementsTableTableManager(
      _$AppDatabase db, $HealthMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthMeasurementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HealthMeasurementsCompanion(
            id: id,
            userId: userId,
            type: type,
            value: value,
            unit: unit,
            notes: notes,
            recordedAt: recordedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required String type,
            required double value,
            required String unit,
            Value<String?> notes = const Value.absent(),
            required DateTime recordedAt,
            required DateTime createdAt,
          }) =>
              HealthMeasurementsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            value: value,
            unit: unit,
            notes: notes,
            recordedAt: recordedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthMeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthMeasurementsTable,
    HealthMeasurement,
    $$HealthMeasurementsTableFilterComposer,
    $$HealthMeasurementsTableOrderingComposer,
    $$HealthMeasurementsTableAnnotationComposer,
    $$HealthMeasurementsTableCreateCompanionBuilder,
    $$HealthMeasurementsTableUpdateCompanionBuilder,
    (
      HealthMeasurement,
      BaseReferences<_$AppDatabase, $HealthMeasurementsTable, HealthMeasurement>
    ),
    HealthMeasurement,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$HealthMeasurementsTableTableManager get healthMeasurements =>
      $$HealthMeasurementsTableTableManager(_db, _db.healthMeasurements);
}
