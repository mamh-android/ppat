class CompareController < ApplicationController
	def index
		@cart = get_cart
		render :layout=>"ppat"
	end
end