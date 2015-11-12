SELECT count(*) AS n, inet_ntoa(ip) AS IP
  FROM weblog
  GROUP BY IP
  ORDER BY n DESC
  LIMIT 10;