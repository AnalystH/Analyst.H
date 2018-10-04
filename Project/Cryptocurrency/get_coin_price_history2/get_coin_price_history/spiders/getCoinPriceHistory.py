import scrapy
from get_coin_price_history.items import GetCoinPriceHistoryItem
from dateutil.parser import parse as dp #for date parsing

"""
shell 에서 
    coin_name(코인명), start_dt(조회시작) , end_dt(조회종료)를 입력하여 csv로 output을 남기도록 함

ex) scrapy crawl coinPriceSpider -a coin_name=ethereum -a start_dt=20170929 -a end_dt=20171010
"""
class CoinSpider(scrapy.Spider):

    name = "coinPriceSpider"

    def __init__(self, coin_name='bitcoin', start_dt='20170927', end_dt='20170928',  *args, **kwargs):
        super(CoinSpider, self).__init__(*args, **kwargs)
        self.coin_name = coin_name
        self.start_urls = ['https://coinmarketcap.com/currencies/{}/historical-data/?start={}&end={}'.format(coin_name, start_dt, end_dt),]


    def parse(self, response):
        item = GetCoinPriceHistoryItem()
        for coin_price in response.xpath('//*[@id="historical-data"]/div/div[3]/table/tbody/tr'):
            item['CoinName'] = self.coin_name
            item['Date'] = dp(coin_price.xpath('td/text()')[0].extract()).strftime('%Y%m%d')
            item['Open'] = coin_price.xpath('td/text()')[1].extract().replace(',', '')
            item['High'] = coin_price.xpath('td/text()')[2].extract().replace(',', '')
            item['Low'] = coin_price.xpath('td/text()')[3].extract().replace(',', '')
            item['Close'] = coin_price.xpath('td/text()')[4].extract().replace(',', '')
            item['Volume'] = coin_price.xpath('td/text()')[5].extract().replace(',', '')
            item['MarketCap'] = coin_price.xpath('td/text()')[6].extract().replace(',', '')

            yield item
            # yield {
            #     'CoinName': self.coin_name,
            #     'Date': dp(coin_price.xpath('td/text()')[0].extract()).strftime('%Y%m%d'),
            #     'Open': coin_price.xpath('td/text()')[1].extract().replace(',', ''),
            #     'High': coin_price.xpath('td/text()')[2].extract().replace(',', ''),
            #     'Low': coin_price.xpath('td/text()')[3].extract().replace(',', ''),
            #     'Close': coin_price.xpath('td/text()')[4].extract().replace(',', ''),
            #     'Volume': coin_price.xpath('td/text()')[5].extract().replace(',', ''),
            #     'Market Cap': coin_price.xpath('td/text()')[6].extract().replace(',', ''),
            # }
