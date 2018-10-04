CREATE TABLE coin_price_histories (
	coin_name varchar(100) NOT NULL ,
	yyyymmdd varchar(8) NOT NULL ,
	price_at_open	numeric(19,10),
	price_at_high	numeric(19,10),
	price_at_low	numeric(19,10),
	price_at_close	numeric(19,10),
	volume		numeric(19),
	marketcap	numeric(19)
);

CREATE UNIQUE INDEX coin_price_histories_pk ON coin_price_histories(coin_name, yyyymmdd); 



--copy coin_price_histories from '/[성욱씨 경로로 수정 후 사용]/CoinPriceHistory.csv_mod' WITH (FORMAT csv);



select distinct coin_name from coin_price_histories where coin_name like '%eth%';
select coin_name, count(*) from coin_price_histories group by coin_name order by 1;


select
	*
from
	coin_price_histories;