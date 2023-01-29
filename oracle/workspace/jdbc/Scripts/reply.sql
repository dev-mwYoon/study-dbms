CREATE SEQUENCE SEQ_REPLY;

CREATE TABLE TBL_REPLY(
   REPLY_ID NUMBER CONSTRAINT PK_REPLY PRIMARY KEY,
   REPLY_CONTENT VARCHAR2(1000) NOT NULL,
   REPLY_REGISTER_DATE DATE DEFAULT SYSDATE,
   REPLY_UPDATE_DATE DATE DEFAULT SYSDATE,
   USER_ID NUMBER NOT NULL,
   BOARD_ID NUMBER NOT NULL,
   REPLY_GROUP NUMBER NOT NULL,
   REPLY_DEPTH NUMBER NOT NULL,
   CONSTRAINT FK_REPLY_USER FOREIGN KEY(USER_ID) REFERENCES TBL_USER(USER_ID) ON DELETE CASCADE,
   CONSTRAINT FK_REPLY_BOARD FOREIGN KEY(BOARD_ID) REFERENCES TBL_BOARD(BOARD_ID) ON DELETE CASCADE
);

SELECT * FROM TBL_REPLY;



SELECT NVL(REPLY_COUNT, 0) REPLY_COUNT, REPLY_ID, REPLY_CONTENT, R2.USER_ID, BOARD_ID, REPLY_REGISTER_DATE, REPLY_UPDATE_DATE, 
R2.REPLY_GROUP, REPLY_DEPTH, 
USER_IDENTIFICATION, USER_NAME, USER_PASSWORD, 
USER_PHONE, USER_NICKNAME, USER_EMAIL, USER_ADDRESS, USER_BIRTH, 
USER_GENDER, USER_RECOMMENDER_ID 
FROM (SELECT REPLY_GROUP, COUNT(REPLY_ID) - 1 REPLY_COUNT FROM TBL_REPLY GROUP BY REPLY_GROUP) R1 RIGHT OUTER JOIN VIEW_REPLY_USER R2
ON R1.REPLY_GROUP = R2.REPLY_GROUP AND R1.REPLY_GROUP = R2.REPLY_ID;

SELECT * FROM VIEW_REPLY_USER;

CREATE OR REPLACE VIEW VIEW_REPLY_USER
AS
SELECT REPLY_ID, REPLY_CONTENT, U.USER_ID, BOARD_ID, REPLY_REGISTER_DATE, REPLY_UPDATE_DATE, 
REPLY_GROUP, REPLY_DEPTH,
USER_IDENTIFICATION, USER_NAME, USER_PASSWORD, 
USER_PHONE, USER_NICKNAME, USER_EMAIL, USER_ADDRESS, USER_BIRTH, 
USER_GENDER, USER_RECOMMENDER_ID 
FROM TBL_USER U, TBL_REPLY R
WHERE U.USER_ID = R.USER_ID;





