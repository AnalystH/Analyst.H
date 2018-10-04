drop table coin_price_histories ;

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

-- /Users/prokbk/onedrive/study/coin : 자신의 경로로 변경
\copy coin_price_histories from '/Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/CoinPriceHistory.csv.raw' with delimiter ',' csv;



drop table if exists coin_price_histories_with_ma7 ;

select 
	/* drop table coin_price_histories_v2  쿼리 실행 전 테이블 유무 확인 
	 * 기존 테이블에서 window 함수 이용 이동평균, 매물대그룹, 최근x일 최대/최소 가격/날짜 등 출
	 * */ 
	   coin_name
	,  to_date(get_date, 'yyyymmdd') get_date
	,  price_at_close
	, avg(price_at_close) over(partition by coin_name order by get_date desc rows between CURRENT row and 7 FOLLOWING) ma_7d -- moving average 7 days 
	into coin_price_histories_with_ma7
from coin_price_histories
;

-- /Users/prokbk/onedrive/study/coin : 자신의 경로로 변경
\copy coin_price_histories_with_ma7 to '/Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/coin_price_histories_with_ma7.csv.raw' with delimiter ',' csv;
