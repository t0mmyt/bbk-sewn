SELECT count(*) AS n, method
  FROM weblog
  GROUP BY method
  ORDER BY n DESC;