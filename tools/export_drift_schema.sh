#! /bin/bash

SCHEMA_VER=$(grep "const DATABASE_VERSION = " lib/db/database.dart | sed "s/const DATABASE_VERSION = //" | sed 's/;//')

echo "Current schema version: $SCHEMA_VER"

dart run drift_dev schema dump lib/db/database.dart "drift_schemas/drift_schema_v$SCHEMA_VER.json"