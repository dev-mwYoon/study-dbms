/*JOBS 테이블에서 JOB_ID로 직원들의 JOB_TITLE, EMAIL, 성, 이름 검색*/
SELECT J.JOB_TITLE 직업, E.EMAIL 이메일, E.LAST_NAME 성, E.FIRST_NAME 이름
FROM JOBS j JOIN EMPLOYEES e 
ON J.JOB_ID = E.JOB_ID; 

SELECT J.JOB_TITLE 직업, E.EMAIL 이메일, E.LAST_NAME || ' ' || E.FIRST_NAME 이름
FROM JOBS j JOIN EMPLOYEES e 
ON J.JOB_ID = E.JOB_ID; 

/*EMP 테이블의 SAL을 SALGRADE 테이블의 등급으로 나누기*/
SELECT s.GRADE , e.SAL 
FROM SALGRADE s JOIN EMP e 
ON e.SAL BETWEEN S.LOSAL AND S.HISAL;

SELECT *
FROM SALGRADE s JOIN EMP e 
ON e.SAL BETWEEN S.LOSAL AND S.HISAL;

/*세타 조인*/
SELECT * 
FROM SALGRADE s , EMP e 
WHERE e.SAL BETWEEN S.LOSAL AND S.HISAL;

/*EMPLOYEES 테이블에서 HIREDATE가 2003~2005년까지인 // 사원의 정보와 부서명 검색*/
SELECT E.*, D.DEPARTMENT_NAME 
FROM DEPARTMENTS d  JOIN EMPLOYEES e
ON D.DEPARTMENT_ID = E.DEPARTMENT_ID 
AND E.HIRE_DATE BETWEEN '2003-01-01' AND '2005-12-31';

SELECT E.*, D.DEPARTMENT_NAME 
FROM DEPARTMENTS d  JOIN EMPLOYEES e
ON D.DEPARTMENT_ID = E.DEPARTMENT_ID 
AND E.HIRE_DATE BETWEEN TO_DATE('2003', 'YYYY') AND TO_DATE('2005', 'YYYY');

SELECT SYS_CONTEXT('USERENV', 'NLS_DATE_FORMAT') FROM DUAL;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY';
ALTER SESSION SET NLS_DATE_FORMAT = 'RR/MM/DD';

/*JOB_TITLE 중 'Manager'라는 문자열이 포함된 직업들의 평균 연봉을 // JOB_TITLE별로 검색*/
SELECT J.JOB_TITLE , AVG(E.SALARY) 
FROM JOBS j JOIN EMPLOYEES e 
ON J.JOB_ID = E.JOB_ID AND J.JOB_TITLE LIKE '%Manager%' 
GROUP BY J.JOB_TITLE;

/*EMP 테이블에서 ENAME에 L이 있는 사원들의 DNAME과 LOC 검색*/
SELECT D.DNAME, D.LOC ,E.ENAME 
FROM DEPT d JOIN EMP e
ON D.DEPTNO = E.DEPTNO AND E.ENAME LIKE '%L%';


/*축구 선수들 중에서 각 팀별로 // 키가 가장 큰 선수들 전체 정보 검색*/
SELECT p.*
FROM 
(
	SELECT TEAM_ID, MAX(HEIGHT) MAX_HEIGHT
	FROM PLAYER
	GROUP BY TEAM_ID 
) P1 JOIN PLAYER p 
ON P1.TEAM_ID = p.TEAM_ID AND P1.MAX_HEIGHT = p.HEIGHT
ORDER BY P.TEAM_ID ;

/*(A, B) IN (C, D) : A = C AND B = D*/
SELECT * 
FROM PLAYER p 
WHERE (TEAM_ID, HEIGHT) IN (
	SELECT TEAM_ID, MAX(HEIGHT) MAX_HEIGHT
	FROM PLAYER
	GROUP BY TEAM_ID )
ORDER BY TEAM_ID ;

/*EMP 테이블에서 사원의 이름과 매니저 이름을 검색*/
/*
SELECT E2.ENAME 사원이름 , E1.ENAME 매니저이름, E2.DEPTNO 
FROM 
(
	SELECT DEPTNO , ENAME , JOB 
	FROM EMP e 
	WHERE JOB = 'MANAGER'
) E1 JOIN EMP E2 ON E1.DEPTNO = E2.DEPTNO AND E1.DEPTNO = E2.DEPTNO 
ORDER BY E2.DEPTNO;
*/

