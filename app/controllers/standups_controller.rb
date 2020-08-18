class StandupsController < ApplicationController
  before_action :set_standup, only: [:show, :edit, :update, :destroy]
  before_action :verify_changeable, only: [:edit, :update, :destroy]

  # GET /standups
  def index
    @standups = Standup.filter_results(params[:search])
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data Standup.to_csv(@standups), filename: "standups-#{Date.today}.csv" }
    end
  end

  # GET /standups/new
  def new
    load_standups
    @standup = current_user.standups.build if @standups.for_today.blank?
  end

  # GET /standups/1
  def edit
    load_standups
    @standup = @standups.for_today.last
  end

  # POST /standups
  def create
    @standup = current_user.standups.build(standup_params)
    respond_to do |format|
      if @standup.save
        format.html { redirect_to new_standup_path, notice: 'Worklog was added successfully.' }
      else
        load_standups
        format.html { render :new}
      end
    end
  end

  # PATCH/PUT /standups/1
  def update
    respond_to do |format|
      if @standup.update(standup_params)
        format.html { redirect_to new_standup_path, notice: 'Worklog was updated successfully' }
      else
        load_standups
        format.html { render :edit }
      end
    end
  end

  # DELETE /standups/1
  def destroy
    @standup.destroy
    respond_to do |format|
      format.html { redirect_to new_standup_path, notice: 'Worklog was deleted successfully' }
    end
  end

  private
    def load_standups
      @standups = current_user.standups.exclude_new_records
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_standup
      @standup = current_user.standups.find_by(id: params[:id])
    end

    def verify_changeable
      raise "Past worklogs cannot be modified" unless @standup && @standup.is_changeable?(current_user.id)
    end

    # Only allow a list of trusted parameters through.
    def standup_params
      params.require(:standup).permit(:user_id, :worklog)
    end
end
