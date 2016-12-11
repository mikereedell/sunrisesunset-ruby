require '../lib/solareventcalculator'
gem 'minitest'
require 'minitest/autorun'
require 'minitest/spec/expect'

describe SolarEventCalculator, "Test the sunset algorithm" do

  it "returns correct sunrise/sunset data over a year" do
    Dir.glob("*.txt") do | dataFileName |
    #puts dataFileName

    nameParts = dataFileName.split('#')
    timeZone = nameParts[1].split('.')[0].sub!('-', '/')
    latString = nameParts[0].split('-')[0].sub!('_', '.')
    longString = nameParts[0].split('-')[1].sub!('_', '.')

    latitude = BigDecimal.new(latString.chop)
    longitude = BigDecimal.new(longString.chop)
    if latString.end_with?('S')
      latitude = BigDecimal.new("0") - latitude
    end

    if longString.end_with?('W')
      longitude = BigDecimal.new("0") - longitude
    end

    tz = TZInfo::Timezone.get(timeZone)
    dataFile = File.open(dataFileName, 'r')

    dataFile.readlines.each do |dataLine|
      parts = dataLine.split(',')
      date_string = parts.shift
      date_array = date_string.split('/')
      date = Date.parse(date_array[2] + "-" + date_array[0] + "-" + date_array[1])
      calc = SolarEventCalculator.new(date, BigDecimal.new(latitude), BigDecimal.new(longitude))

      time = parts[0].split(':')
      expectedAstronomicalRise = put_in_timezone(date, time[0], time[1], timeZone)
      #assert_equal(calc.compute_astronomical_sunrise(timeZone), expectedAstronomicalRise) #, "Astronomical Rise")

      time = parts[1].split(':')
      expectedNauticalRise = put_in_timezone(date, time[0], time[1], timeZone)
      #calc.compute_nautical_sunrise(timeZone).should be_close_to(expectedNauticalRise, "Nautical Rise")

      time = parts[2].split(':')
      expectedCivilRise = put_in_timezone(date, time[0], time[1], timeZone)
      #assert_equal(calc.compute_civil_sunrise(timeZone), expectedCivilRise) #, "Civil Rise")

      time = parts[3].split(':')
      expectedOfficialRise = put_in_timezone(date, time[0], time[1], timeZone)
      assert_equal(calc.compute_official_sunrise(timeZone), expectedOfficialRise)#, "Official Rise")

      time = parts[4].split(':')
      expectedOfficialSet = put_in_timezone(date, time[0], time[1], timeZone)
      assert_equal(calc.compute_official_sunset(timeZone), expectedOfficialSet)#, "Official Set")

      time = parts[5].split(':')
      expectedCivilSet = put_in_timezone(date, time[0], time[1], timeZone)
      #calc.compute_civil_sunset(timeZone).should be_close_to(expectedCivilSet, "Civil Set")

      time = parts[6].split(':')
      expectedNauticalSet = put_in_timezone(date, time[0], time[1], timeZone)
      #calc.compute_nautical_sunset(timeZone).should be_close_to(expectedNauticalSet, "Nautical Set")

      time = parts[7].split(':')
      expectedAstronomicalSet = put_in_timezone(date, time[0], time[1], timeZone)
      #calc.compute_astronomical_sunset(timeZone).should be_close_to(expectedAstronomicalSet, "Astronomical Set")
    end
    end
  end
end

def put_in_timezone(date, hours, minutes, timezone)
  if hours.to_i == 99
    return nil
  end
  offset = get_utc_offset(date, timezone)

  timeInZone = DateTime.parse("#{date.strftime}T#{hours}:#{minutes}:00#{offset}")
  timeInZone
end

def get_utc_offset(date, timezone)
  tz = TZInfo::Timezone.get(timezone)
  noonUTC = Time.utc(date.year,date.mon, date.mday, 12, 0)
  offset = ((tz.utc_to_local(noonUTC) - noonUTC) / 60 / 60).to_i
  offset = (offset  > 0) ? "+" + offset.to_s : offset.to_s
end

# Rspec::Matchers.define :be_close_to do |expected, type|
#   match do |actual|
#     if expected != nil && actual != nil
#       (expected - 61) < actual && actual < (expected + 61)
#     else
#       expected == nil && actual == nil
#     end
#   end

#   failure_message_for_should do |actual|
#     " actual #{type} #{actual} is outside +-1 minute of expected  #{type} #{expected}"
#   end

#   failure_message_for_should_not do |actual|

#   end

#   description do
#     " tests whether the actual time is within a minute of the expected time"
#   end
# end