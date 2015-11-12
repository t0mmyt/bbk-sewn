SELECT count(*) AS n, path
  FROM weblog
  GROUP BY path
  ORDER BY n DESC
  LIMIT 10;
