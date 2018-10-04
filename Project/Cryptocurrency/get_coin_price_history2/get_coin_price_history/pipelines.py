# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

import csv
import itertools

def write_to_csv(item):
    writer = csv.writer(open('CoinPriceHistory.csv', 'a'), lineterminator='\n')
    writer.writerow([
        item['CoinName'],
        item['Date'],
        item['Open'],
        item['High'],
        item['Low'],
        item['Close'],
        item['Volume'],
        item['MarketCap'],
             ])


class GetCoinPriceHistoryPipeline(object):
    def process_item(self, item, spider):
        write_to_csv(item)
        return item

    # def process_item(self, item, spider):
    #     return item

