class TaskDatatable
  delegate :params,  to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: TaskInfo.count,
      iTotalDisplayRecords: task_infos.total_entries,
      aaData: data
    }
  end

private

  def data
    task_infos.map do |task_info|
      [
        task_info.id,
        task_info.task_id,
        task_info.finished_at.to_s,
        task_info.platform,
        task_info.device,
        task_info.branch,
        task_info.purpose,
        task_info.user.name,
        '<span class="icon-refresh"></span>'
      ]
    end
  end

  def task_infos
    @task_infos ||= fetch_task_infos
  end

  def fetch_task_infos
    task_infos = TaskInfo.where(run_type: "ondemand").order("#{sort_column} #{sort_direction}")
    task_infos = task_infos.page(page).per_page(per_page)
    if params[:search]["value"] != ""
      search_str = params[:search]["value"].split(/[\s]/)
      search_str.each do |val|
        task_infos = task_infos.where("id like :search or branch like :search or device like :search or task_id like :search or platform like :search or purpose like :search", search: "%#{val}%")
      end
    end
    task_infos
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    columns = %w[id task_id platform  branch device  purpose submitter]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "asc" ? "asc" : "desc"
  end
end
