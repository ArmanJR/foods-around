require 'nokogiri'
require 'open-uri'
class CrwController < ApplicationController
	def index
		links = []
		@foods = []
		url = 'https://www.reyhoon.com/restaurants?location=%D9%85%D8%AC%D8%A7%D9%87%D8%AF%20%DA%A9%D8%A8%DB%8C%D8%B1&area=%D8%AC%D9%86%D8%AA%20%D8%A2%D8%A8%D8%A7%D8%AF%20%D8%AC%D9%86%D9%88%D8%A8%DB%8C&city=%D8%AA%D9%87%D8%B1%D8%A7%D9%86'
		doc = Nokogiri::HTML(open(url))
		doc.css('.branch-card').first(8).each do |item|
		link = item.at_css('a').attr('href')
		link = 'https://www.reyhoon.com' + link
		links << link
		end
		@li = links

		links.each do |url|
		doc = Nokogiri::HTML(open(url))
			hash = {:title => "", :price => 0.0, :image => "", :category => "", :rest_title => "", :rest_link => ""}
			hash[:rest_link] = url
			rest_title = doc.at_css('h1').at_css('a').text
			hash[:rest_title] = rest_title
			doc.xpath('//*[@itemtype="http://schema.org/Product"]').each do |food|
			hash = {:title => "", :price => 0.0, :image => "", :category => "", :rest_title => rest_title, :rest_link => url}
			title = food.at_css('h2').text
			hash[:title] = title
			price = food.at_css('p').text
			price.tr!(",","")
			price = price.to_i
			hash[:price] = price
		    if food.css('div').at_css('img').nil?
		    	hash[:image] = "https://www.reyhoon.com/assets/img/food.png"
		    	else
		    		image = food.css('div').at_css('img').attr('src')
		    		hash[:image] = image
		    end
			@foods << hash
			end
		end
		@foods.sort_by! { |h| h[:price] }
	end

end
