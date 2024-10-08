/*
font 바꾸기 - edit/preferences -> font and color
sql파일 열기 - control + shift + o
*/

-- 주석. sql문 실행 -> control + enter
/* block 주석 */
-- 사용자 계정 생성

-- local 접속 계정
create user 'playdata'@localhost identified by '1111';
-- 원격 접속 계정
create user 'playdata'@'%' identified by '1111';
-- 등록된 사용자계정 조회
select user, host from mysql.user;

-- 계정에 권한 부여
grant all privileges on *.* to playdata@localhost;
grant all privileges on *.* to playdata@'%';


create database testdb;
use testdb;

/*
테이블: 회원 (member)
속성
id: varchar2(10) primary key
password: varchar2(10) not null (필수)
name: nvarchar2(30) not null
point: number(6) nullable(null을 허용-not null이 아니면 nullable)  -999999 ~ 999999. number(6,2) -9999.99 ~ 9999.99
join_date: date not null
*/
-- 컬럼명   데이터타입   제약조건
create table member (
	 id  varchar(10)  primary key,
     password  varchar(10)  not null,
     name  varchar(50)  not null,
     point  int   default 1000,
     email  varchar(100)  unique,
     gender char(1) check(gender in ('m', 'f')), -- ***** check 대문자 'M'도 들어간다. 흠
     age int check(age > 0),
     join_date  timestamp  not null  default current_timestamp
);

desc member;
-- 테이블 삭제
drop table member;

-- 한행 insert (데이터를 삽입)
insert into member values ('id-111', '1111', '홍길동', 3000, 'abc@a.com', 'm', 20, '2020-1-2 10:10:20');

insert into member (id, password, name,  join_date) 
				   values ('id-1', '1111', '홍길동',  '2020-05-20');

-- 모든 컬럼에 값을 다 넣을 경우 컬럼 지정하는 것은 생략가능
insert into member values ('id-2', '2222', '박영희', 2000, '2019-12-10');

-- 특정 컬럼에만 값을 넣을 경우 컬럼명을 지정해햐 한다.
-- point, join_date는 생략하면 default값이 들어간다.
insert into member (id, password, name)
			        values ('id-3', '3333', '김영수');

-- joint_date 는 not null이지만 안넣으면 설정된 default값이 들어간다. 단 null을 명시적으로 넣으면 에러.
insert into member (id, password, name)
				   values ('id-4', '3333', '김영수'); 

insert into member (id, password, name,  join_date)
				   values ('id-5', '3333', '김영수', null); -- null은 제약조건을 어겼으므로 에러 발생


insert into member values ('id-6', '3333', '박철우', null, '2010-10-10'); -- point는 not null이므로 정상처리





