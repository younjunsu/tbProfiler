-- Q1
SELECT COUNT(*)
FROM USER_POST_INFO
WHERE POST_VIEW > 100;


Execution Plan
----------------------------------------------------------------------------------------------------
   1  COLUMN PROJECTION (Cost:14955, %%CPU:0, Rows:1) 
   2    SORT AGGR (Cost:14955, %%CPU:0, Rows:1) 
   3      TABLE ACCESS (FULL): USER_POST_INFO (Cost:14874, %%CPU:0, Rows:3008323) 


Predicate Information
----------------------------------------------------------------------------------------------------
   3 - filter: ("USER_POST_INFO"."POST_VIEW" > 100) (0.998)


NAME                                VALUE
------------------------------ ----------
db block gets                         232
consistent gets                     34743
physical reads                          0
redo size                              60
sorts (disk)                            0
sorts (memory)                          1
rows processed                          1


Execution Stat
----------------------------------------------------------------------------------------------------
   1  COLUMN PROJECTION (Time:0. ms, Rows:1, Starts:1) 
   2    SORT AGGR (Time:34.19 ms, Rows:1, Starts:1) 
   3      TABLE ACCESS (FULL): USER_POST_INFO (Time:155.85 ms, Rows:2993903, Starts:1) 


create index idx_user_post_info_post_view on user_post_info (post_view);
- 전체 : 3,000,000
- POST_VIEW > 100 : 2,993,903

SELECT /*+ index_ffs(user_post_info idx_user_post_info_post_view) */ COUNT(*)
FROM USER_POST_INFO
WHERE POST_VIEW > 100;

Execution Plan
----------------------------------------------------------------------------------------------------
   1  COLUMN PROJECTION (Cost:2931, %%CPU:4, Rows:1) 
   2    SORT AGGR (Cost:2931, %%CPU:4, Rows:1) 
   3      FILTER (Cost:2850, %%CPU:1, Rows:3008323) 
   4        INDEX (FAST FULL SCAN): IDX_USER_POST_INFO (Cost:2804, %%CPU:0, Rows:3013169) 


Predicate Information
----------------------------------------------------------------------------------------------------
   3 - filter: ("USER_POST_INFO"."POST_VIEW" > 100) (0.998)


NAME                                VALUE
------------------------------ ----------
db block gets                          60
consistent gets                      6696
physical reads                          0
redo size                               0
sorts (disk)                            0
sorts (memory)                          0
rows processed                          1


Execution Stat
----------------------------------------------------------------------------------------------------
   1  COLUMN PROJECTION (Time:0. ms, Rows:1, Starts:1) 
   2    SORT AGGR (Time:28.15 ms, Rows:1, Starts:1) 
   3      FILTER (Time:85.46 ms, Rows:2993903, Starts:1) 
   4        INDEX (FAST FULL SCAN): IDX_USER_POST_INFO (Time:19.99 ms, Rows:3000000, Starts:1) 


-- Q2
SELECT USER_ID, SUM(POST_LIKE)
FROM USER_POST_INFO
GROUP BY USER_ID;

create index idx_user_post_info_user_id_post_like on user_post_info (user_id,post_like);

select /*+ no_index_ffs(user_post_info idx_user_post_info_user_id_post_like) */ 
  user_id, sum(post_like)
from 
  user_post_info
where user_id is not null
group by user_id;




-- Q3
SELECT  USER_ID, COUNT(*)
FROM USER_COMMENT_INFO
GROUP BY USER_ID
HAVING COUNT(*) > 10;

create index idx_user_comment_info_user_id on user_comment_info (user_id);
ALTER SESSION ENABLE PARALLEL DML;
SELECT /*+ index_ffs(user_comment_info idx_user_comment_info_user_id) */ USER_ID, COUNT(*)
FROM USER_COMMENT_INFO
WHERE user_id is not null
GROUP BY USER_ID
HAVING COUNT(*) > 10;

-- Q4
SELECT USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE, COUNT(*)
FROM USER_INFO
JOIN USER_POST_INFO
ON USER_INFO.UUID = USER_POST_INFO.UUID
GROUP BY USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE
ORDER BY COUNT(*) DESC;

create index idx_user_info_uuid_oauth_type on user_info(uuid,oauth_type);
create index idx_user_post_info_uuid on user_post_info(uuid);

SELECT 
/*+ 
  index_ffs(user_info idx_user_info_uuid_oauth_type) 
  index(user_post_info idx_user_post_info_uuid)
*/
USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE, COUNT(*)
FROM USER_INFO
JOIN USER_POST_INFO
ON USER_INFO.UUID = USER_POST_INFO.UUID
GROUP BY USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE
ORDER BY COUNT(*) DESC;


create index idx_user_info_user_id_oauth_type on user_info(user_id, oauth_type);
select
/*
  full(user_info)
*/
  user_info.user_id, user_info.oauth_type, count(*)
from
  user_info
group by
  user_info.user_id, user_info.oauth_type
order by count(*) desc;


-- Q5
SELECT post_id, SUM(post_view) AS total_post_view, SUM(post_like) AS total_post_like, SUM(post_dislike) AS total_post_dislike
FROM user_post_info
GROUP BY post_id;

ALTER SESSION ENABLE PARALLEL DML;

SELECT /*+ PARALLEL(8) index_ffs(user_post_info IDX_USER_POST_INFO_USER_ID_POST_LIKE) */ post_id, SUM(post_view) AS total_post_view, SUM(post_like) AS total_post_like, SUM(post_dislike) AS total_post_dislike
FROM user_post_info
WHERE post_id is not null
GROUP BY post_id;

ALTER SESSION DISABLE PARALLEL DML;

-- Q6
SELECT post_id, SUM(comment_like) AS total_comment_like, SUM(comment_dislike) AS total_comment_dislike
FROM user_comment_info
GROUP BY post_id;

-- Q7
select user_post_info.user_id, sum(user_post_info.post_like) as total_like
from user_info join user_post_info
on user_info.user_id = user_post_info.user_id
group by user_post_info.user_id;

-- Q8
select user_comment_info.user_id, count(1) as comment_count
from user_info join user_comment_info
on user_info.user_id = user_comment_info.user_id
group by user_comment_info.user_id;

-- Q9
SELECT ui.user_id, upi.post_id, uci.comment_id
FROM user_info ui
JOIN user_post_info upi ON ui.user_id = upi.user_id
JOIN user_comment_info uci ON upi.post_id = uci.post_id
WHERE ui.oauth_type = 'facebook'
AND upi.post_view >= 1000
AND uci.comment_like >= 100
ORDER BY upi.post_createdate DESC;

-- Q10
SELECT 
  ui.user_id,
  sum(upi.post_view) as total_post_view,
  sum(upi.post_like) as total_post_like,
  sum(upi.post_dislike) as total_post_dislike,
  count(uc.comment_id) as total_comment
FROM 
  user_info ui 
  LEFT JOIN user_post_info upi 
    ON ui.user_id = upi.user_id 
  LEFT JOIN user_comment_info uc 
    ON upi.post_id = uc.post_id 
GROUP BY 
  ui.user_id;
