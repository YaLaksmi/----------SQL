SELECT table_name, constraint_name
FROM information_schema.table_constraints
WHERE constraint_type = 'PRIMARY KEY';
