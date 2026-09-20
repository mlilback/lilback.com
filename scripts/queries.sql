-- Top pages, last 24h. _sample_interval is Analytics Engine's sampling
-- weight; summing it approximates the true count.
SELECT blob1 AS path,
       SUM(_sample_interval) AS views,
       COUNT(DISTINCT blob5) AS visitors
FROM blog_hits
WHERE timestamp > NOW() - INTERVAL '24' HOUR
GROUP BY path ORDER BY views DESC LIMIT 20

-- Top referrers, last 7 days (blank = direct)
SELECT blob2 AS referrer, SUM(_sample_interval) AS views
FROM blog_hits
WHERE timestamp > NOW() - INTERVAL '7' DAY AND blob2 != ''
GROUP BY referrer ORDER BY views DESC LIMIT 20

-- Same, with the obvious bots excluded at QUERY time, not write time
SELECT blob1 AS path, SUM(_sample_interval) AS views
FROM blog_hits
WHERE timestamp > NOW() - INTERVAL '7' DAY
  AND positionCaseInsensitive(blob4, 'bot') = 0
  AND positionCaseInsensitive(blob4, 'crawler') = 0
  AND positionCaseInsensitive(blob4, 'spider') = 0
GROUP BY path ORDER BY views DESC LIMIT 20

-- Daily totals
SELECT toDate(timestamp) AS day,
       SUM(_sample_interval) AS views,
       COUNT(DISTINCT blob5) AS visitors
FROM blog_hits
WHERE timestamp > NOW() - INTERVAL '30' DAY
GROUP BY day ORDER BY day DESC
