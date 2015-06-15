
str = "<li>中古価格：￥5,349</li>"

lowest_new_price_re = "中古価格：￥([\\d|,]+)"
# lowest_new_price_re = "中古価格：￥(\\d+)"
lowest_new_price_md = /#{lowest_new_price_re}/.match(str)

puts lowest_new_price_md[0]