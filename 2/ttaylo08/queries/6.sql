SELECT count(*) AS n,
	CASE
        WHEN referrer regexp 'yahoo' THEN 'Yahoo'
		WHEN referrer regexp 'google' THEN 'Google'
        WHEN referrer regexp 'msn' THEN 'MSN'
	  ELSE
		NULL
      END 
    AS search_engine
	FROM weblog
    GROUP BY search_engine
    HAVING search_engine IS NOT NULL
    ORDER BY n;