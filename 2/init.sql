CREATE SCHEMA sewn;

CREATE TABLE weblog (
  id int auto_increment primary key,
  time datetime,
  ip int unsigned,
  username char(1),
  method varchar(4),
  path varchar(255),
  data text,
  status smallint,
  vhost varchar(128),
  user_agent varchar(255),
  cookies text,
  referrer text);
