module Util

	# 引数の文字列から「数字以外」を除外した値を返します。
	def trim_chars(str)

		str.gsub(',','')
	end

	# 以下の宣言がないと外部からモジュール関数として使用できない
	module_function :trim_chars
end