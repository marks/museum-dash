#!/usr/bin/env ruby
require 'soda'

raise 'SocrataAppTokenEnvironmentVariableUnset' if ENV['SOCRATA_APP_TOKEN'].nil?

# Configure the dataset ID and initialize SODA client
dataset_resource_id = "5rw9-2vgh" # URL: https://data.imls.gov/d/5rw9-2vgh
soda_client = SODA::Client.new({
  domain: "data.imls.gov",
  app_token: ENV['SOCRATA_APP_TOKEN']
})


SCHEDULER.every '5m', first_in: 0 do |job|

  # #### COUNT BY MUSUEM TYPE ####
  # Construct SODA query
  count_by_type_response = soda_client.get(dataset_resource_id, {
    "$group" => "museum_type",
    "$select" => "museum_type, COUNT(*) AS n"
  })
  type_map = {
    "ART" => "Art Museums",
    "BOT" => "Arboretums, Botanical Gardens, & Nature Centers",
    "CMU" => "Children's Museums",
    "GMU" => "Uncategorized or General Museums",
    "HSC" => "Historical Societies, Historic Preservation",
    "HST" => "History Museums",
    "NAT" => "Natural History & Natural Science Museums",
    "SCI" => "Science & Technology Museums & Planetariums",
    "ZAW" => "Zoos, Aquariums, & Wildlife Conservation",
  }
  # Formulate list
  count_by_type = {}
  count_by_type_response.each do |item|
    type_humanized = type_map[item.museum_type]
    count_by_type[type_humanized] = {:label => type_humanized, :value => item.n}
  end
  # Send event to dashboard
  send_event('count_by_type', { items: count_by_type.values.sort_by{|x| x[:value].to_i}.reverse })


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


  #### COUNT BY STATE ####
  count_by_state_response = soda_client.get(dataset_resource_id, {
    "$group" => "state",
    "$select" => "state, COUNT(*) AS n"
  })
  count_by_state = {}
  count_by_state_response.each do |item|
    count_by_state[item.state] = {:label => item.state, :value => item.n}
  end
  count_by_state_in_order = count_by_state.values.sort_by{|x| x[:value].to_i}.reverse
  # Stitch together top/bottom resuts
  count_by_state_to_send = count_by_state_in_order[0,8]+[{:label => "..."}]+count_by_state_in_order[-8,8]
  # Send event to dashboard
  send_event('count_by_state', { items: count_by_state_to_send })

end