-- sql 주석
# sql 주석
/*
block 주석
*/
-- control + enter: 실행
-- 명령문 뒤에 ; 을 붙인다. 
-- sql문은 대소문자 구분하지 않는다
-- 사용자 계정 (localhost)

create user scott@localhost identified by 'tiger';
-- 사용자 계정 (원격 접속 계정)
create user scott@'%' identified by 'tiger';

-- 권한 지정.
grant all privileges on *.* to scott@localhost;
grant all privileges on *.* to scott@'%';

-- 계정들 조회
select host, user from mysql.user;

-- 계정 삭제
drop user scott@'%';
drop user scott@localhost;

-- db 조회
show databases;

-- database를 생성
create database test;

use test;

drop table member;
create table member(
  num int unsigned auto_increment primary key,
  id varchar(20) not null,
  password varchar(20) not null,
  name varchar(50) not null,
  address varchar(100), 
  join_date datetime not null,
  email varchar(100) unique,
  gender char(1) not null check(gender in ('M', 'F'))
);
-- insert into member (id, password, name, join_date, gender) 
-- values ('id', 'aaaaaa', '이순신', '2020-01-02 10:10:20', '남');

insert into member (id, password, name, join_date, gender) 
values ('id-20', 'aaaaaa', '이순신', '2020-01-02 10:10:20', 'M');

insert into member values (100, 'id-10', 'abc111', '홍길동', '서울',
'2010-10-20 16:22:32', 'abc@a.com', 'M');

select * from member;


-- table 확인
show tables;
-- table의 컬럼(속성)들 확인. desc 테이블이름
desc member;

