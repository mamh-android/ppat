module ApplicationHelper
  def get_cur_user
    session[:username]
  end

  def get_cart
    Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      cart = Cart.create
      session[:cart_id] = cart.id
      cart
  end
end
