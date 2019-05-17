require "spec_helper"

RSpec.describe SolarEventCalculator, "Test the sunset algorithm" do
  subject(:calculator) { described_class.new(date, BigDecimal("39.9537"), BigDecimal("-75.7850")) }
  let(:date) { Date.parse("2008-11-01") }

  it "returns correct longitude hour" do
    expect(calculator.compute_longitude_hour).to eql(BigDecimal("-5.0523"))
  end

  it "returns correct longitude hour" do
    expect(calculator.compute_longitude_event_hour(false)).to eql(BigDecimal("306.9605"))
  end

  it "returns correct sunset mean anomaly" do
    expect(calculator.compute_sun_mean_anomaly(BigDecimal("306.9605"))).to eql(BigDecimal("299.2513"))
  end

  it "returns correct sunset's sun true longitude" do
    expect(calculator.compute_sun_true_longitude(BigDecimal("299.2513"))).to eql(BigDecimal("220.1966"))
  end

  it "returns correct sunset's right ascension" do
    expect(calculator.compute_right_ascension(BigDecimal("220.1966"))).to eql(BigDecimal("37.7890"))
  end

  it "returns correct sunset's right ascension quadrant" do
    expect(calculator.correct_quadrant_for_right_ascension(BigDecimal("220.1966"))).to eql(BigDecimal("14.5193"))
  end

  it "returns correct sunset sin sun declination" do
    expect(calculator.compute_sin_sun_declination(BigDecimal("220.1966"))).to eql(BigDecimal("-0.2568"))
  end

  it "returns correct sunset cosine sun declination" do
    expect(calculator.compute_cosine_sun_declination(BigDecimal("-0.2541"))).to eql(BigDecimal("0.9672"))
  end

  it "returns correct sunset cosine sun local hour" do
    expect(calculator.compute_cosine_sun_local_hour(BigDecimal("220.1966"), 96)).to eql(BigDecimal("0.0815"))
  end

  it "returns correct sunset local hour angle" do
    expect(calculator.compute_local_hour_angle(BigDecimal("0.0815"), false)).to eql(BigDecimal("5.6883"))
  end

  it "returns correct sunset local mean time" do
    trueLong = BigDecimal("220.1966")
    longHour = BigDecimal("-5.0523")
    localHour = BigDecimal("5.6883")
    t = BigDecimal("306.9605")
    expect(calculator.compute_local_mean_time(trueLong, longHour, t, localHour)).to eql(BigDecimal("22.4675"))
  end

  it "returns correct UTC civil sunset time" do
    expect(calculator.compute_utc_civil_sunset).to eql(DateTime.parse("#{date.strftime}T22:28:00-00:00"))
  end

  it "returns correct UTC official sunset time" do
    expect(calculator.compute_utc_official_sunset).to eql(DateTime.parse("#{date.strftime}T21:59:00-00:00"))
  end

  it "returns correct UTC nautical sunset time" do
    expect(calculator.compute_utc_nautical_sunset).to eql(DateTime.parse("#{date.strftime}T23:00:00-00:00"))
  end

  it "returns correct UTC astronomical sunset time" do
    expect(calculator.compute_utc_astronomical_sunset).to eql(DateTime.parse("#{date.strftime}T23:31:00-00:00"))
  end

  it "returns correct 'America/New_York' offical sunset time" do
    expect(calculator.compute_official_sunset("America/New_York")).to eql(DateTime.parse("#{date.strftime}T17:59:00-04:00"))
  end

  it "returns correct 'America/New_York' civil sunset time" do
    expect(calculator.compute_civil_sunset("America/New_York")).to eql(DateTime.parse("#{date.strftime}T18:28:00-04:00"))
  end

  it "returns correct 'America/New_York' nautical sunset time" do
    expect(calculator.compute_nautical_sunset("America/New_York")).to eql(DateTime.parse("#{date.strftime}T19:00:00-04:00"))
  end

  it "returns correct 'America/New_York' astronomical sunset time" do
    expect(calculator.compute_astronomical_sunset("America/New_York")).to eql(DateTime.parse("#{date.strftime}T19:31:00-04:00"))
  end
  # DateTime.parse("#{date.strftime}T06:32:00-04:00")
end

RSpec.describe SolarEventCalculator, "test the math for areas where the sun doesn't set" do
  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal("64.8378"), BigDecimal("-147.7164"))
    expect(calc.compute_utc_nautical_sunset).to eql(nil)
  end

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal("64.8378"), BigDecimal("-147.7164"))
    expect(calc.compute_utc_nautical_sunset).to eql(nil)
  end
end
