require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require './amazon_api.rb'
require 'json'

# ruby app.rb -o localhostで実行

get '/' do
  "Hello Taniguchi."
end

get '/api/v1/search/:isbn' do |isbn|
	# 9784101181066
	books, stocks = BookSearcher::search(isbn)

	hash = {}

	hash["BookInfo"] = books.first.to_hash

	stocks_array = []

	stocks.each do |stock|
		stocks_array.push(stock.to_hash)
	end

	hash["Stocks"] = stocks_array

	return hash.to_json
end

=begin
get '/hello/:fname/?:lname?'do |f, l|
	"hello = #{f} #{l}"
end

get %r{/users/([0-9]*)} do |i|
	"user id = #{i}"
end

get '/about2'do
	'about this site page'
end
=end

