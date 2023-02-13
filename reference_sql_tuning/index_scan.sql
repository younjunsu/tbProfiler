-- 
select count(*) from user_comment_info;

create unique index uidx_user_comment_info_comment_id on user_comment_info(comment_id);
alter table user_comment_info add constraint pk_uidx_user_comment_info_comment_id primary key (comment_id);


--
select user_id, post_id, post_createdate from user_post_info where
post_createdate between '20220101' and '20221231';


select user_id, post_id, post_createdate from user_post_info where post_createdate between '20220101' and '20221231';
create index idx_user_post_info_post_createdate on user_post_info(post_createdate);


select /*+ full(user_post_info) */ user_id, post_id, post_createdate from user_post_info where post_createdate between '20221101' and '20221231';
select /*+ index(user_post_info idx_user_post_info_post_createdate) */ user_id, post_id, post_createdate from user_post_info where post_createdate between '20221101' and '20221231';
select /*+ index(user_post_info idx_user_post_info_post_createdate) */ post_createdate from user_post_info where post_createdate between '20221101' and '20221231';
select user_id, post_id, post_path, post_createdate from user_post_info where post_createdate between '20221101' and '20221231';
select /*+ index(user_post_info idx_user_post_info_post_createdate) */ user_id, post_id, post_path, post_createdate from user_post_info where post_createdate between '20221101' and '20221231';
select post_createdate from user_post_info where post_createdate between '20221101' and '20221231';



-- 게시글 좋아요 30개 이상
select /*+ index(user_post_info idx_user_post_info_post_like) */ * from user_post_info where
post_like >=3000;

select * from user_post_info where
post_like >=3000;


-- 
select /*+ FULL(user_post_info) */ count(*) from user_post_info where post_createdate between '20221101' and '20221231';

select count(*) from user_post_info where post_createdate between '20221101' and '20221231';


select user_id, oauth_type, email from user_info where user_id = 'Yale';

-- 게시글
select user_id from user_info where oauth_type = 'facebook';
select /*+  index(user_info idx_user_info_oauth_type_user_id) */ user_id from user_info where oauth_type = 'facebook';
create index idx_user_info_oauth_type_user_id on user_info(oauth_type);


-- 
select user_id, post_id from user_post_info where post_id = max(post_id);