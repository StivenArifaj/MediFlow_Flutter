// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicines_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicinesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MedicinesTable get medicines => attachedDatabase.medicines;
  MedicinesDaoManager get managers => MedicinesDaoManager(this);
}

class MedicinesDaoManager {
  final _$MedicinesDaoMixin _db;
  MedicinesDaoManager(this._db);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db.attachedDatabase, _db.medicines);
}
