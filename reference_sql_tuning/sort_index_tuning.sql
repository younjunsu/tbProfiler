-- Q1
SELECT COUNT(*)
FROM USER_POST_INFO
WHERE POST_VIEW > 100;

-- Q2
SELECT USER_ID, SUM(POST_LIKE)
FROM USER_POST_INFO
GROUP BY USER_ID;

-- Q3
SELECT USER_ID, COUNT(*)
FROM USER_COMMENT_INFO
GROUP BY USER_ID
HAVING COUNT(*) > 10;

-- Q4
SELECT USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE, COUNT(*)
FROM USER_INFO
JOIN USER_POST_INFO
ON USER_INFO.UUID = USER_POST_INFO.UUID
GROUP BY USER_INFO.USER_ID, USER_INFO.OAUTH_TYPE
ORDER BY COUNT(*) DESC;

-- Q5
SELECT post_id, SUM(post_view) AS total_post_view, SUM(post_like) AS total_post_like, SUM(post_dislike) AS total_post_dislike
FROM user_post_info
GROUP BY post_id;

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
