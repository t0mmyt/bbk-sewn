SELECT count(*) AS n, path, status, referrer
  FROM weblog
  WHERE
    status >= 400
    AND referrer regexp(
      SELECT DISTINCT
        group_concat(vhost SEPARATOR '|')
      FROM weblog)
  GROUP BY path
  ORDER BY n DESC;
