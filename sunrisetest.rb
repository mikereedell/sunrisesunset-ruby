require 'sunrise'

describe SolarEventCalculator, "sunrise longitude hour for 01 Nov 2008 @home" do
  it "returns correct longitude hour" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_rise_longitude_hour.should eql(BigDecimal.new("306.4605"))
  end
end

describe SolarEventCalculator, "sunset longitude hour for 01 Nov 2008 @home" do
  it "returns correct longitude hour" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_set_longitude_hour.should eql(BigDecimal.new("306.9605"))
  end
end

describe SolarEventCalculator, "sunrise mean anomaly" do
  it "returns correct sunrise mean anomaly" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_sun_mean_anomaly(BigDecimal.new("306.4605")).should eql(BigDecimal.new("298.7585"))
  end
end

describe SolarEventCalculator, "sunrise sun true longitude" do
  it "returns correct sunrise's sun true longitude" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_sun_true_longitude(BigDecimal.new("298.7585")).should eql(BigDecimal.new("219.6960"))
  end
end

describe SolarEventCalculator, "sunrise right ascension" do
  it "returns correct sunrise's right ascension" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_right_ascension(BigDecimal.new("219.6960")).should eql(BigDecimal.new("37.2977"))
  end
end

describe SolarEventCalculator, "sunrise right ascension in correct quadrant" do
  it "returns correct sunrise's right ascension quadrant" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.put_ra_in_correct_quadrant(BigDecimal.new("219.6960")).should eql(BigDecimal.new("14.4865"))
  end
end

describe SolarEventCalculator, "sunrise sin sun declination" do
  it "returns correct sunrise sin sun declination" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_sin_sun_declination(BigDecimal.new("219.6960")).should eql(BigDecimal.new("-0.2541"))
  end
end

describe SolarEventCalculator, "sunrise cosine sun declination" do
  it "returns correct sunrise cosine sun declination" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_cosine_sun_declination(BigDecimal.new("-0.2541")).should eql(BigDecimal.new("0.9672"))
  end
end

describe SolarEventCalculator, "sunrise cosine sun local hour" do
  it "returns correct sunrise cosine sun local hour" do
    date = Date.parse('2008-11-01')
    calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
    calc.compute_cosine_sun_local_hour(BigDecimal.new("219.6960"), 96).should eql(BigDecimal.new("0.0791"))
  end
end


# describe SolarEventCalculator, "sunrise time for 01 Nov 2009 @home" do
#   it "returns correct time" do
#     date = Date.parse('2008-11-01')
#     calc = SolarEventCalculator.new(date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
#     calc.compute_utc_sunrise(96).should eql("Sun Nov 01 11:05:00 UTC 2009")
#   end
# end