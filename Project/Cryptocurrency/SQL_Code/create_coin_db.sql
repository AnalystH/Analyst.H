-- admin user 
create user 		coin ;
create database 	coin ;
alter user coin with encrypted password 'coin';
grant all on database coin to coin ;


grant all privileges on database postgres to coin;

-- coin user 
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
select 
	pp.*
	, price_at_close
from coin_name_list  c 
	join lateral (
		select 	
			coin_name
			, price_at_open
		from coin_price_histories t
		where t.coin_name = c.coin_name
		group by 
			coin_name, price_at_open
	) pp on true 
order by pp.coin_name desc 
;


select * from coin_price_histories;



explain
select * from coin_price_histories;







