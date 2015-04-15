class LogController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def in
        session[:return_to] ||= request.referer
        if request.post?
            username = params[:username]
            password = params[:pwd]
            @result = varify_user_login(username, password)
            if @result == "OK"
                session[:username] = username
                email_addr = username + "@marvell.com"
                if User.where(email_addr: email_addr).last.nil?
                    user = User.new(:email_addr => email_addr, name: username, role: "developer")
                    user.save
                end
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
