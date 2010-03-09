require '../lib/solareventcalculator'

describe SolarEventCalculator, "Test the sunset algorithm" do

  before do
    @date = Date.parse('2008-11-01') #01 November 2008
    @calc = SolarEventCalculator.new(@date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
  end

  it "returns correct longitude hour" do
    @calc.compute_lnghour.should eql(BigDecimal.new("-5.0523"))
  end

  it "returns correct longitude hour" do
    @calc.compute_longitude_hour(false).should eql(BigDecimal.new("306.9605"))
  end

  it "returns correct sunset mean anomaly" do
    @calc.compute_sun_mean_anomaly(BigDecimal.new("306.9605")).should eql(BigDecimal.new("299.2513"))
  end

  it "returns correct sunset's sun true longitude" do
    @calc.compute_sun_true_longitude(BigDecimal.new("299.2513")).should eql(BigDecimal.new("220.1966"))
  end

  it "returns correct sunset's right ascension" do
    @calc.compute_right_ascension(BigDecimal.new("220.1966")).should eql(BigDecimal.new("37.7890"))
  end

  it "returns correct sunset's right ascension quadrant" do
    @calc.put_ra_in_correct_quadrant(BigDecimal.new("220.1966")).should eql(BigDecimal.new("14.5193"))
  end

  it "returns correct sunset sin sun declination" do
    @calc.compute_sin_sun_declination(BigDecimal.new("220.1966")).should eql(BigDecimal.new("-0.2568"))
  end

  it "returns correct sunset cosine sun declination" do
    @calc.compute_cosine_sun_declination(BigDecimal.new("-0.2541")).should eql(BigDecimal.new("0.9672"))
  end

  it "returns correct sunset cosine sun local hour" do
    @calc.compute_cosine_sun_local_hour(BigDecimal.new("220.1966"), 96).should eql(BigDecimal.new("0.0815"))
  end

  it "returns correct sunset local hour angle" do
    @calc.compute_local_hour_angle(BigDecimal.new("0.0815"), false).should eql(BigDecimal.new("5.6883"))
  end

  it "returns correct sunset local mean time" do
    trueLong = BigDecimal.new("220.1966")
    longHour = BigDecimal.new("-5.0523")
    localHour = BigDecimal.new("5.6883")
    t = BigDecimal.new("306.9605")
    @calc.compute_local_mean_time(trueLong, longHour, t, localHour).should eql(BigDecimal.new("22.4675"))
  end

  it "returns correct civil sunset time" do
    @calc.compute_utc_civil_sunset.should eql(Time.gm(@date.year, @date.mon, @date.mday, 22, 28))
  end

  it "returns correct official sunset time" do
    @calc.compute_utc_official_sunset.should eql(Time.gm(@date.year, @date.mon, @date.mday, 21, 59))
  end

  it "returns correct nautical sunset time" do
    @calc.compute_utc_nautical_sunset.should eql(Time.gm(@date.year, @date.mon, @date.mday, 23, 0))
  end

  it "returns correct astronomical sunset time" do
    @calc.compute_utc_astronomical_sunset.should eql(Time.gm(@date.year, @date.mon, @date.mday, 23, 31))
  end
end

describe SolarEventCalculator, "test the math for areas where the sun doesn't set" do

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    calc.compute_utc_nautical_sunset.should eql(nil)
  end

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    calc.compute_utc_nautical_sunset.should eql(nil)
  end
end
