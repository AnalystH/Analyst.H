with d as  ( 
	select 
		/* drop table coin_price_histories_v2  쿼리 실행 전 테이블 유무 확인 
		 * 기존 테이블에서 window 함수 이용 이동평균, 매물대그룹, 최근x일 최대/최소 가격/날짜 등 출
		 * */ 
		row_number() over(partition by coin_name order by get_date desc  ) date_rank 
		,  coin_name
		,  to_date(get_date, 'yyyymmdd') get_date
		,  price_at_close
		,  volume
		,  max(to_date(get_date, 'yyyymmdd')) over(partition by coin_name ) max_get_date
		,  min(to_date(get_date, 'yyyymmdd')) over(partition by coin_name ) min_get_date
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
) 
select 
	coin_name,
	get_date,
	ma_7d
	into coin_100
from d
where 
	max_get_date - min_get_date >= 100 
	and date_rank <= 100;
	
create unique index coin_100_uk01 on coin_100(coin_name, get_date);
create unique index coin_100_uk02 on coin_100(get_date , coin_name );


with coin_name_list as (
	select 
		distinct coin_name 
	from 
		coin_100 
) ,
coin_pair as (
	select 
		a.coin_name fixed_coin_name
		, b.coin_name lag_coin_name
	from 
		coin_name_list a join coin_name_list b on a.coin_name <> b.coin_name
) 
select 
	distinct 
	 cp.fixed_coin_name
--	,cp.lag_coin_name
--	,v.abs_price_corr
--	,v.price_corr
--	,v.date_gap
	,max(abs_price_corr) over (partition by cp.fixed_coin_name) 
	,nth_value(lag_coin_name ,  1) over(partition by cp.fixed_coin_name order by abs_price_corr desc ) max_corr_coin_name
	,nth_value(price_corr ,  1) over(partition by cp.fixed_coin_name order by abs_price_corr desc ) max_price_corr
	,nth_value(date_gap ,  1) over(partition by cp.fixed_coin_name order by abs_price_corr desc ) max_price_corr_date_gap
from coin_pair  cp
	join lateral ( 
		select 
			a.coin_name a_coin_name,
			b.coin_name b_coin_name,
			corr(a.ma_7d, b.ma_7d) price_corr,
			abs( corr(a.ma_7d, b.ma_7d) ) abs_price_corr,
			a.get_date - b.get_date date_gap
		from coin_100 a 
			join coin_100 b on ( a.coin_name <> b.coin_name and b.get_date between a.get_date - 30 and a.get_date - 1)
		where 
			1=1
			and a.coin_name = cp.fixed_coin_name
			and b.coin_name = cp.lag_coin_name
		group by 
			a.coin_name, b.coin_name, (a.get_date - b.get_date)
	) as v on true 
limit 100
;




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
		,  	to_date(get_date ,'yyyymmdd') get_date
		,  price_at_close
--		,  (select b.price_at_close from coin_price_histories b where b.coin_name = 'bitcoin' and b.get_date = h.get_date ) bit_price
		,  (select h.price_at_close / b.price_at_close from coin_price_histories b where b.coin_name = 'bitcoin' and b.get_date = h.get_date ) bit_price
		,  volume
		,  max(get_date) over(partition by coin_name ) max_get_date
		,  min(get_date) over(partition by coin_name ) min_get_date
		,  max(price_at_close) over(partition by coin_name ) max_price_at_close
		,  min(price_at_close) over(partition by coin_name ) min_price_at_close
		,  (max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) * 1.0   --  
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 45 price_gap -- 40 == 40 weeks
		,  trunc( price_at_close * 1.0 / ((max(price_at_close) over(partition by coin_name ) - min(price_at_close) over(partition by coin_name )) 
				/ ( (max(get_date) over(partition by coin_name ))::int -  (min(get_date) over(partition by coin_name ))::int ) / 45 ) ) price_group_1  -- price_at_close, 매물대 그룹 
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
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 31 FOLLOWING) ma_31d -- moving average 7 days 
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 93 FOLLOWING) ma_93d
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 365 FOLLOWING) ma_365d
	from coin_price_histories h
	where coin_name = 'neo'
)
select 
	*
from price_history

	