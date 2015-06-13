require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require './amazon_api.rb'
require 'json'

# ruby app.rb -o localhostで実行

get '/' do
  "Hello Taniguchi."
end

# isbnで書籍情報とその在庫情報を取得します。
# http://localhost:4567/api/v1/search/isbn/9784101181066
get '/api/v1/search/isbn/:isbn' do |isbn|
	# 9784101181066
	books, stocks = BookSearcher::search_by_isbn(isbn)

	hash = {}

	hash["BookInfo"] = books.first.to_hash

	stocks_array = []

	stocks.each do |stock|
		next if stock == nil 

		stocks_array.push(stock.to_hash)
	end

	hash["Stocks"] = stocks_array

	return hash.to_json
end

# http://localhost:4567/api/v1/search/title/YUI
get '/api/v1/search/title/:title' do |title|

	books = BookSearcher::search_by_title(title)

	books_array = []

	books.each do |book|
		next if book == nil

		books_array.push(book.to_hash)
	end

	hash = {}
	hash["BookInfos"] = books_array

	return hash.to_json
end

