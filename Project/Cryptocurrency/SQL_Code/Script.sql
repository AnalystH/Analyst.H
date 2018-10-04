CREATE EXTENSION tablefunc;

CREATE TABLE ct(id SERIAL, rowid TEXT, attribute TEXT, value TEXT);
INSERT INTO ct(rowid, attribute, value) VALUES('test1','att1','val1');
INSERT INTO ct(rowid, attribute, value) VALUES('test1','att2','val2');
INSERT INTO ct(rowid, attribute, value) VALUES('test1','att3','val3');
INSERT INTO ct(rowid, attribute, value) VALUES('test1','att4','val4');
INSERT INTO ct(rowid, attribute, value) VALUES('test2','att1','val5');
INSERT INTO ct(rowid, attribute, value) VALUES('test2','att2','val6');
INSERT INTO ct(rowid, attribute, value) VALUES('test2','att3','val7');
INSERT INTO ct(rowid, attribute, value) VALUES('test2','att4','val8');

select * from ct;
SELECT *
FROM crosstab(
  'select rowid, attribute, value
   from ct
   where attribute = ''att2'' or attribute = ''att3''
   order by 1,2')
AS ct(row_name text, category_1 text, category_2 text, category_3 text);

select rowid, attribute, value
   from ct
   where attribute = 'att2' or attribute = 'att3'
   order by 1,2;



select *
from crosstab(
	'select coin_name,price_at_close from coin_price_histories where coin_name = ''aeon'' and get_date > ''20171101'' order by 1,2'
)as kk(row_name text, category_1 text, category_2 text);

select coin_name,price_at_close from coin_price_histories where coin_name = 'aeon' and get_date > '20171101' order by 1,2;
select * from test;


copy allData from '/Users/hsw/Desktop/데이터진흥원/04. Project/bigdata project/data/handling data/merge_stock_ver2.csv' with(FORMAT csv);






