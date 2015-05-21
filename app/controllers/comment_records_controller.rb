class CommentRecordsController < ApplicationController
  before_action :set_comment_record, only: [:show, :edit, :update, :destroy]

  # GET /comment_records
  def index
    @comment_records = CommentRecord.all
  end

  # GET /comment_records/1
  def show
  end

  # GET /comment_records/new
  def new
    @comment_record = CommentRecord.new
  end

  # GET /comment_records/1/edit
  def edit
  end

  # POST /comment_records
  def create
    @comment_record = CommentRecord.new(comment_record_params)

    if @comment_record.save
      redirect_to "/home/index"
    end
  end

  # PATCH/PUT /comment_records/1
  def update
    if @comment_record.update(comment_record_params)
      redirect_to @comment_record, notice: 'Comment record was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /comment_records/1
  def destroy
    @comment_record.destroy
    redirect_to comment_records_url, notice: 'Comment record was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment_record
      @comment_record = CommentRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_record_params
      params.require(:comment_record).permit(:user_id, :text, :image_path, :file_path, :platform, :branch, :device, :uploadtime)
    end
end
