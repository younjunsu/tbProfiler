 CREATE TABLE user_info_new AS 
	SELECT
		rownum uuid,
		A.userid,
		A.password,
		A.email,
		A.oauth_type
	FROM
		(
		SELECT
			A.*,
			ROW_NUMBER() OVER(PARTITION BY A.userid	ORDER BY A.userid) RN
		FROM
			user_info A) A
	WHERE
		A.RN = 1
		;



create table user_info(
  uuid number(38),
  user_id number(4000),
  password varchar2(4000),
  email varchar2(1000),
  oauth_type varchar2(1000),
  singup_date date
);

create table user_post_info(
  uuid varchar2(5000),
  user_id varchar2(1000),
  post_id number(38),
  post_path varchar2(5000),
  post_view number(38),
  post_like number(38),
  post_dislike number(38),
  post_createdate date
);
  
create table user_comment_info
(	
  uuid number(38),
  user_id varchar2(1000),
  post_id number(38),
  comment_id number(38),
  comment_content varchar2(4000),
  comment_like number(38),
  comment_dislike number(38),
  comment_createdate date
);


INSERT INTO user_post_info(uuid,user_id,post_id,post_path,post_view,post_like,post_dislike,post_createdate)
		SELECT
                seq_post_info_uuid.nextval uuid,
                (SELECT user_id FROM user_info WHERE uuid =b.rand) user_id,
                seq_post_info_uuid.nextval post_id,
                'path:/contents/post/'||seq_post_info_uuid.nextval||'/'||rownum post_path,
                CEIL(dbms_random.VALUE(0,50000))   post_view,
                CEIL(dbms_random.VALUE(0,4000))  post_like,
                CEIL(dbms_random.VALUE(0,4000)) post_dislike,
                (SELECT singup_date + b.trand FROM user_info WHERE uuid =b.rand) post_createdate
        FROM
            (SELECT CEIL(dbms_random.VALUE(1,1046847)) rand, CEIL(dbms_random.VALUE(1,1085)) trand FROM dual CONNECT BY LEVEL <=3000000) b
;	


INSERT INTO user_comment_info_date(uuid,user_id,post_id,comment_id,comment_content,comment_like,comment_dislike,comment_createdate)
SELECT 
	seq_comment_uuid.nextval uuid,
	(SELECT user_id FROM user_info_date WHERE uuid =b.rand) user_id,
	(SELECT post_id FROM user_post_info_date WHERE post_id = b.prand) post_id,
	seq_comment_uuid.nextval comment_id,
	dbms_random.string('p',b.trand) comment_content,	
	dbms_random.VALUE(0,1000) comment_like,
	dbms_random.VALUE(0,1001) comment_dislike,
	(SELECT POST_CREATEDATE + b.trand AS post_createdate FROM user_post_info_date WHERE post_id = b.prand) comment_createdate
FROM
	(
		SELECT 
			CEIL(dbms_random.VALUE(1,1046847)) rand, 
			CEIL(dbms_random.VALUE(1,1085)) trand,
			CEIL(dbms_random.value(1,3000000)) prand
		FROM dual CONNECT BY LEVEL <=5000000
	) b
;	



exec dbms_stats.gather_table_stats(ownname=>'TIBERO', TABNAME=>'USER_POST_INFO');
exec dbms_stats.gather_table_stats(ownname=>'TIBERO', TABNAME=>'USER_COMMENT_INFO');