/*
    카카오톡으로 로그인한 사용자의 게시글 작성 정보 확인
-- 게시글 작성자
-- 게시글 번호
-- 게시글 좋아요
-- 게시글 작성 일자
*/




/*
    카카오톡, 페이스북 사용자의 
*/



select user_id, post_id, post_path, post_view from user_post_info where
post_createdate between '20221201' and '20221231';


select /*+ index(user_post_info idx_user_post_info_post_createdate) */ user_id, post_id, post_path, post_view from user_post_info where
post_createdate between '20221201' and '20221231';


create index idx_user_post_info_post_createdate on user_post_info(post_createdate);


