SELECT count(*) AS n, hour(time) AS hour
  FROM weblog 
  GROUP BY hour
  ORDER BY n DESC
  LIMIT 3;
