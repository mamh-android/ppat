module ApplicationHelper
    def get_cur_user
        session[:username]
    end

    def get_record_info(id)
        PowerRecord.find(id)
    end
end
