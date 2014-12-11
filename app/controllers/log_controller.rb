class LogController < ApplicationController
    def in
        unless request.get?
            username = params[:user][:name]
            session[:username] = username
            session[:return_to] ||= request.referer
            redirect_to session.delete(:return_to)
        end
    end
    def out
        session[:return_to] ||= request.referer
        session[:username] = nil
        redirect_to session.delete(:return_to)
    end
end
