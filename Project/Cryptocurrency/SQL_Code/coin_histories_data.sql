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

--drop table coin_price_histories;
create
	unique index coin_price_histories_uk01 on
	coin_price_histories(
		coin_name,
		get_date
	);

	
	
-- truncate table coin_price_histories;

-- insert from file
--copy coin_price_histories
--from
--'/Users/prokbk/onedrive/study/coin/get_coin_price_history/CoinPriceHistory.csv_mod2' with(
--	FORMAT csv
--);

copy coin_price_histories
from
'/Users/hsw/Desktop/개인 파일/스터디/Coin Project/data/CoinPriceHistory.csv_mod2' with(
	FORMAT csv
);

select * from coin_price_histories;

 
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
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 7 price_gap -- 40 == 40 weeks
		,  trunc( price_at_close * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) 
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 7 ) ) price_group_1  -- price_at_close, 매물대 그룹 
--		,  trunc( (price_at_close * 0.7 + price_at_open * 0.3 ) * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) / 20) ) price_group_2  -- price_at_close
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
	--where coin_name = 'aeon'
)
select /* 매물대 상위 그룹 15개 */
	pp.*
	, avg_price_at_close * 1110 as avg_price_at_close_krw
	, case when c.price_at_close > avg_price_at_close then '*' end 
	into all_coin
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
order by pp.coin_name
		, volume_sum desc 
;

--drop table coin_price_histories_v2; 

select 
	/* drop table coin_price_histories_v2  쿼리 실행 전 테이블 유무 확인 
	 * 기존 테이블에서 window 함수 이용 이동평균, 매물대그룹, 최근x일 최대/최소 가격/날짜 등 출
	 * */ 
	row_number() over(partition by coin_name order by get_date ) date_rank 
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
	--into coin_price_histories_v2
from coin_price_histories
;


select * from ( 
select 
	/* drop table coin_price_histories_v2  쿼리 실행 전 테이블 유무 확인 
	 * 기존 테이블에서 window 함수 이용 이동평균, 매물대그룹, 최근x일 최대/최소 가격/날짜 등 출
	 * */ 
	row_number() over(partition by coin_name order by get_date ) date_rank 
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
	--into coin_price_histories_v2
from coin_price_histories
) as v
where v.date_rank > 8;

;
select * from all_coin;
select * from coin_price_histories_v2;

copy coin_price_histories
to
'/Users/hsw/Desktop/개인 파일/스터디/Coin Project/data/CoinPriceHistory.csv_handle' with(
	FORMAT csv
);
--------------- ready -----------------
drop table coin_price_100; 
select 
	date_rank
	, coin_name
	, get_date
	, ma_7d
into coin_price_100 
from (
	select 
		*
		, count(*) over(partition by coin_name) cc
	from (
		select
			row_number() over(partition by coin_name order by get_date desc) date_rank
			, coin_name
			, get_date
			, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d
		from coin_price_histories
	) as n1 where n1.date_rank <= 100
) as n2 where cc = 100

select count(*) from coin_price_100 group by coin_name; -- 코인별로 자료가 100개 이상인 것들 중에 딱 100개만 추림.
select * from coin_price_100;

create unique index coin_price_100_uk01 on coin_price_100(coin_name, get_date);
create unique index coin_price_100_uk02 on coin_price_100(get_date , coin_name);
create unique index coin_price_100_uk03 on coin_price_100(coin_name , date_rank);
drop index coin_price_100_uk01;
drop index coin_price_100_uk02;
---------------------------------------------------
--drop table finish;
with unique_coin as ( 
	select
		distinct(coin_name)
	from coin_price_100
	order by coin_name
), possible_event as ( 
	select
		c1.coin_name coin1
		, c2.coin_name coin2
	from unique_coin c1 cross join unique_coin c2
	where c1.coin_name != c2.coin_name
),lagNum as (
	select generate_series(1,30) lag -- 원하는 lag 까지 확인 
)
select
	p.coin1 fixedCoin
	, p.coin2 lagCoin
	, pp.*
--into finish
from possible_event p
	join lateral(
		select
			ll.*
		from lagNum l
			join lateral( 
				select
					l.lag
					, corr(ma_7d, lag) cor
				from (
					select 
						row_number() over(order by t1.get_date desc) date_rank
						, t1.coin_name
						, t2.coin_name
						, lag(t1.ma_7d, l.lag) over(order by 1)
						, t2.ma_7d 
					from coin_price_100 t1, coin_price_100 t2
					where t1.coin_name = p.coin1 and t2.coin_name = p.coin2 and t1.date_rank = t2.date_rank 
				) as v 
				where v.date_rank <= 100
			) ll on true order by abs(cor) desc limit 1
	) pp on true
	
