/*
	▷ WITH절 
	- 기본 구조
	WITH
	WITH_SUB AS (
		~~~ -- 서브쿼리 부분
	)
	SELECT * FROM WITH_SUB; -- WITH절을 사용한 메인 쿼리
	
	▷ Recursive WITH절
	- WITH 절을 가지고 자신이 자신을 호출하는 Recursive한 방식 사용 가능.
	  ㄴ Rcursive With절 이라 지칭.
	  
	- 예제 ( 1~9 피보나치 수열 )
	WITH
	SUM(NUM, RESULT) AS(
		-- 초기값을 설정해주는 초기 서브쿼리이다. 즉 NUM=1, RESULT=1 이다.
		SELECT 
			1,1 
		FROM DUAL 
		UNION ALL
		-- 이후 행위를 정의한 Recurisive 서브쿼리이다. NUM의 값은 1씩 증가시키며, RESULT 값에는 계속 (NUM + 1)을 더한다.
		SELECT 
			NUM+1, (NUM+1) + RESULT 
		FROM SUM 
		WHERE NUM < 9-- 종료조건으로 NUM < 9를 작성했다.
	)
	SELECT 
		NUM ,RESULT 
	FROM SUM;
	
	▷ 계층형 WITH절
	- 오라클에서는 계층형 쿼리를 위해 CONNECT BY 지원.
	- WITH절은 ORACLE 이외에 DBMS에서도 지원.
	
	- 예제 ( WITH 계층형 쿼리 버전 )
	WITH WITH_DEPT (DEPT_LEVEL, LVL, DEPT_ID, PAR_ID, DEPT_NAME) AS (
		SELECT 
			LPAD('-- -- -- -- ', 0) AS DEPT_LEVEL, 
			1 AS LVL, -- LVL=1
			DEPT_ID, PAR_ID, DEPT_NAME
		FROM V_EX_DEPT
		WHERE DEPT_ID = '000000101' -- 시작 부서 설정 ( 최상위 부서 )
		UNION ALL 
		SELECT 
			LPAD('-- -- -- -- ', 3*((WD.LVL+1) - 1) ) AS DEPT_LEVEL, 
			(WD.LVL + 1) AS LVL, 
			D.DEPT_ID, D.PAR_ID, D.DEPT_NAME
		FROM V_EX_DEPT D, WITH_DEPT WD -- V_EX_DEPT(이번계층), WITH_DEPT(이전계층)
		--WHERE D.PAR_ID = WD.DEPT_ID -- 이전계층의 나 = 이번계층의 부모
		WHERE WD.DEPT_ID = D.PAR_ID -- 이전계층의 나 = 이번계층의 부모
	)
	SELECT DEPT_LEVEL || DEPT_NAME AS DEPT_LEVEL, LVL, DEPT_NAME, PAR_ID, DEPT_ID 
	FROM WITH_DEPT;
	
	- 예제 ( 오라클 계층형 쿼리 버전 )
	SELECT LPAD('-- -- -- -- ', 3*(LEVEL-1)) || DEPT_NAME AS DEPT_LEVEL, LEVEL, A.*
	FROM V_EX_DEPT A
	START WITH DEPT_ID = '000000101'
	CONNECT BY PRIOR DEPT_ID = PAR_ID; -- 바로 전에(PRIOR) 구한 계층의 DEPT_ID를 PAR_ID로 갖는 데이터
	-- 이전계층의 값	=  이번계층의 값
	-- 이전계층의 나	=  이번계층의 부모
	-- 이전계층의 부모	=  이번계층의 나
 */


/*
 
 	▷ 예제 TABLE & VIEW
 	
 	CREATE TABLE V_EX_DEPT(
		DEPT_ID		CHAR(9) NOT NULL,
		DEPT_NAME 	VARCHAR2(200) NOT NULL,
		PAR_ID		CHAR(9) NOT NULL,
		SEQ			NUMBER(3,0) NOT NULL
	);
	
	COMMIT;
	
	INSERT INTO TBL_EX_DEPT
	(DEPT_ID, DEPT_NAME, PAR_ID, SEQ)
	SELECT '000000101','최상위부서','000000000',0
	FROM DUAL
	UNION ALL
	SELECT '000010000','테스트부서1','000000101',1
	FROM DUAL
	UNION ALL
	SELECT '000010001','테스트부서3','000000101',2
	FROM DUAL
	UNION ALL
	SELECT '000010200','테스트부서22','000010001',1
	FROM DUAL;
	
	COMMIT;
	
	SELECT DEPT_ID, DEPT_NAME, PAR_ID, SEQ FROM TBL_EX_DEPT; ( 아래는 조회 값 )
	000000101	최상위부서		000000000	0
	000010000	테스트부서1	000000101	1
	000010001	테스트부서3	000000101	2
	000010200	테스트부서22	000010001	1

	CREATE VIEW V_EX_DEPT AS
	 SELECT PAR_ID, DEPT_ID, DEPT_NAME, 
		SUBSTR(SYS_CONNECT_BY_PATH(DEPT_NAME, '|'),2) FULLNAME,
		SUBSTR(SYS_CONNECT_BY_PATH(DEPT_ID, '|'),2) FULLID, 
		SEQ
	FROM
	( 
		SELECT DEPT_ID, DEPT_NAME, PAR_ID, SEQ 
		FROM TBL_EX_DEPT
	)
	START WITH DEPT_ID = '000000101' CONNECT BY PRIOR DEPT_ID = PAR_ID
	ORDER SIBLINGS BY PAR_ID, SEQ;
	
	COMMIT;
 
 */




WITH WITH_DEPT (DEPT_LEVEL, LVL, DEPT_ID, PAR_ID, DEPT_NAME) AS (
	SELECT 
		LPAD('-- -- -- -- ', 0) AS DEPT_LEVEL, 
		1 AS LVL, -- LVL=1
		DEPT_ID, PAR_ID, DEPT_NAME
	FROM V_EX_DEPT
	WHERE DEPT_ID = '000000101' -- 시작 부서 설정 ( 최상위 부서 )
	UNION ALL 
	SELECT 
		LPAD('-- -- -- -- ', 3*((WD.LVL+1) - 1) ) AS DEPT_LEVEL, 
		(WD.LVL + 1) AS LVL, 
		D.DEPT_ID, D.PAR_ID, D.DEPT_NAME
	FROM V_EX_DEPT D, WITH_DEPT WD -- V_EX_DEPT(이번계층), WITH_DEPT(이전계층)
	--WHERE D.PAR_ID = WD.DEPT_ID -- 이전계층의 나 = 이번계층의 부모
	WHERE WD.DEPT_ID = D.PAR_ID -- 이전계층의 나 = 이번계층의 부모
)
SELECT DEPT_LEVEL || DEPT_NAME AS DEPT_LEVEL, /*LVL, */DEPT_NAME, PAR_ID, DEPT_ID 
FROM WITH_DEPT;



SELECT LPAD('-- -- -- -- ', 3*(LEVEL-1)) || DEPT_NAME AS DEPT_LEVEL, LEVEL, A.*
FROM V_EX_DEPT A
START WITH DEPT_ID = '000000101'
CONNECT BY PRIOR DEPT_ID = PAR_ID; -- 바로 전에(PRIOR) 구한 계층의 DEPT_ID를 PAR_ID로 갖는 데이터
-- 이전계층의 값	=  이번계층의 값
-- 이전계층의 나	=  이번계층의 부모
-- 이전계층의 부모	=  이번계층의 나
