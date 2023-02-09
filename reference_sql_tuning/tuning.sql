-- 인덱스 컬럼 가공
select * from user_info where
to_char(uuid) = '1'

1 = uuid*1000;

-- 인덱스 컬럼 함수


-- 



/*
-- 컬럼 가공에 의한 INDEX RANGE SCAN 불가
*/

함수

연산


/*
-- 인덱스 튜닝
*/

-- 사용자별 게시글 개수
select 
    user_id, post_id, count(*) post_cnt
from
    user_post_info 
where 
    post_id is not null 
group by
    user_id, post_id;

Execution Stat
----------------------------------------------------------------------------------------------------
   1  GROUP BY (HASH) (Time:5210.08 ms, Rows:3000000, Starts:1) 
   2    TABLE ACCESS (FULL): USER_POST_INFO (Time:494.51 ms, Rows:3000000, Starts:1) 


-- 사용자별 게시글 개수 중 탑 사용자 10명
select 
    post_cnt_top_user.user_id,
    post_cnt_top_user.post_cnt
from
    (
        select
            user_id, count(*) post_cnt
        from
            user_post_info
        where
            user_id is not null
        group by
            user_id
        order by post_cnt desc 
    ) post_cnt_top_user
where
    rownum <=10;

Execution Stat
----------------------------------------------------------------------------------------------------
   1  ORDER BY (SORT) TOP-N (Time:136.58 ms, Rows:10, Starts:1) 
   2    GROUP BY (HASH) (Time:2362.21 ms, Rows:987189, Starts:1) 
   3      TABLE ACCESS (FULL): USER_POST_INFO (Time:262.75 ms, Rows:3000000, Starts:1) 

-- 사용자별 댓글 개수 중 탑 사용자 10명
select
    comment_cnt_top_user.user_id,
    comment_cnt_top_user.comment_cnt
from
    (
        select
            user_id, count(*) comment_cnt
        from
            user_comment_info
        where
            user_id is not null
        group by
            user_id
        order by comment_cnt desc
    ) comment_cnt_top_user
where
    rownum <= 10;
Execution Stat
----------------------------------------------------------------------------------------------------
   1  ORDER BY (SORT) TOP-N (Time:150.24 ms, Rows:10, Starts:1) 
   2    GROUP BY (SORT) (Time:5656.1 ms, Rows:1037907, Starts:1) 
   3      TABLE ACCESS (FULL): USER_COMMENT_INFO (Time:2435.43 ms, Rows:5000000, Starts:1) 


-- 댓글이 가장 많이 달린 탑 게시글 10개
select
    comment_top_post.post_id,
    comment_top_post.comment_cnt
from
    (
        select
            post_id,
            count(*) comment_cnt
        from
            user_comment_info
        where
            post_id is not null
        group by
            post_id
        order by 
            comment_cnt desc
    ) comment_top_post
where
    rownum <= 10;

Execution Stat
----------------------------------------------------------------------------------------------------
   1  ORDER BY (SORT) TOP-N (Time:337.72 ms, Rows:10, Starts:1) 
   2    GROUP BY (HASH) (Time:7069.42 ms, Rows:2432897, Starts:1) 
   3      TABLE ACCESS (FULL): USER_COMMENT_INFO (Time:2660.03 ms, Rows:5000000, Starts:1) 

-- 게시글 조회 수가 높은 탑 10개 게시글
select
    post_view_top.post_id,
    post_view_top.post_view
from
    (
        select
            post_id,
            post_view
        from
            user_post_info
        where
            post_id is not null
        order by 
            post_view desc
    ) post_view_top
where
    rownum <=10;
    
Execution Stat
----------------------------------------------------------------------------------------------------
   1  ORDER BY (SORT) TOP-N (Time:527.26 ms, Rows:10, Starts:1) 
   2    TABLE ACCESS (FULL): USER_POST_INFO (Time:273.56 ms, Rows:3000000, Starts:1) 



-- 게시글 좋아요를 가장 많이 받은 게시글 탑 10개

-- 댓글 좋아요를 가장 많이 받은 게시글 탑 10개

-- 게시판 페이지에 최신 작성 게시글 10개씩 출력

-- 게시판 페이지에 최신 작성 게시글 30개씩 출력

-- 게시판 페이지에 최신 작성 게시글 50개씩 출력




/*
-- 조인 튜닝
*/