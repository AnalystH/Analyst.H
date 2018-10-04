create
	table
		coin_price_histories(
			coin_name varchar(100) not null,
			get_date varchar(8) not null,
			price_at_open numeric(
				19,
				10
			),
			price_at_high numeric(
				19,
				10
			),
			price_at_low numeric(
				19,
				10
			),
			price_at_close numeric(
				19,
				10
			),
			volume numeric(19),
			marketcap numeric(19)
		);

create
	unique index coin_price_histories_uk01 on
	coin_price_histories(
		coin_name,
		get_date
	);

	
	
-- truncate table coin_price_histories;

-- insert from file
copy coin_price_histories
from
'/Users/prokbk/onedrive/study/coin/get_coin_price_history/CoinPriceHistory.csv_20171202' with(
	FORMAT csv
);



copy coin_price_histories_tmp
from
'/Users/prokbk/onedrive/study/coin/get_coin_price_history/CoinPriceHistory.csv_20171202' with(
	FORMAT csv
);



truncate table coin_price_histories;

insert into coin_price_histories
select distinct * from coin_price_histories_tmp;

copy coin_price_histories
from
'[성욱씨 경로로 지정]/CoinPriceHistory.csv_mod2' with(
	FORMAT csv
);



 
with coin_name_list as (
	select 
		coin_name
		, get_date
		, price_at_close
	from coin_price_histories
	where (coin_name, get_date) 
	in (
		select 
			coin_name 
			, max(get_date)
		from coin_price_histories
		group by coin_name
	) 
) 
, price_history as ( 
	select row_number() over(partition by coin_name order by get_date desc) date_rank 
		,  coin_name
		,  get_date
		,  price_at_close
		,  volume
		,  max(get_date) over(partition by coin_name ) max_get_date
		,  min(get_date) over(partition by coin_name ) min_get_date
		,  max(price_at_close) over(partition by coin_name ) max_price_at_close
		,  min(price_at_close) over(partition by coin_name ) min_price_at_close
		,  (max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) * 1.0   --  
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 30 price_gap -- 40 == 40 weeks
		,  trunc( price_at_close * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) 
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 30 ) ) price_group_1  -- price_at_close, 매물대 그룹 
		,  trunc( (price_at_close * 0.7 + price_at_open * 0.3 ) * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) / 20) ) price_group_2  -- price_at_close
		,  max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) max_price_in_7d -- 7일 중 고
		,  min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) min_price_in_7d-- 7일 중 저
		,  max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) max_price_in_14d-- 14일 중 저
		,  min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) min_price_in_14d-- 14일 중 저
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) 
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING)
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 21 FOLLOWING)
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) 
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING)
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 21 FOLLOWING)	
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d -- moving average 7 days 
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 52 FOLLOWING) ma_52d
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 365 FOLLOWING) ma_356d
	from coin_price_histories
	where coin_name = 'neo'
),
major_price_list as ( 
	select 
		coin_name
		, sum(case when  rnk = 1 then avg_price_at_close end ) major_price_1
		, sum(case when  rnk = 2 then avg_price_at_close end ) major_price_2
		, sum(case when  rnk = 3 then avg_price_at_close end ) major_price_3
		, sum(case when  rnk = 4 then avg_price_at_close end ) major_price_4
		, sum(case when  rnk = 5 then avg_price_at_close end ) major_price_5
		, sum(case when  rnk = 6 then avg_price_at_close end ) major_price_6
		, sum(case when  rnk = 7 then avg_price_at_close end ) major_price_7
		, sum(case when  rnk = 8 then avg_price_at_close end ) major_price_8
		, sum(case when  rnk = 9 then avg_price_at_close end ) major_price_9
		, sum(case when  rnk = 10 then avg_price_at_close end ) major_price_10
		, sum(case when  rnk = 11 then avg_price_at_close end ) major_price_11
		, sum(case when  rnk = 12 then avg_price_at_close end ) major_price_12
		, sum(case when  rnk = 13 then avg_price_at_close end ) major_price_13
		, sum(case when  rnk = 14 then avg_price_at_close end ) major_price_14
		, sum(case when  rnk = 15 then avg_price_at_close end ) major_price_15
	from 
	(
		select /* 매물대 상위 그룹 15개 */
			pp.coin_name 
			,rank() over(partition by pp.coin_name order by pp.coin_name,  pp.volume_sum desc ) rnk
			,pp.avg_price_at_close
		--	into aeon_coin
		from coin_name_list  c 
			join lateral (
				select 	
					coin_name
					, price_group_1
					, avg(price_at_close)  avg_price_at_close
					, sum(volume) volume_sum
					, avg(price_gap) price_gap
				from price_history p 
				where p.coin_name = c.coin_name
				group by 
					coin_name
					, price_group_1
				order by sum(volume) desc 	
				limit 15
			) pp on true 
	) as v 
	group by coin_name 
)
select 
	get_date 
	,h.price_at_close
	,l.*
