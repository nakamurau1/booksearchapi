require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require './amazon_api.rb'
require 'json'
# require 'pry'

# ruby app.rb -o localhostで実行

get '/' do
  "Hello!"
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

# http://localhost:4567/api/v1/search/author/YUI
get '/api/v1/search/author/:author' do |author|

	books = BookSearcher::search_by_author(author)

	books_array = []

	books.each do |book|
		next if book == nil

		books_array.push(book.to_hash)
	end

	hash = {}
	hash["BookInfos"] = books_array

	return hash.to_json

end

# フリーワード検索
# http://localhost:4567/api/v1/search/freeword/YUI
get '/api/v1/search/freeword/:word' do |word|

	books = BookSearcher::search_by_freeword(word)

	books_array = []

	books.each do |book|
		next if book == nil

		books_array.push(book.to_hash)
	end

	hash = {}
	hash["BookInfos"] = books_array

	return hash.to_json
end

# ISBN検索
# http://localhost:4567/api/v1/search/isbn/4860521153
get '/api/v1/search/isbn/:isbn' do |isbn|

	books, stocks = BookSearcher::search_by_isbn(isbn)

	books_array = []
	books.each do |book|
		next if book == nil

		books_array.push(book.to_hash)
	end

  stocks_array = []
  stocks.each do |stock|
    next if stock == nil

    stocks_array.push(stock.to_hash)
  end

	hash = {}
	hash["BookInfos"] = books_array
  hash["Stocks"] = stocks_array

	return hash.to_json
end

error do |e|
  status 500
  body e.message
end
