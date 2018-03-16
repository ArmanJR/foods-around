require 'nokogiri'
require 'open-uri'
class CrwController < ApplicationController
	def index

		# location
		@given_location = params[:id]
		loc_hash = Hash.new
		loc_hash.default = 'https://reyhoon.com/tehran/sazman-barnameh'
		locations = []
		url = "https://www.reyhoon.com/tehran"
		loc_doc = Nokogiri::HTML(open(url))
		loc_doc.css('li').each do |li|
			unless li.at_css('a').nil?
				title = li.at_css('a').text
				link = 'https://reyhoon.com' + li.at_css('a').attr('href')
				loc_hash[title] = link
			end
		end
		location_link = loc_hash[@given_location]

		# restaurants links
		links = []
		url = location_link
		doc = Nokogiri::HTML(open(url))
		doc.css('.branch-card').first(8).each do |item|
		link = item.at_css('a').attr('href')
		link = 'https://www.reyhoon.com' + link
		links << link
		end
		@li = links

		# foods
		@foods = []
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
		@paginatable_array = Kaminari.paginate_array(@foods).page(params[:page]).per(21)
	end

	def location_picker
		@hash = Hash.new
		url = "https://www.reyhoon.com/tehran"
		doc = Nokogiri::HTML(open(url))
		doc.css('li').each do |li|
			unless li.at_css('a').nil?
				title = li.at_css('a').text
				link = '/tehran/' + title
				@hash[title] = link
			end
		end
		
		# bootstrap styling + removing header and footer links
		@sliced_array = @hash.each_slice(4).to_a
		@sliced_array = @sliced_array[1..@sliced_array.length-4]
	end

end