from 
	major_price_list l 
	join price_history h  on l.coin_name = h.coin_name
;

--drop table coin_price_histories_v2; 
with t as ( 
	select 
		/* drop table coin_price_histories_v2  쿼리 실행 전 테이블 유무 확인 
		 * 기존 테이블에서 window 함수 이용 이동평균, 매물대그룹, 최근x일 최대/최소 가격/날짜 등 출
		 * */ 
		row_number() over(partition by coin_name order by get_date desc) date_rank 
		,  coin_name
		,  get_date
		,  price_at_close
		,  volume
		,  max(get_date) over(partition by coin_name ) max_get_date
		,  min(get_date) over(partition by coin_name ) min_get_date
		,  max(price_at_close) over(partition by coin_name ) max_price_at_close
		,  min(price_at_close) over(partition by coin_name ) min_price_at_close
		,  (max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) * 1.0   --  
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 7 price_gap -- 40 == 40 weeks
		,  trunc( price_at_close * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) 
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 7 ) ) price_group_1  -- price_at_close, 매물대 그룹 
	--		,  trunc( (price_at_close * 0.7 + price_at_open * 0.3 ) * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) / 20) ) price_group_2  -- price_at_close
		,  max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) max_price_in_7d -- 7일 중 고
		,  min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) min_price_in_7d-- 7일 중 저
		,  max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) max_price_in_14d-- 14일 중 저
		,  min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) min_price_in_14d-- 14일 중 저
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) price_at_close_m_max7
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) price_at_close_m_max14
		, price_at_close - max(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 21 FOLLOWING) price_at_close_m_max21
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING)  price_at_close_m_min7
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 14 FOLLOWING) price_at_close_m_min14
		, price_at_close - min(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 21 following) price_at_close_m_min21
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d -- moving average 7 days 
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 52 FOLLOWING) ma_52d
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 365 FOLLOWING) ma_356d
	--	into coin_price_histories_v2
	from coin_price_histories
	) 
select 
	* 
	, last_value(ma_7d) over(partition by coin_name order by get_date desc rows between current row and 7 following ) ma_7d_last_value
	, (ma_7d - (last_value(ma_7d) over(partition by coin_name order by get_date desc rows between current row and 7 following )) ) * 1.0
		/(last_value(ma_7d) over(partition by coin_name order by get_date desc rows between current row and 7 following )) incr_ratio
	from t ; 
;


drop table kkbox_members; 
create
	table
		kkbox_members(
			msno varchar(52),
			city int ,
			bd int , -- age
			gender varchar(10),
			registered_via int,
			registration_init_time varchar(8)
		);

COPY kkbox_members FROM '/Users/prokbk/Projects/kaggle/members_v3.csv' DELIMITER ',' CSV HEADER


create
	table
		kkbox_transactions_2(
			msno varchar(52),
			payment_method_id int ,
			payment_plan_days int ,
			plan_list_price int ,
			actual_amount_paid int ,
			is_auto_renew int ,
			transaction_date varchar(8),
			membership_expire_date varchar(8),
			is_cancel int 
		);
		
COPY kkbox_transactions_2 FROM '/Users/prokbk/Projects/kaggle/transactions_v2.csv' DELIMITER ',' CSV HEADER

insert into kkbox_transactions
select * from kkbox_transactions_2 a where not exists (select 0 from kkbox_transactions b where b.msno = a.msno and b.transaction_date = a.transaction_date 
and a.* <> b.*) ;
-- YIW/2sBKhNRWWUyz6moNh9RjMOrkI54mlSbsme27Gc4=	32	410	1788	1788	0	20170215	20180403	0

select distinct * 
	into kkbox_transactions_3
from kkbox_transactions


alter table kkbox_transactions_3 rename to kkbox_transactions

