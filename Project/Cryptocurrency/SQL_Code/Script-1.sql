with cph as ( 
	select 
		coin_name
		, to_date(get_date, 'yyyymmdd') as get_date 
		, price_at_close
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 5 PRECEDING and CURRENT row) fma_5
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 10 PRECEDING and CURRENT row) fma_10
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 20 PRECEDING and CURRENT row) fma_20
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 60 PRECEDING and CURRENT row) fma_60
--		, volume
--		, max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 5 FOLLOWING) max5
--		, min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 5 FOLLOWING) min5
--		, max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 10 FOLLOWING) max10
--		, min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 10 FOLLOWING) min10
--		, max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 20 FOLLOWING) max20
--		, min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 20 FOLLOWING) min20
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 5 FOLLOWING) ma_5
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 10 FOLLOWING) ma_10
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 20 FOLLOWING) ma_20
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 60 FOLLOWING) ma_60
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 120 FOLLOWING) ma_120
--		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 366 FOLLOWING) ma_366
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 5 FOLLOWING) 	ma_5_gap
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 10 FOLLOWING) 	ma_10_gap
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 20 FOLLOWING) 	ma_20_gap
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 60 FOLLOWING) 	ma_60_gap
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 120 FOLLOWING) 	ma_120_gap
		, price_at_close - avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between CURRENT row and 366 FOLLOWING) 	ma_366_gap
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 5 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 5 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 5 FOLLOWING) + 0.0000001)  stoch_k_5
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 10 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 10 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 10 FOLLOWING) + 0.0000001)  stoch_k_10
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 20 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 20 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 20 FOLLOWING) + 0.0000001)  stoch_k_20
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 40 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 40 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 40 FOLLOWING) + 0.0000001)  stoch_k_40
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 60 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 60 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 60 FOLLOWING) + 0.0000001)  stoch_k_60
		, ( price_at_close - (min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 120 FOLLOWING)) ) 
		  / ( max(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 120 FOLLOWING) 
		      - min(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd')  desc rows between CURRENT row and 120 FOLLOWING) + 0.0000001)  stoch_k_120
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 5 PRECEDING and CURRENT row) - price_at_close rma_5_diff
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 10 PRECEDING and CURRENT row)  - price_at_close rma_10_diff
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 15 PRECEDING and CURRENT row)  - price_at_close rma_15_diff
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 20 PRECEDING and CURRENT row)  - price_at_close rma_20_diff
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 60 PRECEDING and CURRENT row)  - price_at_close rma_60_diff
		, avg(price_at_close) over(partition by coin_name order by to_date(get_date, 'yyyymmdd') desc rows between 120 PRECEDING and CURRENT row) - price_at_close rma_120_diff
	from 
		coin_price_histories ch 
	where 
		ch.coin_name = 'bitcoin'
	order by 1,2 desc
)
, t as ( 
	select 
		get_date 
		, coin_name
		, (( rma_5_diff + rma_10_diff + rma_15_diff ) / 3 ) / price_at_close sig 
		, price_at_close
		, ma_5_gap
		, ma_10_gap
		, ma_20_gap
		, ma_60_gap
		, ma_120_gap
		, ma_366_gap
		, (price_at_close - ma_5_gap   ) / price_at_close ma_5_gap_pct
		, (price_at_close - ma_10_gap  ) / price_at_close ma_10_gap_pct
		, (price_at_close - ma_20_gap  ) / price_at_close ma_20_gap_pct
		, (price_at_close - ma_60_gap  ) / price_at_close ma_60_gap_pct
		, (price_at_close - ma_120_gap ) / price_at_close ma_120_gap_pct
		, (price_at_close - ma_366_gap ) / price_at_close ma_366_gap_pct
		, avg(stoch_k_5) over(partition by coin_name order by get_date desc rows between CURRENT row and 3 FOLLOWING) stoch_k_5
		, avg(stoch_k_10) over(partition by coin_name order by get_date desc rows between CURRENT row and 6 FOLLOWING) stoch_k_10
		, avg(stoch_k_20) over(partition by coin_name order by get_date desc rows between CURRENT row and 12 FOLLOWING) stoch_k_20
		, avg(stoch_k_40) over(partition by coin_name order by get_date desc rows between CURRENT row and 24 FOLLOWING) stoch_k_40
		, avg(stoch_k_60) over(partition by coin_name order by get_date desc rows between CURRENT row and 48 FOLLOWING) stoch_k_60
		, avg(stoch_k_120) over(partition by coin_name order by get_date desc rows between CURRENT row and 96 FOLLOWING) stoch_k_120
		, rma_5_diff
		, rma_10_diff
		, rma_15_diff
		, rma_20_diff
	--	, (( rma_5_diff + rma_10_diff + rma_15_diff ) / 3 ) / price_at_close
	--	, rma_60_diff
	--	, rma_120_diff
	from 
		cph
	where 
		1=1
)
select 
	get_date
	, sig /* 실제 상승여부 확인. 종가와 미래의 5일 평균, 10일 평균, 15일 평균과 비교하여 결정(기대 수익률에 가까움) .어떤 수치(cutoff)를 buy 신호로 결정할지는 아직 미정 */
	, price_at_close
	/* ma_N_gap : ma_N과 price_at_close의 차이 (이평선과 얼마나 가격이 떨어져 있는가) */
