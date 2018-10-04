
/*
 * ma7기준 업다운, 전체상승/폭락 제외 데이터 구하기(데이터 갱신 필요)
 * */
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
--	where coin_name =  'bitcoin'-- for zeppelin'${coin_name=bitcoin,bitcoin|ethereum|ark|blocknet|dash|neo|lisk}'
),
updown as ( 
select
	COIN_NAME
	, get_date
	, max_get_date::date - min_get_date::date as date_gap
	, MA_7D
	, LAG(MA_7D) OVER(partition by COIN_NAME order by GET_DATE)
	, case when MA_7D >  COALESCE( LAG(MA_7D) OVER(partition by COIN_NAME order by GET_DATE), 0) then 1 else 0 end UPDOWN
from 
	PRICE_HISTORY
where 
	/*수집 기간이 365일 이상 경과하고 최근 1년치 데이터만 가져오도록   */
	max_get_date::date - min_get_date::date  > 365
  	and get_date::date >  max_get_date::date - 365
)
select 
	updown.* 
	, count(*) over(partition by get_date) coin_count_by_get_date	     -- 날짜 기준에 코인이 몇개가 존재하는지 카운트 
	, sum(updown) over(partition by get_date) updown_count   -- 날짜 기준에 전날 대비 가격이 up 된 카운트 (down은 coin_count_by_get_date 에서 빼주면 됨)
	, case 
		when   sum(updown) over(partition by get_date)  * 1.0 / count(*) over(partition by get_date) >= 0.8 
			or sum(updown) over(partition by get_date)  * 1.0 / count(*) over(partition by get_date) <= 0.2 then 1 
		else 0 end coupled
	into price_2
from updown
order by get_date
;


/*
 * 위에서 만든 테이블(price_2 : ma_7 기준 updown + coupled 여부 ) 에서 coupled = 0인 것들만 가져오도록 함( 대부분 폭락/상승은 제외 처리 )  
 * */
select 
	* 
from ( 
	select
		p.*
		, count(*) over(partition by get_date) count_by_Date
	from
		price_2 p 
	where 
		coupled = 0
) as v 
where v.count_by_Date = 73 -- 데이터 일부 누락으로 추정되어 건수를 맞추기 위한 임시 방편 처리(실제로는 데이터 갱신 필요) 
;