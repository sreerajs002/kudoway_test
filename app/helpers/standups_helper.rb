module StandupsHelper

  def display_links(object, user)
    if object.is_changeable?(user.id)
      link_to("Edit", edit_standup_path(object), class: 'm-r-sm') +
      link_to("Delete", object, method: :delete, data: { confirm: 'Are you sure?' }, class: 'm-r-sm')
    end
  end

  def formatted_date(date)
    date.try(:strftime, "%e-%m-%Y")
  end

  def users_select_options
    User.pluck(:name, :id)
  end
end
