class RecordListsController < ApplicationController
  # GET /record_lists
  # GET /record_lists.json
  def index
    @record_lists = RecordList.all
    render :layout=>"empty"
  end

  # GET /record_lists/1
  # GET /record_lists/1.json
  def show
    @record_list = RecordList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @record_list }
    end
  end

  # GET /record_lists/new
  # GET /record_lists/new.json
  def new
    @record_list = RecordList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record_list }
    end
  end

  # GET /record_lists/1/edit
  def edit
    @record_list = RecordList.find(params[:id])
  end

  # POST /record_lists
  # POST /record_lists.json
  def create
    @cart = get_cart
    power_record = PowerRecord.find(params[:power_record_id])
    @record_list = @cart.record_list.build(:power_record => power_record)

    respond_to do |format|
      if @record_list.save
        #format.html { redirect_to @record_list, notice: 'Record list was successfully created.' }
        format.json { render json: @record_list, status: :created, location: @record_list }
      else
        format.html { render action: "new" }
        format.json { render json: @record_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_by_task
    @cart = get_cart
    @scenarios = PowerRecord.where(task_id:  params[:task_id])
    @scenarios.each do |power_record|
      @record_list = @cart.record_list.build(:power_record => power_record)
      @record_list.save
    end
    respond_to do |format|
        format.js
    end
  end

  # PUT /record_lists/1
  # PUT /record_lists/1.json
  def update
    @record_list = RecordList.find(params[:id])

    respond_to do |format|
      if @record_list.update_attributes(params[:record_list])
        format.html { redirect_to @record_list, notice: 'Record list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @record_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /record_lists/1
  # DELETE /record_lists/1.json
  def destroy
    @record_list = RecordList.find(params[:id])
    @record_list.destroy

    respond_to do |format|
      format.html { redirect_to record_lists_url }
      format.json { head :no_content }
    end
  end

  def delete
    @record_list = RecordList.find(params[:id])
    @power_scenario_id = @record_list.power_record.power_scenario_id
    @record_list.destroy
    @cart = get_cart
    respond_to do |format|
      format.js
    end
  end
end
