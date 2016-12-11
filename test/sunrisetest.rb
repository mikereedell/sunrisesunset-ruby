#!/usr/bin/env/ruby

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solareventcalculator'
gem 'minitest'
require 'minitest/autorun'

#
class TestByLocation < MiniTest::Test
  def setup
    @date = Date.parse('2008-11-01') # 01 November 2008
    @calc = SolarEventCalculator.new(
      @date,
      BigDecimal.new('39.9537'),
      BigDecimal.new('-75.7850')
    )
  end

  def test_lng_hour
    assert_equal(
      BigDecimal.new('-5.0523'),
      @calc.compute_lnghour
    )
    assert_equal(-5.0523, @calc.compute_lnghour)
  end

  def test_longitude_hour
    assert_equal(
      BigDecimal.new('306.4605'),
      @calc.compute_longitude_hour(true)
    )
    assert_equal(
      306.4605,
      @calc.compute_longitude_hour(true)
    )
  end

  def test_mean_anomaly
    assert_equal(
      BigDecimal.new('298.7585'),
      @calc.compute_sun_mean_anomaly(
        BigDecimal.new('306.4605')
      )
    )
    assert_equal(
      298.7585,
      @calc.compute_sun_mean_anomaly(306.4605)
    )
  end

  def test_true_longitude
    assert_equal(
      BigDecimal.new('219.6960'),
      @calc.compute_sun_true_longitude(
        BigDecimal.new('298.7585')
      )
    )
    assert_equal(
      219.6960,
      @calc.compute_sun_true_longitude(298.7585)
    )
  end

  def test_right_ascension
    assert_equal(
      BigDecimal.new('37.2977'),
      @calc.compute_right_ascension(
        BigDecimal.new('219.6960')
      )
    )
    assert_equal(
      37.2977,
      @calc.compute_right_ascension(219.6960)
    )
  end

  def test_right_ascension_quadrant
    assert_equal(
      BigDecimal.new('14.4865'),
      @calc.put_ra_in_correct_quadrant(
        BigDecimal.new('219.6960')
      )
    )
    assert_equal(
      14.4865,
      @calc.put_ra_in_correct_quadrant(219.6960)
    )
  end

  def test_sine_declination
    assert_equal(
      BigDecimal.new('-0.2541'),
      @calc.compute_sine_sun_declination(
        BigDecimal.new('219.6960')
      )
    )
    assert_equal(
      -0.2541,
      @calc.compute_sine_sun_declination(219.6960)
    )
  end

  def test_cosine_declination
    assert_equal(
      0.9672,
      @calc.compute_cosine_sun_declination(
        BigDecimal.new('-0.2541')
      )
    )
    assert_equal(
      0.9672E0,
      @calc.compute_cosine_sun_declination(-0.2541)
    )
  end

  def test_cosine_local_hour
    assert_equal(
      BigDecimal.new('0.0791'),
      @calc.compute_cosine_sun_local_hour(
        BigDecimal.new('219.6960'), 9
      )
    )
    assert_equal(
      0.0791,
      @calc.compute_cosine_sun_local_hour(219.6960, 96)
    )
  end

  def test_local_hour_angle
    assert_equal(
      BigDecimal.new('18.3025'),
      @calc.compute_local_hour_angle(
        BigDecimal.new('0.0791'), true
      )
    )
    assert_equal(
      18.3025,
      @calc.compute_local_hour_angle(0.0791, true)
    )
  end

  def test_local_mean_time
    assert_equal(
      BigDecimal.new('11.0818'),
      @calc.compute_local_mean_time(
        BigDecimal.new('219.6960'),
        BigDecimal.new('-5.0523'),
        BigDecimal.new('18.3025'),
        BigDecimal.new('306.4605')
      )
    )
  end
end

#
class TestZoneTimes < MiniTest::Test
  def setup
    @date = Date.parse('2008-11-01') # 01 November 2008
    @calc = SolarEventCalculator.new(
      @date,
      BigDecimal.new('39.9537'),
      BigDecimal.new('-75.7850')
    )
  end

  def test_astronomical_twilight_start
    assert_equal(
      @calc.compute_utc_astronomical_sunrise,
      DateTime.parse(
        "#{@date.strftime}T10:01:00-00:00"
      )
    )
  end

  def test_nautical_twilight_start
    assert_equal(
      @calc.compute_utc_nautical_sunrise,
      DateTime.parse(
        "#{@date.strftime}T10:32:00-00:00"
      )
    )
  end

  def test_civil_twilight_start
    assert_equal(
      @calc.compute_utc_civil_sunrise,
      DateTime.parse(
        "#{@date.strftime}T11:04:00-00:00"
      )
    )
  end

  def test_sunrise
    assert_equal(
      @calc.compute_utc_official_sunrise,
      DateTime.parse(
        "#{@date.strftime}T11:33:00-00:00"
      )
    )
  end

  def test_zone_astronomical_twilight_start
    assert_equal(
      @calc.compute_astronomical_sunrise(
        'America/New_York'
      ),
      DateTime.parse(
        "#{@date.strftime}T06:01:00-04:00"
      )
    )
  end

  def test_zone_nautical_twilight_start
    assert_equal(
      @calc.compute_nautical_sunrise(
        'America/New_York'
      ),
      DateTime.parse(
        "#{@date.strftime}T06:32:00-04:00"
      )
    )
  end

  def test_zone_cival_twilight_start
    assert_equal(
      @calc.compute_civil_sunrise(
        'America/New_York'
      ),
      DateTime.parse(
        "#{@date.strftime}T07:04:00-04:00"
      )
    )
  end

  def test_zone_sunrise
    assert_equal(
      @calc.compute_official_sunrise(
        'America/New_York'
      ),
      DateTime.parse(
        "#{@date.strftime}T07:33:00-04:00"
      )
    )
  end
end

#
class TestSolarEventCalculator < MiniTest::Test
  def test_none
    date = Date.parse('2008-04-25') # 25 April 2008
    calc = SolarEventCalculator.new(
      date, BigDecimal.new('64.8378'), BigDecimal.new('-147.7164')
    )
    assert_nil(calc.compute_utc_nautical_sunrise, nil)

    date = Date.parse('2008-04-25') # 25 April 2008
    calc = SolarEventCalculator.new(
      date, BigDecimal.new('64.8378'), BigDecimal.new('-147.7164')
    )
    assert_nil(calc.compute_utc_nautical_sunrise, nil)
  end
end
