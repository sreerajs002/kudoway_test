class Standup < ApplicationRecord

  #requires
  require 'exportable'
  extend Exportable

  # scopes
  default_scope { order('created_at DESC') }
  scope :exclude_new_records, -> {where.not(id: nil)}
  scope :for_today, -> {where("created_at > '#{Time.zone.now.beginning_of_day.utc}'")}
  scope :for_yesterday, -> {where(created_at: [Time.zone.now.prev_day.beginning_of_day.utc .. Time.zone.now.prev_day.end_of_day.utc])}

  # associations
  belongs_to :user

  # delegations
  delegate :name, to: :user

  # validations
  validates_presence_of :worklog

  # csv exportable columns definition
  EXPORTABLE_COLUMNS = ['created_at', 'name', 'worklog']

  def is_changeable?(requester_id)
    (Standup.for_today.exists? id) && (user_id == requester_id)
  end

  def self.filter_results(search_params)
    return all if search_params.blank?
    query = []
    query << "created_at > '#{search_params[:from_date].to_time.in_time_zone.beginning_of_day.utc}'" unless search_params[:from_date].blank?
    query << "created_at < '#{search_params[:to_date].to_time.in_time_zone.end_of_day.utc}'" unless search_params[:to_date].blank?
    query << "user_id = '#{search_params[:user_id]}'" unless search_params[:user_id].blank?
    query << "worklog LIKE '%#{search_params[:worklog]}%'" unless search_params[:worklog].blank?
    where(query.join(' AND '))
  end

  def self.set_absentees_worklog
    user_ids = Standup.for_yesterday.pluck(:user_id)
    User.where.not(id: user_ids).each do |user|
      user.standups.create(worklog: "Absent", created_at: Time.zone.now.prev_day)
    end
  end
end