select count(*), sum(case when a.* is not null then 1 end )  from kkbox_transactions a ;


with t as (
	select 1 c1 , null::int c2 union all 
	select 2 c1,  2 
)
,
t1 as (select 2 c1, 3 c2 )
--select  count(*) , sum(case when t.* is not null then 1 end )from t
select *
from t 
where exists (
	select 1
	from t1 
	where t1.c1 = t.c1
	  and t1.* <> t.*
) 



--explain
select 
	msno, transaction_date, min(is_cancel), max(is_cancel)
from kkbox_transactions
group by 1,2
having count(*) > 1
limit 20

select 
		* 
--		, lag( to_date(transaction_date, 'yyyymmdd') ) over(partition by msno order by transaction_date) 
--		, lag( to_date(membership_expire_date, 'yyyymmdd') ) over(partition by msno order by membership_expire_date)  lag_membership_expire_date
		, to_date(membership_expire_date, 'yyyymmdd') membership_expire_date
		, to_date(transaction_date, 'yyyymmdd') transaction_date
--		, to_date(membership_expire_date, 'yyyymmdd')  - lag( to_date(membership_expire_date, 'yyyymmdd') ) over(partition by msno order by membership_expire_date) 
from kkbox_transactions
where msno = '++0BJXY8tpirgIhJR14LDM1pnaRosjD1mdO1mIKxlJA='
--order by transaction_date
;

select * from kkbox_members where msno = '++0BJXY8tpirgIhJR14LDM1pnaRosjD1mdO1mIKxlJA=';


create unique index kkbox_members_uk01 on kkbox_members(msno);


select to_date('20170122', 'yyyymmdd');

create
	table
		kkbox_transactions(
			msno varchar(52),
			payment_method_id int ,
			payment_plan_days int ,
			plan_list_price int ,
			actual_amount_paid int ,
			is_auto_renew int ,
			transaction_date varchar(8),
			membership_expire_date varchar(8),
			is_cancel int 
		);
		
COPY kkbox_transactions FROM '/Users/prokbk/Projects/kaggle/transactions.csv' DELIMITER ',' CSV HEADER

create index kkbox_transactions_ix01 on kkbox_transactions(  transaction_date);

create index kkbox_transactions_ix03 on kkbox_transactions(  msno, transaction_date);

create index kkbox_transactions_ix02 on kkbox_transactions(  membership_expire_date);

select min(transaction_date) , max(transaction_date) from kkbox_transactions;

select  
	substring(transaction_date,1,6) ,
	count(*),
	count(distinct msno)
from  kkbox_transactions
where transaction_date >= '20170101'
group by substring(transaction_date,1,6);



select 
	payment_plan_days,
	count(*)
from kkbox_transactions
group by 1 ;


select count(*) from kkbox_members;

select 
	gender
	, city
	,	count(*)
from kkbox_members
group by 1,2
order by 2,1

select 
	distinct registered_via
from kkbox_members 
order by 1


select 
	*
from kkbox_members 
limit 10


select trunc( bd::int / 5 ), count(*) 
from kkbox_members
where gender is null 
group by  1


select 
	city,kkbox_members, count(*)
from kkbox_members
group by 1,2 
order by 1

select count(msno), count(distinct msno) from kkbox_members;


--grant all privileges on database postgres to coin ;

create user 		coin ;
create database 	coin ;

alter user coin with encrypted password 'coin';
grant all on database coin to coin 



create
	table
		coin_price_histories(
			coin_name varchar(100) not null,
			get_date varchar(8) not null,
			price_at_open numeric(
				19,
				10
			),
			price_at_high numeric(
				19,
				10
			),
			price_at_low numeric(
				19,
				10
			),
			price_at_close numeric(
				19,
				10
			),
			volume numeric(19),
			marketcap numeric(19)
		);

create
	unique index coin_price_histories_uk01 on
	coin_price_histories(
		coin_name,
		get_date
	);

	
	
-- truncate table coin_price_histories;

-- insert from file
copy coin_price_histories
from
'/Users/prokbk/onedrive/study/coin/get_coin_price_history/CoinPriceHistory.csv_mod2' with(
	FORMAT csv
);


select ln(1)

2017-04-04 0.0049
2017-07-17 0.29689212


select date('2017-07-17') - date('2017-04-04')

select 0.0049 * power(1.04023,date('2017-11-17') - date('2017-04-04')) 


select power(10,3)