/*셀프 조인*/
/*E1의 매니저를 찾아주세요니까 E2가 매니저 E1이 사원*/
SELECT E1.ENAME EMPLOYEE, E2.ENAME MGR
FROM EMP e1 JOIN EMP e2
ON E1.MGR = E2.EMPNO ;

/*SQL 실행 순서*/
/*FROM > ON > JOIN > WHERE > GROUP BY > HAVING > SELECT > ORDER BY*/

/*[브론즈]*/
/*PLAYER 테이블에서 키가 NULL인 선수들은 키를 170으로 변경하여 평균 구하기(NULL 포함)*/
SELECT AVG(NVL(HEIGHT, 170)) AS "평균 키"
FROM PLAYER p ;

/*[실버]*/
/*PLAYER 테이블에서 팀 별 최대 몸무게*/
SELECT TEAM_ID, MAX(WEIGHT) "최대 몸무게"
FROM PLAYER p 
GROUP BY TEAM_ID 
ORDER BY TEAM_ID ;

/*[골드]*/
/*AVG 함수를 쓰지 않고 PLAYER 테이블에서 선수들의 평균 키 구하기(NULL 포함)*/
SELECT SUM(HEIGHT) / COUNT(PLAYER_ID)  
FROM PLAYER p ;

SELECT SUM(NVL(HEIGHT, 0)) / COUNT(NVL(HEIGHT, 0)) 
FROM PLAYER p ;

SELECT AVG(NVL(HEIGHT, 0))
FROM PLAYER p ;

/*[플래티넘]*/
/*DEPT 테이블의 LOC별 평균 급여를 반올림한 값과// 각 LOC별 SAL 총 합을 조회, 반올림 : ROUND()*/
SELECT D.LOC "지역", ROUND(AVG(E.SAL), 2) "평균 급여", SUM(E.SAL) "총 합"
FROM DEPT d JOIN EMP e
ON D.DEPTNO = E.DEPTNO 
GROUP BY D.LOC ;



/*[다이아]*/
/*PLAYER 테이블에서 팀별 최대 몸무게인 선수 검색*/
SELECT *
FROM PLAYER p1
WHERE (TEAM_ID, WEIGHT) IN (
	SELECT TEAM_ID , MAX(WEIGHT) 
	FROM PLAYER p 
	GROUP BY TEAM_ID
) 
ORDER BY TEAM_ID ;

SELECT *
FROM PLAYER p1
WHERE (
	SELECT TEAM_ID , MAX(WEIGHT) 
	FROM PLAYER p 
	GROUP BY TEAM_ID) IN (TEAM_ID, WEIGHT) 
ORDER BY TEAM_ID ;

SELECT P2.*
FROM 
(
	SELECT TEAM_ID , MAX(WEIGHT) WEIGHT 
	FROM PLAYER p 
	GROUP BY TEAM_ID
) P1 JOIN PLAYER P2 ON P1.TEAM_ID = P2.TEAM_ID AND P1.WEIGHT = P2.WEIGHT 
ORDER BY P2.TEAM_ID ;

/*[마스터]*/
/*EMP 테이블에서 HIREDATE가 FORD의 입사년도와 같은 사원 전체 정보 조회*/
/*
SELECT *
FROM EMP e 
WHERE HIREDATE =
(
	SELECT HIREDATE 
	FROM EMP e2 
	WHERE ENAME = 'FORD'
) AND ENAME != 'FORD';

SELECT *
FROM EMP e 
WHERE HIREDATE =
(
	SELECT HIREDATE 
	FROM EMP e2 
	WHERE ENAME = 'FORD'
);

SELECT E1.*
FROM EMP E1 JOIN
(
SELECT HIREDATE FROM EMP
WHERE ENAME = 'FORD' 
)E2
ON E1.HIREDATE = E2.HIREDATE;
*/
SELECT TO_CHAR(HIREDATE, 'YYYY') 
FROM EMP e 
WHERE ENAME = 'FORD';

SELECT *
FROM EMP e
WHERE TO_CHAR(HIREDATE, 'YYYY') =
(
	SELECT TO_CHAR(HIREDATE, 'YYYY') 
	FROM EMP e 
	WHERE ENAME = 'FORD'
);

/*외부 조인*/
/*JOIN 할 때 선행 또는 후행 중 하나의 테이블 정보를 모두 확인하고 싶을 때 사용한다.*/
SELECT TEAM_NAME , S.* 
FROM TEAM t RIGHT OUTER JOIN STADIUM s
ON T.TEAM_ID = S.HOMETEAM_ID ;

