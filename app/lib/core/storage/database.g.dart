// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SkillStatsRowsTable extends SkillStatsRows with TableInfo<$SkillStatsRowsTable, SkillStatsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillStatsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta('correct');
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _independentMeta = const VerificationMeta('independent');
  @override
  late final GeneratedColumn<int> independent = GeneratedColumn<int>(
    'independent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsMeta = const VerificationMeta('hints');
  @override
  late final GeneratedColumn<int> hints = GeneratedColumn<int>(
    'hints',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [skill, attempts, correct, independent, hints];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skill_stats_rows';
  @override
  VerificationContext validateIntegrity(Insertable<SkillStatsRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('skill')) {
      context.handle(_skillMeta, skill.isAcceptableOrUnknown(data['skill']!, _skillMeta));
    } else if (isInserting) {
      context.missing(_skillMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta, correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('independent')) {
      context.handle(_independentMeta, independent.isAcceptableOrUnknown(data['independent']!, _independentMeta));
    } else if (isInserting) {
      context.missing(_independentMeta);
    }
    if (data.containsKey('hints')) {
      context.handle(_hintsMeta, hints.isAcceptableOrUnknown(data['hints']!, _hintsMeta));
    } else if (isInserting) {
      context.missing(_hintsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {skill};
  @override
  SkillStatsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillStatsRow(
      skill: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}skill'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      correct: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}correct'])!,
      independent: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}independent'])!,
      hints: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}hints'])!,
    );
  }

  @override
  $SkillStatsRowsTable createAlias(String alias) {
    return $SkillStatsRowsTable(attachedDatabase, alias);
  }
}

