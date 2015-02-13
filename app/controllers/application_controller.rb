class ApplicationController < ActionController::Base
  protect_from_forgery

private
	def get_cart
		Cart.find(session[:cart_id])
		rescue ActiveRecord::RecordNotFound
			cart = Cart.create
			session[:cart_id] = cart.id
			cart
	end
	def get_now
		Time.now.to_i
	end
end
