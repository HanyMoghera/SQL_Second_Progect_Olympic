-- The sport which was played in the Summer season
SELECT *
FROM olympics.dbo.athlete_events
WHERE Season = 'Summer';

-- To get the total count of games
WITH t1 AS (
    SELECT COUNT(DISTINCT Games) AS GamesCount
    FROM olympics.dbo.athlete_events
    WHERE Season = 'Summer'
),
t2 AS (
    SELECT sport, COUNT(DISTINCT Games) AS GamesCount
    FROM olympics.dbo.athlete_events
    WHERE Season = 'Summer'
    GROUP BY sport
)
SELECT *
FROM t2
JOIN t1 ON t2.GamesCount = t1.GamesCount;

-- SQL query to fetch the top 5 athletes who have won the most gold medals.
WITH goldcount AS (
    SELECT athlete_events.Name, COUNT(Medal) AS Gold_Count
    FROM olympics.dbo.athlete_events
    WHERE Medal LIKE '%Gold%'
    GROUP BY Name
),
t2 AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY Gold_Count DESC) AS rnk
    FROM goldcount
)
SELECT *
FROM t2
WHERE rnk <= 5;

-- Get the number of gold, silver, and bronze medals for each country
WITH t1 AS (
    SELECT team, Medal
    FROM olympics.dbo.athlete_events
    WHERE Medal <> 'NA'
),
Gold AS (
    SELECT Team, COUNT(Medal) AS GoldCount
    FROM t1
    WHERE Medal = 'Gold'
    GROUP BY Team
),
Silver AS (
    SELECT Team, COUNT(Medal) AS SilverCount
    FROM t1
    WHERE Medal = 'Silver'
    GROUP BY Team
),
Bronze AS (
    SELECT Team, COUNT(Medal) AS BronzCount
    FROM t1
    WHERE Medal = 'Bronze'
    GROUP BY Team
),
tf AS (
    SELECT Gold.Team, GoldCount, SilverCount
    FROM Gold
    JOIN Silver ON Gold.Team = Silver.Team
),
tff AS (
    SELECT tf.Team, GoldCount, SilverCount, BronzCount
    FROM tf
    INNER JOIN Bronze ON tf.Team = Bronze.Team
)
SELECT *
FROM tff
ORDER BY GoldCount DESC;

-- Another solution
WITH alldeta AS (
    SELECT region AS country, Medal, COUNT(Medal) AS total_medal
    FROM olympics.dbo.athlete_events AS eve
    INNER JOIN olympics.dbo.noc_regions AS rgo ON eve.NOC = rgo.NOC
    WHERE Medal <> 'NA'
    GROUP BY region, Medal
)
SELECT country, 
       COALESCE([Gold], 0) AS gold,
       COALESCE([Silver], 0) AS silver,
       COALESCE([Bronze], 0) AS bronze
FROM (
    SELECT country, Medal, total_medal
    FROM alldeta
) AS SourceTable
PIVOT (
    SUM(total_medal)
    FOR Medal IN ([Gold], [Silver], [Bronze])
) AS PivotTable
ORDER BY country;

-- List down all Olympic Games held so far
SELECT year, season, city 
FROM olympics.dbo.athlete_events
ORDER BY Year;

-- SQL query to fetch the total number of countries participated in each Olympic Games
SELECT Games, COUNT(DISTINCT region) AS Num_Of_Country
FROM olympics.dbo.athlete_events AS ev
INNER JOIN olympics.dbo.noc_regions AS reg ON ev.NOC = reg.NOC
GROUP BY Games
ORDER BY Games;

-- Using SQL query, identify the sport which was played only once in all of the Olympics
WITH count_Games AS (
    SELECT Sport, COUNT(Games) AS count_Games 
    FROM olympics.dbo.athlete_events
    GROUP BY Sport
)
SELECT *
FROM count_Games
WHERE count_Games = 1;

-- Query to fetch the total number of sports played in each Olympic Games and get the top 5 for Summer
WITH scount AS (
    SELECT Games, COUNT(DISTINCT sport) AS count_sport
    FROM olympics.dbo.athlete_events
    GROUP BY Games
),
RANKO AS (
    SELECT *, DENSE_RANK() OVER (ORDER BY count_sport DESC) AS rnk
    FROM scount
)
SELECT *
FROM RANKO
WHERE rnk <= 5;

-- Details of the oldest athletes to win a gold medal at the Olympics
SELECT *
FROM olympics.dbo.athlete_events
WHERE Medal = 'Gold'
ORDER BY Games;