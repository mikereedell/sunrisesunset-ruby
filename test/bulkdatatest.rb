require '../lib/solareventcalculator'

describe SolarEventCalculator, "Test the sunset algorithm" do

  it "returns correct sunrise/sunset data over a year" do
    dataFile = File.open("39_9937N-75_7850W#America-New_York.txt", 'r')
    tz = TZInfo::Timezone.get("America/New_York")

    dataFile.readlines.each do |dataLine|
      parts = dataLine.split(',')
      date = Date.parse(parts.shift)
      calc = SolarEventCalculator.new(date, BigDecimal.new("39.9937"), BigDecimal.new("-75.7850"))

      time = parts[0].split(':')
      expectedAstronomicalRise = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_astronomical_sunrise("America/New_York").should be_close_to(expectedAstronomicalRise)

      time = parts[1].split(':')
      expectedNauticalRise = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_nautical_sunrise("America/New_York").should be_close_to(expectedNauticalRise)

      time = parts[2].split(':')
      expectedCivilRise = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_civil_sunrise("America/New_York").should be_close_to(expectedCivilRise.getlocal)

      time = parts[3].split(':')
      expectedOfficialRise = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_official_sunrise("America/New_York").should be_close_to(expectedOfficialRise.getlocal)

      time = parts[4].split(':')
      expectedOfficialSet = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_official_sunset("America/New_York").should be_close_to(expectedOfficialSet)

      time = parts[5].split(':')
      expectedCivilSet = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_civil_sunset("America/New_York").should be_close_to(expectedCivilSet)

      time = parts[6].split(':')
      expectedNauticalSet = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_nautical_sunset("America/New_York").should be_close_to(expectedNauticalSet)

      time = parts[7].split(':')
      expectedAstronomicalSet = Time.local(date.year, date.mon, date.mday, time[0], time[1])
      calc.compute_astronomical_sunset("America/New_York").should be_close_to(expectedAstronomicalSet)
    end
  end
end

Spec::Matchers.define :be_close_to do |expected|
  match do |actual|
    (expected - 61) < actual && actual < (expected + 61)
  end

  failure_message_for_should do |actual|
    " actual #{actual} is outside +-1 minute of expected #{expected}"
  end

  failure_message_for_should_not do |actual|

  end

  description do
    " tests whether the actual time is within a minute of the expected time"
  end
end