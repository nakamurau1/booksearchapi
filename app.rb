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
# タイトルで検索できる
# http://localhost:4567/api/v1/search/freeword/YUI
# ISBNでも検索可能
# http://localhost:4567/api/v1/search/freeword/4101181063
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

error do
  "何やら様子がおかしいようです"
end