class SkillStatsRow extends DataClass implements Insertable<SkillStatsRow> {
  final String skill;
  final int attempts;
  final int correct;
  final int independent;
  final int hints;
  const SkillStatsRow({
    required this.skill,
    required this.attempts,
    required this.correct,
    required this.independent,
    required this.hints,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['skill'] = Variable<String>(skill);
    map['attempts'] = Variable<int>(attempts);
    map['correct'] = Variable<int>(correct);
    map['independent'] = Variable<int>(independent);
    map['hints'] = Variable<int>(hints);
    return map;
  }

  SkillStatsRowsCompanion toCompanion(bool nullToAbsent) {
    return SkillStatsRowsCompanion(
      skill: Value(skill),
      attempts: Value(attempts),
      correct: Value(correct),
      independent: Value(independent),
      hints: Value(hints),
    );
  }

  factory SkillStatsRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillStatsRow(
      skill: serializer.fromJson<String>(json['skill']),
      attempts: serializer.fromJson<int>(json['attempts']),
      correct: serializer.fromJson<int>(json['correct']),
      independent: serializer.fromJson<int>(json['independent']),
      hints: serializer.fromJson<int>(json['hints']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'skill': serializer.toJson<String>(skill),
      'attempts': serializer.toJson<int>(attempts),
      'correct': serializer.toJson<int>(correct),
      'independent': serializer.toJson<int>(independent),
      'hints': serializer.toJson<int>(hints),
    };
  }

  SkillStatsRow copyWith({String? skill, int? attempts, int? correct, int? independent, int? hints}) => SkillStatsRow(
    skill: skill ?? this.skill,
    attempts: attempts ?? this.attempts,
    correct: correct ?? this.correct,
    independent: independent ?? this.independent,
    hints: hints ?? this.hints,
  );
  SkillStatsRow copyWithCompanion(SkillStatsRowsCompanion data) {
    return SkillStatsRow(
      skill: data.skill.present ? data.skill.value : this.skill,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      correct: data.correct.present ? data.correct.value : this.correct,
      independent: data.independent.present ? data.independent.value : this.independent,
      hints: data.hints.present ? data.hints.value : this.hints,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillStatsRow(')
          ..write('skill: $skill, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('independent: $independent, ')
          ..write('hints: $hints')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(skill, attempts, correct, independent, hints);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillStatsRow &&
          other.skill == this.skill &&
          other.attempts == this.attempts &&
          other.correct == this.correct &&
          other.independent == this.independent &&
          other.hints == this.hints);
}

class SkillStatsRowsCompanion extends UpdateCompanion<SkillStatsRow> {
  final Value<String> skill;
  final Value<int> attempts;
  final Value<int> correct;
  final Value<int> independent;
  final Value<int> hints;
  final Value<int> rowid;
  const SkillStatsRowsCompanion({
    this.skill = const Value.absent(),
    this.attempts = const Value.absent(),
    this.correct = const Value.absent(),
    this.independent = const Value.absent(),
    this.hints = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkillStatsRowsCompanion.insert({
    required String skill,
    required int attempts,
    required int correct,
    required int independent,
    required int hints,
    this.rowid = const Value.absent(),
  }) : skill = Value(skill),
       attempts = Value(attempts),
       correct = Value(correct),
       independent = Value(independent),
       hints = Value(hints);
  static Insertable<SkillStatsRow> custom({
    Expression<String>? skill,
    Expression<int>? attempts,
    Expression<int>? correct,
    Expression<int>? independent,
    Expression<int>? hints,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (skill != null) 'skill': skill,
      if (attempts != null) 'attempts': attempts,
      if (correct != null) 'correct': correct,
      if (independent != null) 'independent': independent,
      if (hints != null) 'hints': hints,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkillStatsRowsCompanion copyWith({
    Value<String>? skill,
    Value<int>? attempts,
    Value<int>? correct,
    Value<int>? independent,
    Value<int>? hints,
    Value<int>? rowid,
  }) {
    return SkillStatsRowsCompanion(
      skill: skill ?? this.skill,
      attempts: attempts ?? this.attempts,
      correct: correct ?? this.correct,
      independent: independent ?? this.independent,
      hints: hints ?? this.hints,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (independent.present) {
      map['independent'] = Variable<int>(independent.value);
    }
    if (hints.present) {
      map['hints'] = Variable<int>(hints.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillStatsRowsCompanion(')
          ..write('skill: $skill, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('independent: $independent, ')
          ..write('hints: $hints, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileRowsTable extends ProfileRows with TableInfo<$ProfileRowsTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 24),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageBandMeta = const VerificationMeta('ageBand');
  @override
  late final GeneratedColumn<String> ageBand = GeneratedColumn<String>(
    'age_band',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nickname, avatar, ageBand, locale];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta, nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta, avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    if (data.containsKey('age_band')) {
      context.handle(_ageBandMeta, ageBand.isAcceptableOrUnknown(data['age_band']!, _ageBandMeta));
    } else if (isInserting) {
      context.missing(_ageBandMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nickname: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatar: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}avatar'])!,
      ageBand: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}age_band'])!,
      locale: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
    );
  }

  @override
  $ProfileRowsTable createAlias(String alias) {
    return $ProfileRowsTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String nickname;
  final String avatar;
  final String ageBand;
  final String locale;
  const ProfileRow({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.ageBand,
    required this.locale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['avatar'] = Variable<String>(avatar);
    map['age_band'] = Variable<String>(ageBand);
    map['locale'] = Variable<String>(locale);
    return map;
  }

  ProfileRowsCompanion toCompanion(bool nullToAbsent) {
    return ProfileRowsCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avatar: Value(avatar),
      ageBand: Value(ageBand),
      locale: Value(locale),
    );
  }

  factory ProfileRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatar: serializer.fromJson<String>(json['avatar']),
      ageBand: serializer.fromJson<String>(json['ageBand']),
      locale: serializer.fromJson<String>(json['locale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avatar': serializer.toJson<String>(avatar),
      'ageBand': serializer.toJson<String>(ageBand),
      'locale': serializer.toJson<String>(locale),
    };
  }

  ProfileRow copyWith({int? id, String? nickname, String? avatar, String? ageBand, String? locale}) => ProfileRow(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    avatar: avatar ?? this.avatar,
    ageBand: ageBand ?? this.ageBand,
    locale: locale ?? this.locale,
  );
  ProfileRow copyWithCompanion(ProfileRowsCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      ageBand: data.ageBand.present ? data.ageBand.value : this.ageBand,
      locale: data.locale.present ? data.locale.value : this.locale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('ageBand: $ageBand, ')
          ..write('locale: $locale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatar, ageBand, locale);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avatar == this.avatar &&
          other.ageBand == this.ageBand &&
          other.locale == this.locale);
}

class ProfileRowsCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> avatar;
  final Value<String> ageBand;
  final Value<String> locale;
  const ProfileRowsCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
    this.ageBand = const Value.absent(),
    this.locale = const Value.absent(),
  });
  ProfileRowsCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required String avatar,
    required String ageBand,
    required String locale,
  }) : nickname = Value(nickname),
       avatar = Value(avatar),
       ageBand = Value(ageBand),
       locale = Value(locale);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? avatar,
    Expression<String>? ageBand,
    Expression<String>? locale,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (ageBand != null) 'age_band': ageBand,
      if (locale != null) 'locale': locale,
    });
  }

  ProfileRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<String>? avatar,
    Value<String>? ageBand,
    Value<String>? locale,
  }) {
    return ProfileRowsCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      ageBand: ageBand ?? this.ageBand,
      locale: locale ?? this.locale,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (ageBand.present) {
      map['age_band'] = Variable<String>(ageBand.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRowsCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('ageBand: $ageBand, ')
          ..write('locale: $locale')
          ..write(')'))
        .toString();
  }
}

class $SettingRowsTable extends SettingRows with TableInfo<$SettingRowsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_rows';
  @override
  VerificationContext validateIntegrity(Insertable<SettingRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingRowsTable createAlias(String alias) {
    return $SettingRowsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingRowsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingRow copyWith({String? key, String? value}) => SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingRowsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingRow && other.key == this.key && other.value == this.value);
}

class SettingRowsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingRowsCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingRow> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingRowsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingRowsCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LevelProgressRowsTable extends LevelProgressRows with TableInfo<$LevelProgressRowsTable, LevelProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelProgressRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [level, stars, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_progress_rows';
  @override
  VerificationContext validateIntegrity(Insertable<LevelProgressRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level')) {
      context.handle(_levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(_starsMeta, stars.isAcceptableOrUnknown(data['stars']!, _starsMeta));
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {level};
  @override
  LevelProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelProgressRow(
      level: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      stars: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}stars'])!,
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
    );
  }

  @override
  $LevelProgressRowsTable createAlias(String alias) {
    return $LevelProgressRowsTable(attachedDatabase, alias);
  }
}

class LevelProgressRow extends DataClass implements Insertable<LevelProgressRow> {
  /// `<world>.l<number>`, e.g. `animals.l1`.
  final String level;
  final int stars;
  final DateTime completedAt;
  const LevelProgressRow({required this.level, required this.stars, required this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level'] = Variable<String>(level);
    map['stars'] = Variable<int>(stars);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LevelProgressRowsCompanion toCompanion(bool nullToAbsent) {
    return LevelProgressRowsCompanion(level: Value(level), stars: Value(stars), completedAt: Value(completedAt));
  }

  factory LevelProgressRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelProgressRow(
      level: serializer.fromJson<String>(json['level']),
      stars: serializer.fromJson<int>(json['stars']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'level': serializer.toJson<String>(level),
      'stars': serializer.toJson<int>(stars),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LevelProgressRow copyWith({String? level, int? stars, DateTime? completedAt}) => LevelProgressRow(
    level: level ?? this.level,
    stars: stars ?? this.stars,
    completedAt: completedAt ?? this.completedAt,
  );
  LevelProgressRow copyWithCompanion(LevelProgressRowsCompanion data) {
    return LevelProgressRow(
      level: data.level.present ? data.level.value : this.level,
      stars: data.stars.present ? data.stars.value : this.stars,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressRow(')
          ..write('level: $level, ')
          ..write('stars: $stars, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(level, stars, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelProgressRow &&
          other.level == this.level &&
          other.stars == this.stars &&
          other.completedAt == this.completedAt);
}

class LevelProgressRowsCompanion extends UpdateCompanion<LevelProgressRow> {
  final Value<String> level;
  final Value<int> stars;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LevelProgressRowsCompanion({
    this.level = const Value.absent(),
    this.stars = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelProgressRowsCompanion.insert({
    required String level,
    required int stars,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : level = Value(level),
       stars = Value(stars),
       completedAt = Value(completedAt);
  static Insertable<LevelProgressRow> custom({
    Expression<String>? level,
    Expression<int>? stars,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (level != null) 'level': level,
      if (stars != null) 'stars': stars,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelProgressRowsCompanion copyWith({
    Value<String>? level,
    Value<int>? stars,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LevelProgressRowsCompanion(
      level: level ?? this.level,
      stars: stars ?? this.stars,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressRowsCompanion(')
          ..write('level: $level, ')
          ..write('stars: $stars, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SkillStatsRowsTable skillStatsRows = $SkillStatsRowsTable(this);
  late final $ProfileRowsTable profileRows = $ProfileRowsTable(this);
  late final $SettingRowsTable settingRows = $SettingRowsTable(this);
  late final $LevelProgressRowsTable levelProgressRows = $LevelProgressRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [skillStatsRows, profileRows, settingRows, levelProgressRows];
}

typedef $$SkillStatsRowsTableCreateCompanionBuilder = SkillStatsRowsCompanion Function({
  required String skill,
  required int attempts,
  required int correct,
  required int independent,
  required int hints,
  Value<int> rowid,
});
typedef $$SkillStatsRowsTableUpdateCompanionBuilder = SkillStatsRowsCompanion Function({
  Value<String> skill,
  Value<int> attempts,
  Value<int> correct,
  Value<int> independent,
  Value<int> hints,
  Value<int> rowid,
});

class $$SkillStatsRowsTableFilterComposer extends Composer<_$AppDatabase, $SkillStatsRowsTable> {
  $$SkillStatsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get independent =>
      $composableBuilder(column: $table.independent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hints => $composableBuilder(column: $table.hints, builder: (column) => ColumnFilters(column));
}

class $$SkillStatsRowsTableOrderingComposer extends Composer<_$AppDatabase, $SkillStatsRowsTable> {
  $$SkillStatsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get independent =>
      $composableBuilder(column: $table.independent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hints =>
      $composableBuilder(column: $table.hints, builder: (column) => ColumnOrderings(column));
}

class $$SkillStatsRowsTableAnnotationComposer extends Composer<_$AppDatabase, $SkillStatsRowsTable> {
  $$SkillStatsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get skill => $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get correct => $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get independent => $composableBuilder(column: $table.independent, builder: (column) => column);

  GeneratedColumn<int> get hints => $composableBuilder(column: $table.hints, builder: (column) => column);
}

class $$SkillStatsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SkillStatsRowsTable,
          SkillStatsRow,
          $$SkillStatsRowsTableFilterComposer,
          $$SkillStatsRowsTableOrderingComposer,
          $$SkillStatsRowsTableAnnotationComposer,
          $$SkillStatsRowsTableCreateCompanionBuilder,
          $$SkillStatsRowsTableUpdateCompanionBuilder,
          (SkillStatsRow, BaseReferences<_$AppDatabase, $SkillStatsRowsTable, SkillStatsRow>),
          SkillStatsRow,
          PrefetchHooks Function()
        > {
  $$SkillStatsRowsTableTableManager(_$AppDatabase db, $SkillStatsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SkillStatsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SkillStatsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SkillStatsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> skill = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> independent = const Value.absent(),
                Value<int> hints = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkillStatsRowsCompanion(
                skill: skill,
                attempts: attempts,
                correct: correct,
                independent: independent,
                hints: hints,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String skill,
                required int attempts,
                required int correct,
                required int independent,
                required int hints,
                Value<int> rowid = const Value.absent(),
              }) => SkillStatsRowsCompanion.insert(
                skill: skill,
                attempts: attempts,
                correct: correct,
                independent: independent,
                hints: hints,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SkillStatsRowsTable, SkillStatsRow>(table),
                  BaseReferences<_$AppDatabase, $SkillStatsRowsTable, SkillStatsRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SkillStatsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SkillStatsRowsTable,
      SkillStatsRow,
      $$SkillStatsRowsTableFilterComposer,
      $$SkillStatsRowsTableOrderingComposer,
      $$SkillStatsRowsTableAnnotationComposer,
      $$SkillStatsRowsTableCreateCompanionBuilder,
      $$SkillStatsRowsTableUpdateCompanionBuilder,
      (SkillStatsRow, BaseReferences<_$AppDatabase, $SkillStatsRowsTable, SkillStatsRow>),
      SkillStatsRow,
      PrefetchHooks Function()
    >;
typedef $$ProfileRowsTableCreateCompanionBuilder = ProfileRowsCompanion Function({
  Value<int> id,
  required String nickname,
  required String avatar,
  required String ageBand,
  required String locale,
});
typedef $$ProfileRowsTableUpdateCompanionBuilder = ProfileRowsCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> avatar,
  Value<String> ageBand,
  Value<String> locale,
});

class $$ProfileRowsTableFilterComposer extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ageBand =>
      $composableBuilder(column: $table.ageBand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));
}

class $$ProfileRowsTableOrderingComposer extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ageBand =>
      $composableBuilder(column: $table.ageBand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));
}

class $$ProfileRowsTableAnnotationComposer extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname => $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatar => $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get ageBand => $composableBuilder(column: $table.ageBand, builder: (column) => column);

  GeneratedColumn<String> get locale => $composableBuilder(column: $table.locale, builder: (column) => column);
}

class $$ProfileRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileRowsTable,
          ProfileRow,
          $$ProfileRowsTableFilterComposer,
          $$ProfileRowsTableOrderingComposer,
          $$ProfileRowsTableAnnotationComposer,
          $$ProfileRowsTableCreateCompanionBuilder,
          $$ProfileRowsTableUpdateCompanionBuilder,
          (ProfileRow, BaseReferences<_$AppDatabase, $ProfileRowsTable, ProfileRow>),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfileRowsTableTableManager(_$AppDatabase db, $ProfileRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfileRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfileRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProfileRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> avatar = const Value.absent(),
            Value<String> ageBand = const Value.absent(),
            Value<String> locale = const Value.absent(),
          }) => ProfileRowsCompanion(id: id, nickname: nickname, avatar: avatar, ageBand: ageBand, locale: locale),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nickname,
                required String avatar,
                required String ageBand,
                required String locale,
              }) => ProfileRowsCompanion.insert(
                id: id,
                nickname: nickname,
                avatar: avatar,
                ageBand: ageBand,
                locale: locale,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileRowsTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfileRowsTable, ProfileRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileRowsTable,
      ProfileRow,
      $$ProfileRowsTableFilterComposer,
      $$ProfileRowsTableOrderingComposer,
      $$ProfileRowsTableAnnotationComposer,
      $$ProfileRowsTableCreateCompanionBuilder,
      $$ProfileRowsTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfileRowsTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$SettingRowsTableCreateCompanionBuilder = SettingRowsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingRowsTableUpdateCompanionBuilder = SettingRowsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingRowsTableFilterComposer extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingRowsTableOrderingComposer extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingRowsTableAnnotationComposer extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingRowsTable,
          SettingRow,
          $$SettingRowsTableFilterComposer,
          $$SettingRowsTableOrderingComposer,
          $$SettingRowsTableAnnotationComposer,
          $$SettingRowsTableCreateCompanionBuilder,
          $$SettingRowsTableUpdateCompanionBuilder,
          (SettingRow, BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingRowsTableTableManager(_$AppDatabase db, $SettingRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingRowsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingRowsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingRowsTable,
      SettingRow,
      $$SettingRowsTableFilterComposer,
      $$SettingRowsTableOrderingComposer,
      $$SettingRowsTableAnnotationComposer,
      $$SettingRowsTableCreateCompanionBuilder,
      $$SettingRowsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$LevelProgressRowsTableCreateCompanionBuilder = LevelProgressRowsCompanion Function({
  required String level,
  required int stars,
  required DateTime completedAt,
  Value<int> rowid,
});
typedef $$LevelProgressRowsTableUpdateCompanionBuilder = LevelProgressRowsCompanion Function({
  Value<String> level,
  Value<int> stars,
  Value<DateTime> completedAt,
  Value<int> rowid,
});

class $$LevelProgressRowsTableFilterComposer extends Composer<_$AppDatabase, $LevelProgressRowsTable> {
  $$LevelProgressRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stars => $composableBuilder(column: $table.stars, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$LevelProgressRowsTableOrderingComposer extends Composer<_$AppDatabase, $LevelProgressRowsTable> {
  $$LevelProgressRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$LevelProgressRowsTableAnnotationComposer extends Composer<_$AppDatabase, $LevelProgressRowsTable> {
  $$LevelProgressRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get level => $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get stars => $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);
}

class $$LevelProgressRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LevelProgressRowsTable,
          LevelProgressRow,
          $$LevelProgressRowsTableFilterComposer,
          $$LevelProgressRowsTableOrderingComposer,
          $$LevelProgressRowsTableAnnotationComposer,
          $$LevelProgressRowsTableCreateCompanionBuilder,
          $$LevelProgressRowsTableUpdateCompanionBuilder,
          (LevelProgressRow, BaseReferences<_$AppDatabase, $LevelProgressRowsTable, LevelProgressRow>),
          LevelProgressRow,
          PrefetchHooks Function()
        > {
  $$LevelProgressRowsTableTableManager(_$AppDatabase db, $LevelProgressRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LevelProgressRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LevelProgressRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LevelProgressRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> level = const Value.absent(),
            Value<int> stars = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LevelProgressRowsCompanion(level: level, stars: stars, completedAt: completedAt, rowid: rowid),
          createCompanionCallback: ({
            required String level,
            required int stars,
            required DateTime completedAt,
            Value<int> rowid = const Value.absent(),
          }) => LevelProgressRowsCompanion.insert(level: level, stars: stars, completedAt: completedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LevelProgressRowsTable, LevelProgressRow>(table),
                  BaseReferences<_$AppDatabase, $LevelProgressRowsTable, LevelProgressRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LevelProgressRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LevelProgressRowsTable,
      LevelProgressRow,
      $$LevelProgressRowsTableFilterComposer,
      $$LevelProgressRowsTableOrderingComposer,
      $$LevelProgressRowsTableAnnotationComposer,
      $$LevelProgressRowsTableCreateCompanionBuilder,
      $$LevelProgressRowsTableUpdateCompanionBuilder,
      (LevelProgressRow, BaseReferences<_$AppDatabase, $LevelProgressRowsTable, LevelProgressRow>),
      LevelProgressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SkillStatsRowsTableTableManager get skillStatsRows => $$SkillStatsRowsTableTableManager(_db, _db.skillStatsRows);
  $$ProfileRowsTableTableManager get profileRows => $$ProfileRowsTableTableManager(_db, _db.profileRows);
  $$SettingRowsTableTableManager get settingRows => $$SettingRowsTableTableManager(_db, _db.settingRows);
  $$LevelProgressRowsTableTableManager get levelProgressRows =>
      $$LevelProgressRowsTableTableManager(_db, _db.levelProgressRows);
}
