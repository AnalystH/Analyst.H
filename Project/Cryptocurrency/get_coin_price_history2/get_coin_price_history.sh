#!/bin/bash

#코인별 최근 연동시점 정보를 가지고 있는 디렉토리(코인목록 포함)
coin_last_date_path=./data/coin_last_date
coin_price_raw_file=CoinPriceHistory.csv

#실행시점 기준으로 어제 날짜까지 데이터를 가져올 수 있음
end_dt=$(date -v -1d '+%Y%m%d')

source activate tensorflow
for coin in `ls $coin_last_date_path`
do
	start_dt=`cat $coin_last_date_path/$coin`
	if [ $end_dt != $start_dt ]
	then
		sleep_time=$(( ( RANDOM % 5 )  + 1 ))
		echo sleep_time : $sleep_time
		sleep $sleep_time
		#echo $coin $end_dt `cat $coin_last_date_path/$coin` 
		echo scrapy crawl coinPriceSpider -a coin_name=$coin -a start_dt=$start_dt -a end_dt=$end_dt
		scrapy crawl coinPriceSpider -a coin_name=$coin -a start_dt=$start_dt -a end_dt=$end_dt
		echo $end_dt > $coin_last_date_path/$coin
	fi	
done

source deactivate tensorflow

sort -u CoinPriceHistory.csv | grep -v ,- > $coin_price_raw_file.$end_dt

rm -rf $coin_price_raw_file.raw
cp  $coin_price_raw_file.$end_dt  $coin_price_raw_file.raw

#현재 쉘 경로로 변경해 줄 것 : /Users/prokbk/onedrive/study/coin <- 변경
psql -h localhost -d coin -U coin -p 15432  -f /Users/hsw/Desktop/개인파일/스터디/Coin_Project/Python_Code/get_coin_price_history2/script/sql_script/create_coin_price_history.sql


Rscript /Users/hsw/Desktop/개인파일/스터디/Coin_Project/R_Code/Correlation_Analysis.R

