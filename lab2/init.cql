CREATE KEYSPACE sewn WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

CREATE TABLE weblog (
  id uuid PRIMARY KEY,
  datetime timestamp,
  ip inet,
  x1 text,
  type text,
  path text,
  data text,
  status int,
  vhost text,
  user_agent text,
  cookies text,
  referrer text );
