#!/usr/bin/env ruby
require 'soda'

raise 'SocrataAppTokenEnvironmentVariableUnset' if ENV['SOCRATA_APP_TOKEN'].nil?

# Configure the dataset ID and initialize SODA client
dataset_resource_id = "5rw9-2vgh"
soda_client = SODA::Client.new({
  domain: "data.imls.gov",
  app_token: ENV['SOCRATA_APP_TOKEN']
})


SCHEDULER.every '5m', first_in: 0 do |job|


  # #### COUNT BY STATUS ####
  # # Construct SODA query
  # count_by_status_response = soda_client.get(dataset_resource_id, {
  #   "$group" => "ticket_status",
  #   "$select" => "ticket_status, COUNT(ticket_status) AS n"
  # })
  # # Formulate list
  # count_by_status = {}
  # count_by_status_response.each do |item|
  #   count_by_status[item.ticket_status] = {:label => item.ticket_status, :value => item.n}
  # end
  # # Send event to dashboard
  # send_event('count_by_status', { items: count_by_status.values })


  # #### TOTAL TICKETS ####
  total_museums_response = soda_client.get(dataset_resource_id, {
    "$select" => "count(*)"
  })
  total_museums = total_museums_response.first["count"].to_i
  send_event('total_museums', { current:  total_museums})

  # #### TOTAL WITH PHOTO ####
  # total_with_photo_response = soda_client.get(dataset_resource_id, {
  #   "$where" => "image is not null",
  #   "$select" => "count(*)"
  # })
  # total_with_photo = total_with_photo_response.first["count"]
  # send_event('number_with_photo', { current:  total_with_photo})

  # #### PERCENT WITH PHOTO ####
  # percent_with_photo = ((total_with_photo.to_f/total_tickets.to_f)*100).to_i
  # send_event('percent_with_photo', { value:  percent_with_photo})

  # #### COUNT BY ISSUE TYPE ####
  # count_by_issue_type_response = soda_client.get(dataset_resource_id, {
  #   "$group" => "issue_type",
  #   "$select" => "issue_type, COUNT(issue_type) AS n"
  # })
  # count_by_issue_type = {}
  # count_by_issue_type_response.each do |item|
  #   count_by_issue_type[item.issue_type] = {:label => item.issue_type, :value => item.n}
  # end
  # # Send event to dashboard
  # send_event('count_by_issue_type', { items: count_by_issue_type.values.sort_by{|x| x[:value].to_i}.reverse })

end