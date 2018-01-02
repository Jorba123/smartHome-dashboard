require 'net/http'
require 'json'
require_relative('variable.rb')

SERVER_API = URI.parse("http://192.168.178.26:3000")

# create HTTP
def create_http
  http = Net::HTTP.new(SERVER_API.host, SERVER_API.port)
  http.use_ssl = false
  return http
end

# create HTTP request for given path
def create_request(path)
  request = Net::HTTP::Get.new(SERVER_API.path + path)
  return request
end

def get_calendar_stats(http)
	request = create_request("/api/calendar/events/today/count")
  	response = http.request(request)
 	data = JSON.parse(response.body)
 	return data.count
 end

SCHEDULER.every '5m', :first_in => 0 do |job|
	http = create_http
	$current_number_of_events_today = get_calendar_stats(http)
	send_event('calendarEventsTotal', { current: $current_number_of_events_today, last: $last_number_of_events_today })
end