require 'amazon/ecs'
require 'open-uri'
require 'nokogiri'
require 'uri'
require 'kconv'
require 'json'

# todo: ActiveRecordを使うようにする
class Book
	attr_accessor :title
	attr_accessor :isbn
	attr_accessor :price
	attr_accessor :image_url
	attr_accessor :author
	attr_accessor :publisher
	attr_accessor :asin
	attr_accessor :jan

	def print()
		puts "title : #{@title}"
		puts "isbn  : #{@isbn}"
		puts "price : #{@price}"
		puts "image : #{@image_url}"
		puts "author: #{@author}"
		puts "publisher: #{@publisher}"
		puts "asin  : #{@asin}"
		puts "jan   : #{@jan}"
		puts "------------------------------"		
	end

	def to_hash()
		hash = {"title" => @title,
		        "isbn" => @isbn,
		        "price" => @price,
		        "image" => @image_url,
		        "author" => @author,
		        "publisher" => @publisher,
		        "asin" => @asin,
		        "jan" => @jan}

		return hash
	end
end

class StockInfo
	attr_accessor :lowest_used_price
	attr_accessor :lowest_new_price
	attr_accessor :selling_agent
	attr_accessor :url
	attr_accessor :isbn
	attr_accessor :jan

	def print
		puts "lowest_new_price : #{@lowest_new_price}"
		puts "lowest_used_price: #{@lowest_used_price}"
		puts "selling_agent    : #{@selling_agent}"
		puts "url              : #{@url}"
		puts "isbn             : #{@isbn}"
		puts "jan              : #{@jan}"
		puts "------------------------------"		
	end

	def to_hash
		hash = {"isbn" => @isbn,
			    "jan" => @jan,
			    "url" => @url,
			    "selling_agent" => @selling_agent,
			    "lowest_used_price" => @lowest_used_price,
			    "lowest_new_price" => @lowest_new_price}

		return hash
	end
end

class BookSearcher

	def self.search(isbn)

		Amazon::Ecs.options = {
			:associate_tag => 'yuiweb-22',
			:AWS_access_key_id => 'AKIAJWBU6APZDQHRFEOQ',
			:AWS_secret_key => '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'
		}

		#商品検索
		res = Amazon::Ecs.item_search(
			isbn,
			{:search_index => 'Books',
			 :response_group => 'Medium',
			 :country=>'jp'}
			)

		books = []
		stock_infos = []

		res.items.each do |item|

			new_book = Book.new

			new_book.title = item.get("ItemAttributes/Title")
			new_book.price = item.get("ItemAttributes/ListPrice/Amount")
			new_book.image_url = item.get("MediumImage/URL")
			new_book.isbn = item.get("ItemAttributes/ISBN")
			new_book.author = item.get("ItemAttributes/Author")
			new_book.publisher = item.get("ItemAttributes/Publisher")
			new_book.asin = item.get("ASIN")
			new_book.jan = item.get("ItemAttributes/EAN")

			books << new_book

			# Amazon
			amazon_stock = StockInfo.new
			amazon_stock.lowest_new_price = item.get("OfferSummary/LowestNewPrice/Amount")
			amazon_stock.lowest_used_price = item.get("OfferSummary/LowestUsedPrice/Amount")
			amazon_stock.selling_agent = "amazon.co.jp"
			amazon_stock.isbn = new_book.isbn
			amazon_stock.jan = new_book.jan
			amazon_stock.url = item.get("DetailPageURL")

			stock_infos << amazon_stock

			# Bookoff
			bookoff_stock = get_bookoff_price(new_book)
			stock_infos << bookoff_stock
		end

		return books, stock_infos
	end

	:private

		# Bookoffから価格情報を取得します
		def self.get_bookoff_price(book)

			bookoff_url = "http://www.bookoffonline.co.jp/feed/search,st=u,q=#{book.jan}"

			doc = Nokogiri::XML(open(bookoff_url).read)

			items = doc.xpath("//rss/channel/item")
			item = items.first

			description = item.xpath("description").text

			lowest_new_price_re = "定価：￥(\\d+)"
			lowest_new_price_md = /#{lowest_new_price_re}/.match(description)

			lowest_used_price_re = "中古価格：￥(\\d+)"
			lowest_used_price_md = /#{lowest_used_price_re}/.match(description)

			url = item.xpath("link").text

			bookoff_stock = StockInfo.new

			if !lowest_new_price_md.nil?
				bookoff_stock.lowest_new_price = lowest_new_price_md[1]
				bookoff_stock.lowest_used_price = lowest_used_price_md[1]
			end

			bookoff_stock.selling_agent = "bookoffonline"
			bookoff_stock.isbn = book.isbn
			bookoff_stock.jan = book.jan
			bookoff_stock.url = url

			# bookoff_stock.print

			return bookoff_stock
		end
end 