--	, ma_5_gap
--	, ma_10_gap
--	, ma_20_gap
--	, ma_60_gap
--	, ma_120_gap
--	, ma_366_gap
	, ma_5_gap_pct
	, ma_10_gap_pct
	, ma_20_gap_pct
	, ma_60_gap_pct
	, ma_120_gap_pct
	, ma_366_gap_pct
	/* stoch_k_N : 스토캐스틱 N 
	 * stoch_k_N_diff1 : 스토캐스틱 N 의 하루전의 값 - 스토캐스틱 N 의 이틀 전 값 
	 * stoch_k_N_diff2 : 스토캐스틱 N 의 이틀 전 값 - 스토캐스틱 N 의 삼일 전 값 
	 * stoch_k_N_diff3 : 스토캐스틱 N 의 삼일 전 값  - 스토캐스틱 N 의 사일 전 값 
	 * */
	, stoch_k_5
	, stoch_k_5 
		- nth_value(stoch_k_5, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_5_diff1
	, nth_value(stoch_k_5, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_5, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_5_diff2
	, nth_value(stoch_k_5, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_5, 4 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_5_diff3
	, stoch_k_10 
	, stoch_k_10 
		- nth_value(stoch_k_10, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_10_diff1
	, nth_value(stoch_k_10, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_10, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_10_diff2
	, nth_value(stoch_k_10, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_10, 4 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_10_diff3
	, stoch_k_20 
	, stoch_k_20 
		- nth_value(stoch_k_20, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_20_diff1
	, nth_value(stoch_k_20, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_20, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_20_diff2
	, nth_value(stoch_k_20, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_20, 4 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_20_diff3
	, stoch_k_60 
	, stoch_k_60 
		- nth_value(stoch_k_60, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_60_diff1
	, nth_value(stoch_k_60, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_60, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_60_diff2
	, nth_value(stoch_k_60, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_60, 4 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_60_diff3
	, stoch_k_120 
	, stoch_k_120 
		- nth_value(stoch_k_120, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_120_diff1
	, nth_value(stoch_k_120, 2 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_120, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_120_diff2
	, nth_value(stoch_k_120, 3 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) 
	  	- nth_value(stoch_k_120, 4 ) over(partition by coin_name order by get_date desc rows between CURRENT row and 4 FOLLOWING) stoch_k_120_diff3
--into stochastic_info
from 
	t 
;

select * from coin_price_histories;
truncate table coin_price_histories;
copy coin_price_histories from '/Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/CoinPriceHistory.csv.raw' with (FORMAT csv);
drop table stochastic_info;

select * from stochastic_info;

copy stochastic_info to '/Users/hsw/Desktop/개인파일/스터디/Coin_Project/data/stochastic_info.csv' with (FORMAT csv, header);

--Add CommentCollapse 