select * from finish;
	
	
-------
with coin_list as (
select 
	row_number() over(partition by coin_name order by get_date desc) date_rank
	, coin_name
	, get_date
	, price_at_close
	, ma_7d
	, count(*) over(partition by coin_name)
from coin_price_histories_v2
where date_rank <= 100
), unique_coin as( 
	select
		distinct(coin_name)
	from coin_list
	where coin_list.cc = 100
), possible_event as(
	select
		c1.coin_name coin1
		, c2.coin_name coin2
	from unique_coin c1 cross join unique_coin c2
	where c1.coin_name != c2.coin_name
),lagNum as(
	select generate_series(1,97) lag
)
select
	p.coin1
	, p.coin2
	, tt.*
from possible_event p
	join lateral(
		select  
			*
		from (
			select
				pp.*
			from lagNum l
				join lateral( 
					select
						l.lag
						, corr(ma_7d, lag) cor
					from (
						select 
							row_number() over(order by t1.get_date desc) date_rank
							, t1.coin_name
							, t2.coin_name
							, t1.ma_7d
							, lag(t2.ma_7d, l.lag) over(order by 1)
						from coin_list t1, coin_list t2
						where t1.coin_name = p.coin1 and t2.coin_name = p.coin2 and t1.date_rank = t2.date_rank 
						group by t1.get_date, t1.coin_name, t2.coin_name, t1.ma_7d, t2.ma_7d
					) as v
					where v.date_rank <= 100
				) pp on true
		) as m order by abs(cor) desc limit 1
	) tt on true




select 
	pp.* 
from possible_event p
	join lateral(
		select
			p.coin1
			, p.coin2
			, corr(t1.price_at_close, t2.price_at_close)
		from coin_list t1, coin_list t2
		where t1.coin_name = p.coin1 and t2.coin_name = p.coin2 and t1.date_rank = t2.date_rank
	) pp on true;



------
with coin_list as (
select 
	row_number() over(partition by coin_name order by get_date desc) date_rank
	, coin_name
	, get_date
	, price_at_close
	, ma_7d
	, count(*) over(partition by coin_name) cc
from coin_price_histories_v2
where date_rank <= 100
), unique_coin as( 
	select
		distinct(coin_name)
	from coin_list
	where coin_list.cc = 100
), possible_event as(
	select
		row_number() over(order by 1) idx
		, c1.coin_name coin1
		, c2.coin_name coin2
	from unique_coin c1 cross join unique_coin c2
	where c1.coin_name != c2.coin_name
), lagNum as(
	select generate_series(1,30) lag
)
select
	pp.*
from lagNum l
	join lateral( 
		select
			l.lag
			, corr(ma_7d, lag) cor
		from (
			select 
				row_number() over(order by t1.get_date desc) idx
				, t1.coin_name
				, t2.coin_name
				, t1.ma_7d
				, lag(t2.ma_7d, l.lag) over(order by 1)
			from coin_list t1, coin_list t2
			where t1.coin_name = 'aeon' and t2.coin_name = 'ark' and t1.date_rank = t2.date_rank 
			group by t1.get_date, t1.coin_name, t2.coin_name, t1.ma_7d, t2.ma_7d
		) as v
		where v.idx <= 100
	) pp on true order by abs(cor) desc limit 1
	
	
------
with unique_coin as( 
	select
		distinct(coin_name)
	from coin_price_100
), possible_event as(
	select
		row_number() over(order by 1) idx
		, c1.coin_name coin1
		, c2.coin_name coin2
	from unique_coin c1 cross join unique_coin c2
	where c1.coin_name != c2.coin_name
), lagNum as(
	select generate_series(1,30) lag
), test as( 
	select
		p.coin1
		, p.coin2
		, c1.get_date
		, c1.ma_7d
		, c2.ma_7d
	from possible_event p
	inner join coin_price_100 c1 on p.coin1 = c1.coin_name
	inner join coin_price_100 c2 on p.coin2 = c2.coin_name
	where c1.get_date = c2.get_date
	order by 1,2,3 desc
) select * from test

select
	pp.*
from lagNum l
	join lateral( 
		select
			l.lag
			, corr(ma_7d, lag) cor
		from (
			select 
				row_number() over(order by t1.get_date desc) idx
				, t1.coin_name
				, t2.coin_name
				, t1.ma_7d
				, lag(t2.ma_7d, l.lag) over(order by 1)
			from coin_price_100 t1, coin_price_100 t2
			where t1.coin_name = 'aeon' and t2.coin_name = 'ark' and t1.date_rank = t2.date_rank 
			group by t1.get_date, t1.coin_name, t2.coin_name, t1.ma_7d, t2.ma_7d
		) as v
		where v.idx <= 100
	) pp on true order by abs(cor) desc limit 1

select * from coin_price_histories_with_ma7;




