module ApplicationHelper
    def get_cur_user
        session[:username]
    end
end
