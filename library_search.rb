require 'open-uri'
require 'nokogiri'
require 'uri'
require 'kconv'

# 図書館の貸出状況
class LibraryStock
	attr_accessor :system_id
	attr_accessor :status

	def to_hash()
		hash = {"system_id" => system_id,
		        "status" => status}

		return hash
	end

	def print
		puts "system_id   : #{system_id}"
		puts "status      : #{status}"
		puts "--------------------------------"
	end
end

# 図書館
class Library
	attr_accessor :system_id
	attr_accessor :system_name
	attr_accessor :libkey
	attr_accessor :libid
	attr_accessor :short
	attr_accessor :formal
	attr_accessor :url_pc
	attr_accessor :address
	attr_accessor :pref
	attr_accessor :city
	attr_accessor :post
	attr_accessor :tel
	attr_accessor :geocode
	attr_accessor :category
	attr_accessor :image

	def to_hash()
		hash = {"system_id" => system_id,
		        "system_name" => system_name,
		        "libkey" => libkey,
		        "libid" => libid,
		        "short" => short,
		        "formal" => formal,
		        "url_pc" => url_pc,
		        "address" => address,
		        "pref" => pref,
		        "city" => city,
		        "post" => post,
		        "tel" => tel,
		        "geocode" => geocode,
		        "category" => category,
		        "image" => image}
		        
		return hash
	end

	def print()
		puts "system_id   : #{system_id}"
		puts "system_name : #{system_name}"
		puts "geocode     : #{geocode}"
		puts "--------------------------------"
	end
end

class LibrarySearch

	# カーリルのアプリキー
	APP_KEY = "7e353ce6afe5c44d1b599a4bee5bec0c"

	# 引数
	# 	isbn
	# 	geocode => ユーザの現在位置
	def search_stocks(isbn,geocode)

		near_libraries = self.search_near_libraries(geocode)

		library_stocks = self.search_stocks_by(isbn,near_libraries)

		return near_libraries, library_stocks
	end

	:private

		# 近くの図書館を検索します
		def search_near_libraries(geocode)

			libraries = []

			begin
				
				api_url = "http://api.calil.jp/library?appkey=#{APP_KEY}&geocode=#{geocode}&format=xml"

				doc = Nokogiri::XML(open(api_url).read)

				nodes = doc.xpath("//Libraries/Library")

				nodes.each do |node|
					
					new_library = Library.new()

					new_library.system_id = node.xpath("systemid").text
					new_library.system_name = node.xpath("systemname").text
					new_library.libkey = node.xpath("libkey").text
					new_library.libid = node.xpath("libid").text
					new_library.short = node.xpath("short").text
					new_library.formal = node.xpath("formal").text
					new_library.url_pc = node.xpath("url_pc").text
					new_library.address = node.xpath("address").text
					new_library.pref = node.xpath("pref").text
					new_library.city = node.xpath("city").text
					new_library.post = node.xpath("post").text
					new_library.tel = node.xpath("tel").text
					new_library.geocode = node.xpath("geocode").text
					new_library.category = node.xpath("category").text
					new_library.image = node.xpath("image").text

					new_library.print

					libraries << new_library
				end

			rescue => ex

				puts "近辺の図書館情報のXML解析時にエラーが発生しました。"
			end

			return libraries
		end

		# 図書館の在庫状況を調べます
		def search_stocks_by(isbn, libraries)

			stocks = []

			begin

				system_ids = libraries.map{|library| library.system_id}.join(",")
				
				api_url = "http://api.calil.jp/check?appkey=#{APP_KEY}&isbn=#{isbn}&systemid=#{system_ids}&format=xml"

				puts api_url

				doc = Nokogiri::XML(open(api_url).read)

				puts doc

				nodes = doc.xpath("//books/book/system")

				nodes.each do |node|
					
					new_stock = LibraryStock.new()

					new_stock.system_id = node.attr("systemid")
					new_stock.status = node.xpath("status").text

					new_stock.print

					stocks << new_stock
				end

			rescue => ex

				puts "図書館の蔵書情報検索時にエラーが発生しました"
			end

			return stocks
		end
end








