require 'sunrise'

describe SolarEventCalculator, "#sunrise time for 01 Nov 2009 @home" do
  it "returns correct time" do
    date = Date.parse('2009-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_utc_sunrise.should.to_s == "Sun Nov 01 11:05:00 UTC 2009"
  end
end