require '../lib/solareventcalculator'

describe SolarEventCalculator, "test the math for home" do

  before do
    @date = Date.parse('2008-11-01') #01 November 2008
    @calc = SolarEventCalculator.new(@date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
  end

  it "returns correct longitude hour" do
    @calc.compute_lnghour.should eql(BigDecimal.new("-5.0523"))
  end

  it "returns correct longitude hour" do
    @calc.compute_longitude_hour(true).should eql(BigDecimal.new("306.4605"))
  end

  it "returns correct sunrise mean anomaly" do
    @calc.compute_sun_mean_anomaly(BigDecimal.new("306.4605")).should eql(BigDecimal.new("298.7585"))
  end

  it "returns correct sunrise's sun true longitude" do
    @calc.compute_sun_true_longitude(BigDecimal.new("298.7585")).should eql(BigDecimal.new("219.6960"))
  end

  it "returns correct sunrise's right ascension" do
    @calc.compute_right_ascension(BigDecimal.new("219.6960")).should eql(BigDecimal.new("37.2977"))
  end

  it "returns correct sunrise's right ascension quadrant" do
    @calc.put_ra_in_correct_quadrant(BigDecimal.new("219.6960")).should eql(BigDecimal.new("14.4865"))
  end

  it "returns correct sunrise sin sun declination" do
    @calc.compute_sin_sun_declination(BigDecimal.new("219.6960")).should eql(BigDecimal.new("-0.2541"))
  end

  it "returns correct sunrise cosine sun declination" do
    @calc.compute_cosine_sun_declination(BigDecimal.new("-0.2541")).should eql(BigDecimal.new("0.9672"))
  end

  it "returns correct sunrise cosine sun local hour" do
    @calc.compute_cosine_sun_local_hour(BigDecimal.new("219.6960"), 96).should eql(BigDecimal.new("0.0791"))
  end

  it "returns correct sunrise local hour angle" do
    @calc.compute_local_hour_angle(BigDecimal.new("0.0791"), true).should eql(BigDecimal.new("18.3025"))
  end

  it "returns correct sunrise local mean time" do
    trueLong = BigDecimal.new("219.6960")
    longHour = BigDecimal.new("-5.0523")
    localHour = BigDecimal.new("18.3025")
    t = BigDecimal.new("306.4605")
    @calc.compute_local_mean_time(trueLong, longHour, t, localHour).should eql(BigDecimal.new("11.0818"))
  end

  it "returns correct UTC civil sunrise time" do
    @calc.compute_utc_civil_sunrise.should eql(DateTime.parse("#{@date.strftime}T11:04:00-00:00"))
  end

  it "returns correct UTC official sunrise time" do
    @calc.compute_utc_official_sunrise.should eql(DateTime.parse("#{@date.strftime}T11:33:00-00:00"))
  end

  it "returns correct UTC nautical sunrise time" do
    @calc.compute_utc_nautical_sunrise.should eql(DateTime.parse("#{@date.strftime}T10:32:00-00:00"))
  end

  it "returns correct UTC astronomical sunrise time" do
    @calc.compute_utc_astronomical_sunrise.should eql(DateTime.parse("#{@date.strftime}T10:01:00-00:00"))
  end

  it "returns correct 'America/New_York' official sunrise time" do
    @calc.compute_official_sunrise('America/New_York').should eql(DateTime.parse("#{@date.strftime}T07:33:00-04:00"))
  end

  it "returns correct 'America/New_York' civil sunrise time" do
    @calc.compute_civil_sunrise('America/New_York').should eql(DateTime.parse("#{@date.strftime}T07:04:00-04:00"))
  end

  it "returns correct 'America/New_York' nautical sunrise time" do
    @calc.compute_nautical_sunrise('America/New_York').should eql(DateTime.parse("#{@date.strftime}T06:32:00-04:00"))
  end

  it "returns correct 'America/New_York' astronomical sunrise time" do
    @calc.compute_astronomical_sunrise('America/New_York').should eql(DateTime.parse("#{@date.strftime}T06:01:00-04:00"))
  end
end

describe SolarEventCalculator, "test the math for areas where there could be no rise/set" do

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    calc.compute_utc_nautical_sunrise.should eql(nil)
  end

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    calc.compute_utc_nautical_sunrise.should eql(nil)
  end
end
