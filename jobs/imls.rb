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

  # museums per state - top 5 / low 5
  # breakdown by type
  # number with EIN; percent with EIN

  # #### TOTAL MUSEUMS ####
  total_museums_response = soda_client.get(dataset_resource_id, {
    "$select" => "count(*)"
  })
  total_museums = total_museums_response.first["count"].to_i
  send_event('total_museums', { current:  total_museums})

  #### TOTAL NONPROFIT ####
  total_nonprofit_response = soda_client.get(dataset_resource_id, {
    "$where" => "ein is not null",
    "$select" => "count(*)"
  })
  total_nonprofit = total_nonprofit_response.first["count"]
  send_event('total_nonprofit', { current:  total_nonprofit})

  # #### PERCENT NONPROFIT ####
  percent_nonprofit = ((total_nonprofit.to_f/total_museums.to_f)*100).to_i
  send_event('percent_nonprofit', { value:  percent_nonprofit})


  #### COUNT BY ISSUE TYPE ####
  count_by_state_response = soda_client.get(dataset_resource_id, {
    "$group" => "state",
    "$select" => "state, COUNT(*) AS n"
  })
  count_by_state = {}
  count_by_state_response.each do |item|
    count_by_state[item.state] = {:label => item.state, :value => item.n}
  end
  count_by_state_in_order = count_by_state.values.sort_by{|x| x[:value].to_i}.reverse
  count_by_state_to_send = count_by_state_in_order[0,7]+[{:label => "..."}]+count_by_state_in_order[-7,7]
  # Send event to dashboard
  send_event('count_by_state', { items: count_by_state_to_send })
end