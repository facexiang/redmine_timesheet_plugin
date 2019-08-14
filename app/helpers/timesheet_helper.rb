module TimesheetHelper
  include ProjectsHelper

  def add_day_total? time_entries, time_entry_counter
    (time_entry_counter == (time_entries.length - 1)) ||
      (time_entries[time_entry_counter + 1].spent_on != time_entries[time_entry_counter].spent_on)
  end

  def calculate_day_total time_entries, time_entry_counter
    date = time_entries[time_entry_counter].spent_on
    hours_sum = 0
    while (time_entry_counter >= 0) && (time_entries[time_entry_counter].spent_on == date)
      hours_sum += time_entries[time_entry_counter].hours
      time_entry_counter -= 1
    end
    number_with_precision(hours_sum, :precision => @precision)
  end

  def showing_users(users)
    l(:timesheet_showing_users) + users.collect(&:name).join(', ')
  end

  def permalink_to_timesheet(timesheet)
    link_to(l(:timesheet_permalink),
      :controller => 'timesheet',
      :action => 'report',
      :timesheet => timesheet.to_param)
  end

  def link_to_csv_export(timesheet)
    link_to('CSV',
      {
        :controller => 'timesheet',
        :action => 'report',
        :format => 'csv',
        :timesheet => timesheet.to_param
      },
      :method => 'post',
      :class => 'icon icon-timesheet')
  end

  def toggle_arrows(element, js_function)
    js = "#{js_function}('#{element}');"

    return toggle_arrow(element, 'toggle-arrow-closed.gif', js, false) +
        toggle_arrow(element, 'toggle-arrow-open.gif', js, true)
  end

  def toggle_arrow(element, image, js, hide=false)
    style = 'display:none;' if hide
    style ||= ''

    content_tag(:span,
                link_to_function(image_tag(image, :plugin => "redmine_timesheet_plugin"), js),
                :class => "toggle-" + element.to_s,
                :style => style
    )
  end

  def toggle_issue_arrows(issue_id)
    return toggle_arrows(issue_id, 'toggleTimeEntriesIssue')
  end
  
  def toggle_issue_arrows_date(spent_on)
    return toggle_arrows(spent_on, 'toggleTimeEntriesDate')
  end

  def displayed_time_entries_for_issue(time_entries)
    time_entries.collect(&:hours).sum
  end

  def project_options(timesheet)
    available_projects = timesheet.allowed_projects
    selected_projects = timesheet.projects
    selected_projects = available_projects if selected_projects.blank?
    project_tree_options_for_select(available_projects, :selected => selected_projects)
  end

  def activity_options(timesheet, activities)
    options_from_collection_for_select(activities, :id, :name, timesheet.activities)
  end
  
  def group_options(timesheet)
    available_groups = Group.all
    if timesheet.groups.first.class == Group
      selected_groups = timesheet.groups.collect{|g| g.id}
    else
      selected_groups = timesheet.groups
    end
    selected_groups = available_groups.collect{|g| g.id} if selected_groups.blank?
    options_from_collection_for_select(available_groups, :id, :name, :selected =>timesheet.groups)
  end

  def tracker_options(timesheet)
    available_trackers = Tracker.all
    selected_trackers = timesheet.trackers
    selected_trackers = available_trackers.collect{|g| g.id} if selected_trackers.blank?
    options_from_collection_for_select(available_trackers, :id, :name, :selected =>timesheet.trackers)
  end

  def user_options(timesheet)
    available_users = Timesheet.viewable_users.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
    selected_users = timesheet.users

    options_from_collection_for_select(available_users,
      :id,
      :name,
      selected_users)

  end
  
  def options_for_period_select(value)
    options_for_select([[l(:label_all_time), 'all'],
                        [l(:label_today), 'today'],
                        [l(:label_yesterday), 'yesterday'],
                        [l(:label_this_week), 'current_week'],
                        [l(:label_last_week), 'last_week'],
                        [l(:label_last_n_weeks, 2), 'last_2_weeks'],
                        [l(:label_last_n_days, 7), '7_days'],
                        [l(:label_this_month), 'current_month'],
                        [l(:label_last_month), 'last_month'],
                        [l(:label_last_n_days, 30), '30_days'],
                        [l(:label_this_year), 'current_year']],
                        value)
  end

  def user_selected(timesheet)
    Timesheet.viewable_users.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }.select{|u| u.id.in?(timesheet.users)}
  end

  def project_colors(timesheet)
    arr = %w{Black BlanchedAlmond Blue BlueViolet Brown BurlyWood CadetBlue Chartreuse Chocolate Coral CornflowerBlue Cornsilk Crimson Cyan DarkBlue DarkCyan DarkGoldenRod DarkGray DarkGreen DarkKhaki DarkMagenta DarkOliveGreen Darkorange DarkOrchid DarkRed DarkSalmon DarkSeaGreen DarkSlateBlue DarkSlateGray DarkTurquoise DarkViolet DeepPink DeepSkyBlue DimGray DodgerBlue FireBrick}
    hash = {}
    timesheet.projects.each do |pro|
      hash[pro.id] = [ arr.pop, pro.name ]
    end
    hash
  end

  def user_time_pro(timesheet)
    hash = {}
    timesheet.time_entries.each do |project, logs|
      logs[:logs].each do |log|
        time_hash = hash[log.user_id] || {}
        pro_arr = time_hash[log.spent_on.to_s] || []
        pro_arr << log.project_id
        time_hash[log.spent_on.to_s] = pro_arr
        hash[log.user_id] = time_hash
      end
    end
    hash
    #@grand_total = @total.collect{|k,v| v}.inject{|sum,n| sum + n}
  end

  def color_arr(projects)
    arr = %w{SkyBlued DeepSkyBlue LightBlue PowderBlue CadetBlue PaleTurquoise Cyan Aqua DarkTurquoise DarkSlateGray DarkCyan Teal MediumTurquoise LightSeaGreen Turquoise Aquamarine MediumAquamarine MediumSpringGreen SpringGreen MediumSeaGreen SeaGreen LightGreen PaleGreen DarkSeaGreen LimeGreen Lime ForestGreen Green DarkGreen Chartreuse LawnGreen GreenYellow DarkOliveGreen YellowGreen OliveDrab LightGoldenrodYellow Yellow Olive DarkKhaki LemonChiffon PaleGoldenrod Khaki Gold Cornsilk Goldenrod DarkGoldenrod Wheat Moccasin Orange PapayaWhip BlanchedAlmond NavajoWhite AntiqueWhite Tan BurlyWood Bisque DarkOrange Linen Peru PeachPuff SandyBrown Chocolate SaddleBrown Sienna LightSalmon Coral OrangeRed DarkSalmon Tomato MistyRose Salmon LightCoral RosyBrown IndianRed Red Brown FireBrick DarkRed Maroon Gainsboro LightGrey Silver DarkGray Gray DimGray Black LightPink Pink Crimson LavenderBlush PaleVioletRed HotPink DeepPink MediumVioletRed Orchid Thistle Plum Violet Magenta Fuchsia DarkMagenta Purple MediumOrchid DarkViolet DarkOrchid Indigo BlueViolet MediumPurple MediumSlateBlue SlateBlue DarkSlateBlue Lavender Blue MediumBlue MidnightBlue DarkBlue Navy RoyalBlue CornflowerBlue LightSteelBlue LightSlateGray SlateGray DodgerBlue SteelBlue LightSkyBlue}
    hash = {}
    projects.each do |pro|
      hash[pro.id] = [ arr.pop, pro.name ]
    end
    hash
  end

end
