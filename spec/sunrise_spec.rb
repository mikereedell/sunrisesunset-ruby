require "spec_helper"

RSpec.describe SolarEventCalculator, "test the math for home" do
  subject(:calculator) { described_class.new(date, BigDecimal("39.9537"), BigDecimal("-75.7850")) }
  let(:date) { Date.parse("2008-11-01") }

  it "returns correct longitude hour" do
    expect(calculator.compute_lnghour).to eql(BigDecimal("-5.0523"))
  end

  it "returns correct longitude hour" do
    expect(calculator.compute_longitude_hour(true)).to eql(BigDecimal("306.4605"))
  end

  it "returns correct sunrise mean anomaly" do
    expect(calculator.compute_sun_mean_anomaly(BigDecimal("306.4605"))).to eql(BigDecimal("298.7585"))
  end

  it "returns correct sunrise's sun true longitude" do
    expect(calculator.compute_sun_true_longitude(BigDecimal("298.7585"))).to eql(BigDecimal("219.6960"))
  end

  it "returns correct sunrise's right ascension" do
    expect(calculator.compute_right_ascension(BigDecimal("219.6960"))).to eql(BigDecimal("37.2977"))
  end

  it "returns correct sunrise's right ascension quadrant" do
    expect(calculator.put_ra_in_correct_quadrant(BigDecimal("219.6960"))).to eql(BigDecimal("14.4865"))
  end

  it "returns correct sunrise sin sun declination" do
    expect(calculator.compute_sin_sun_declination(BigDecimal("219.6960"))).to eql(BigDecimal("-0.2541"))
  end

  it "returns correct sunrise cosine sun declination" do
    expect(calculator.compute_cosine_sun_declination(BigDecimal("-0.2541"))).to eql(BigDecimal("0.9672"))
  end

  it "returns correct sunrise cosine sun local hour" do
    expect(calculator.compute_cosine_sun_local_hour(BigDecimal("219.6960"), 96)).to eql(BigDecimal("0.0791"))
  end

  it "returns correct sunrise local hour angle" do
    expect(calculator.compute_local_hour_angle(BigDecimal("0.0791"), true)).to eql(BigDecimal("18.3025"))
  end

  it "returns correct sunrise local mean time" do
    trueLong = BigDecimal("219.6960")
    longHour = BigDecimal("-5.0523")
    localHour = BigDecimal("18.3025")
    t = BigDecimal("306.4605")
    expect(calculator.compute_local_mean_time(trueLong, longHour, t, localHour)).to eql(BigDecimal("11.0818"))
  end

  it "returns correct UTC civil sunrise time" do
    expect(calculator.compute_utc_civil_sunrise).to eql(DateTime.parse("#{date.strftime}T11:04:00-00:00"))
  end

  it "returns correct UTC official sunrise time" do
    expect(calculator.compute_utc_official_sunrise).to eql(DateTime.parse("#{date.strftime}T11:33:00-00:00"))
  end

  it "returns correct UTC nautical sunrise time" do
    expect(calculator.compute_utc_nautical_sunrise).to eql(DateTime.parse("#{date.strftime}T10:32:00-00:00"))
  end

  it "returns correct UTC astronomical sunrise time" do
    expect(calculator.compute_utc_astronomical_sunrise).to eql(DateTime.parse("#{date.strftime}T10:01:00-00:00"))
  end

  it "returns correct 'America/New_York' official sunrise time" do
    expect(calculator.compute_official_sunrise('America/New_York')).to eql(DateTime.parse("#{date.strftime}T07:33:00-04:00"))
  end

  it "returns correct 'America/New_York' civil sunrise time" do
    expect(calculator.compute_civil_sunrise('America/New_York')).to eql(DateTime.parse("#{date.strftime}T07:04:00-04:00"))
  end

  it "returns correct 'America/New_York' nautical sunrise time" do
    expect(calculator.compute_nautical_sunrise('America/New_York')).to eql(DateTime.parse("#{date.strftime}T06:32:00-04:00"))
  end

  it "returns correct 'America/New_York' astronomical sunrise time" do
    expect(calculator.compute_astronomical_sunrise('America/New_York')).to eql(DateTime.parse("#{date.strftime}T06:01:00-04:00"))
  end
end

RSpec.describe SolarEventCalculator, "test the math for areas where there could be no rise/set" do

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal("64.8378"), BigDecimal("-147.7164"))
    expect(calc.compute_utc_nautical_sunrise).to eql(nil)
  end

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal("64.8378"), BigDecimal("-147.7164"))
    expect(calc.compute_utc_nautical_sunrise).to eql(nil)
  end
end
