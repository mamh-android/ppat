class LogController < ApplicationController
    def in
        unless request.get?
            session[:return_to] ||= request.referer
            username = params[:user][:name]
            password = params[:pwd]
            @result = varify_user_login(username, password)
            if @result == "OK"
                session[:username] = username
                redirect_to session.delete(:return_to)
            end
        end
    end

    def out
        session[:return_to] ||= request.referer
        session[:username] = nil
        redirect_to session.delete(:return_to)
    end

    def varify_user_login(username, password)
        username = 'marvell\\' + username
        ldap = Net::LDAP.new(
            host: 'sh4-dc02.marvell.com',
            auth: { method: :simple, username: username, password: password }
        )
        if ldap.bind
            "OK"
        end
    end
end
