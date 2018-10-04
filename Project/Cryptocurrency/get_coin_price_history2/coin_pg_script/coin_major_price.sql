
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
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d -- moving average 7 days 
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 52 FOLLOWING) ma_52d
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 365 FOLLOWING) ma_356d
	from coin_price_histories
	where coin_name =  'bitcoin'-- for zeppelin'${coin_name=bitcoin,bitcoin|ethereum|ark|blocknet|dash|neo|lisk}'
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
	,l.major_price_1
	,l.major_price_2
	,l.major_price_3
	,l.major_price_4
	,l.major_price_5
	,l.major_price_6
from 
	major_price_list l 
	join price_history h  on l.coin_name = h.coin_name
where
    get_date >= '2017-01-01' -- for zeppelin'${get_Date=2017-01-01}'
order by 1
;



/* for zeppelin

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
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d -- moving average 7 days 
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 52 FOLLOWING) ma_52d
		, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 365 FOLLOWING) ma_356d
	from coin_price_histories
	where coin_name = '${coin_name=bitcoin,bitcoin|ethereum|ark|blocknet|dash|neo|lisk}'
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
		select -- 매물대 상위 그룹 15개 
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
	,l.major_price_1
	,l.major_price_2
	,l.major_price_3
	,l.major_price_4
	,l.major_price_5
	,l.major_price_6
from 
	major_price_list l 
	join price_history h  on l.coin_name = h.coin_name
where
    get_date >= '${get_Date=2017-01-01}'
order by 1
;
*/