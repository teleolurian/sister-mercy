require 'open-uri'
require 'time'
require 'csv'
class SisterMercy::Commands::CoronaGlobal < SisterMercy::Command
  def self.name; :corona; end

  def description
    'Per Country Coronavirus'
  end

  def execute(event, location, *args)
    begin
      if location.length == 2 #state
        response = open "http://coronavirusapi.com/getTimeSeries/#{location.upcase}"
        content = CSV.parse(resource.read, headers: true)
        content.map do |row|
          time = Time.at(row['seconds_since_Epoch'].to_i).strftime "%Y %b %e"
          +"#{time} - #{row['tested']} tested / #{row['positive']} sick / #{row['deaths']} dead"
        end
      else
        response = get_json_from "https://api/covid19api.com/country/#{location.downcase}/status/confirmed/live"
      response.sort {|x,y| x.Date <=> y.Date}[-7..-1].each do |x|
        date = Time.parse(x.Date).strftime "%Y %b %e"
        +"#{date} - #{x.Cases} cases"
      end
    end
  rescue
    +"Can't parse location #{location}. Please use a country name or state abbreviation."
  end
end
