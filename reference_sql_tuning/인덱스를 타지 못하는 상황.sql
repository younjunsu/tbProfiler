-- 인덱스 컬럼 가공
select * from user_info where
to_char(uuid) = '1'

1 = uuid*1000;

-- 인덱스 컬럼 함수


-- 