SELECT *
FROM TEAM t ;

/*DEPARTMENT 테이블에서 매니저 이름 검색, 매니저가 없더라도 부서명 모두 검색*/
SELECT D.DEPARTMENT_NAME , NVL(E.LAST_NAME, 'NO')  || ' ' || NVL(E.FIRST_NAME, 'NAME')   
FROM DEPARTMENTS d LEFT OUTER JOIN EMPLOYEES e 
ON D.DEPARTMENT_ID = E.DEPARTMENT_ID 
AND D.MANAGER_ID = E.EMPLOYEE_ID  
ORDER BY D.DEPARTMENT_ID ;


SELECT D.*
FROM DEPARTMENTS d;

/*EMPLOYEES 테이블에서 사원의 매니저 이름, 사원의 이름 조회, 매니저가 없는 사원은 본인이 매니저임을 표시*/

SELECT *
FROM EMPLOYEES e 
WHERE E.LAST_NAME || E.FIRST_NAME = 'KumarSundita';

SELECT E2.FIRST_NAME "사원 이름", NVL(E1.FIRST_NAME, E2.FIRST_NAME) "매니저 이름" 
FROM EMPLOYEES e1 RIGHT OUTER JOIN EMPLOYEES e2 
ON E2.MANAGER_ID = E1.EMPLOYEE_ID 
ORDER BY NVL(E2.MANAGER_ID, E1.EMPLOYEE_ID);

/*EMPLOYEES에서 각 사원별로 관리부서(매니저)와 소속부서(사원) 조회*/
SELECT E1.JOB_ID 관리부서, E2.JOB_ID 소속부서, E2.FIRST_NAME 이름 , E2.LAST_NAME 성
FROM 
(
	SELECT JOB_ID , MANAGER_ID 
	FROM EMPLOYEES E
	GROUP BY JOB_ID , MANAGER_ID 
) E1 
FULL OUTER JOIN EMPLOYEES E2
ON E2.EMPLOYEE_ID = E1.MANAGER_ID
ORDER BY 소속부서;

/*VIEW*/
/*CREA VIEW [이름] AS [쿼리문]*/
/*
 * 실제 데이터는 아닌데 보여지기 위한 용도?
 * 기존의 테이블을 그대로 놔둔 채 필요한 컬럼들 및 새로운 컬럼을 만든 가상 테이블
 * 실제 데이터가 저장되는 것은 아니지만 VIEW를 통해서 데이터를 관리할 수 있다.
 * 
 * - 독립성 : 다른 곳에서 접근하지 못하도록 하는 성질 EX) 아이디 비밀번호 테이블에서 아이디만 뷰로 보이게 설정
 * - 관리성 : 길고 복잡한 ㅝ리문을 매번 작성할 필요가 없다.
 * - 보안성 : 기존의 쿼리문이 보이지 않는다.
 * 
 */

/*PLAYER 테이블에 나이 컬럼 추가한 뷰 만들기*/
CREATE VIEW VIEW_PLAYER AS
SELECT FLOOR((SYSDATE - BIRTH_DATE) / 365) AGE, P.*
FROM PLAYER p ;

SELECT *
FROM VIEW_PLAYER vp ;

/*EMPLOYEES 테이블에서 사원 이름과 그 사원의 매니저 이름이 있는 VIEW 만들기*/
DROP VIEW VIEW_EMPLOYEES ;

CREATE VIEW VIEW_EMPLOYEES AS
SELECT E2.LAST_NAME || ' ' || E2.FIRST_NAME EMPLOYEE_NAME, E1.LAST_NAME || ' ' || E1.FIRST_NAME MANAGER_NAME
FROM EMPLOYEES E1 JOIN EMPLOYEES E2
ON E2.MANAGER_ID = E1.EMPLOYEE_ID ;

SELECT * FROM VIEW_EMPLOYEES ve ;


/*PLAYER 테이블에서 TEAM_NAME 컬럼을 추가한 VIEW 만들기*/
DROP VIEW VIEW_PLAYER ;

CREATE VIEW VIEW_PLAYER_TEAM AS
SELECT T.TEAM_NAME AS "TEAM_NAME", P.*
FROM TEAM t JOIN PLAYER p ON T.TEAM_ID = P.TEAM_ID ;

SELECT * FROM VIEW_PLAYER_TEAM ;


