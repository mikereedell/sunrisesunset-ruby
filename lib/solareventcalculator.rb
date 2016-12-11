
require 'bigdecimal'
require 'date'
require 'tzinfo'

#
class SolarEventCalculator
  include Math
  attr_accessor :date, :latitude, :longitude
  attr_accessor :pi, :to_rad, :to_deg, :cycle

  def initialize(date, latitude, longitude)
    @date = date
    @latitude = latitude
    @longitude = longitude
    @pi = PI
    @cycle = @pi * 2
    @to_rad = @pi / 180.0
    @to_deg = 180.0 / @pi
  end

  def compute_lnghour
    lng_hour = @longitude / BigDecimal.new('15')
    lng_hour.round(4)
  end

  def compute_longitude_hour(is_sunrise)
    minuend = is_sunrise ? BigDecimal.new('6') : BigDecimal.new('18')
    long_hour =
      @date.yday +
      ((minuend - compute_lnghour) /
      BigDecimal.new('24'))
    long_hour.round(4)
  end

  def compute_sun_mean_anomaly(long_hour)
    constant = BigDecimal.new('0.9856')
    ((long_hour * constant) - BigDecimal.new('3.289')).round(4)
  end

  def compute_sun_true_longitude(mean_anomaly)
    ma_rads = mean_anomaly * @to_rad
    sin_ma = sin(ma_rads)
    sin_2_ma = sin(2 * ma_rads)
    first_parens = sin_ma * 1.916
    second_parens = sin_2_ma * 0.020
    true_long = mean_anomaly + first_parens + second_parens + 282.634
    true_long = put_in_range(true_long, 0, 360, 360)
    true_long.round(4)
  end

  def put_in_range(number, lower, upper, adjuster)
    number -= adjuster if number > upper
    number += adjuster if number < lower
    number
  end

  def compute_right_ascension(true_long)
    tan = tan(true_long * @to_rad)
    ra = atan(0.91764 * tan) * @to_deg
    ra = put_in_range(ra, 0, 360, 360)
    ra.round(4)
  end

  def put_ra_in_correct_quadrant(true_long)
    l_quadrant = 90.0 * (true_long / 90.0).floor
    ra_quadrant = 90.0 * (compute_right_ascension(true_long) / 90.0).floor

    ra = compute_right_ascension(true_long) + (l_quadrant - ra_quadrant)
    ra /= 15.0
    ra.round(4)
  end

  def compute_sine_sun_declination(true_long)
    sine = sin(true_long * @to_rad)
    sin_dec = sine * 0.39782
    sin_dec.round(4)
  end

  def compute_cosine_sun_declination(sine_declination)
    cos_dec = cos(asin(sine_declination))
    cos_dec.round(4)
  end

  def compute_cosine_sun_local_hour(true_long, zenith)
    cosine_zenith = cos(zenith * @to_rad)
    sine_latitude = sin(@latitude * @to_rad)
    cosine_latitude = cos(@latitude * @to_rad)
    sine_declination = compute_sine_sun_declination(true_long)
    top = cosine_zenith - (sine_declination * sine_latitude)
    bottom = compute_cosine_sun_declination(sine_declination) * cosine_latitude
    cosine_local_hour = top / bottom
    cosine_local_hour.round(4)
  end

  def compute_local_hour_angle(cosine_local_hour, is_sunrise)
    acos_h = acos(cosine_local_hour)
    local_hour_angle = is_sunrise ? @cycle - acos_h : acos_h
    local_hour_angle /= 15.0
    (local_hour_angle * @to_deg).round(4)
  end

  def compute_local_mean_time(true_long, long_hour, t, local_hour)
    h = local_hour
    ra = put_ra_in_correct_quadrant(true_long)
    parens = 0.06571 * t
    time = h + ra - parens - 6.622
    utc_time = time - long_hour
    utc_time = put_in_range(utc_time, 0, 24, 24)
    utc_time.round(4)
  end

  def pad_minutes(minutes)
    if minutes < 10
      '0' + minutes.to_s
    else
      minutes
    end
  end

  def cosine_range(cosine_local_hour)
    cosine = cosine_local_hour
    cosine_local_hour > BigDecimal.new('1') ? cosine = nil : cosine
    cosine_local_hour < BigDecimal.new('-1') ? cosine = nil : cosine
    cosine
  end

  def compute_utc_solar_event(zenith, is_sunrise)
    event_long_hour = compute_longitude_hour(is_sunrise)
    mean_anomaly = compute_sun_mean_anomaly(event_long_hour)
    true_long = compute_sun_true_longitude(mean_anomaly)
    cosine_local_hour = compute_cosine_sun_local_hour(true_long, zenith)
    cosine_range(cosine_local_hour).nil? ? return : cosine_local_hour
    local_hour = compute_local_hour_angle(cosine_local_hour, is_sunrise)
    local_mean_time =
      compute_local_mean_time(
        true_long,
        compute_lnghour,
        event_long_hour,
        local_hour
      )
    time_parts = local_mean_time.to_f.to_s.split('.')
    mins = BigDecimal.new('.' + time_parts[1]) * BigDecimal.new('60')
    mins = mins.truncate.to_f
    hours = time_parts[0].to_f
    Time.utc(
      @date.year,
      @date.mon,
      @date.mday,
      hours,
      pad_minutes(mins.to_i),
      0
    ).to_datetime
    DateTime.new(@date.year, @date.mon, @date.day, hours, mins, 0)
  end

  def convert_to_datetime(time)
    unless time.nil? DateTime.parse(
      "#{@date.strftime}T#{time.hour}:#{time.min}:00+0000"
    )
    end
  end

  def get_utc_offset(timezone)
    tz = TZInfo::Timezone.get(timezone)
    noon_utc = Time.gm(@date.year, @date.mon, @date.mday, 12, 0)
    tz.utc_to_local(noon_utc) - noon_utc
  end

  def dt_from_utc_time(utc_time, offset)
    DateTime.new(
      utc_time.to_date.year,
      utc_time.to_date.month,
      utc_time.to_date.day,
      (utc_time + offset.to_f).hour,
      (utc_time + offset.to_f).min,
      (utc_time + offset.to_f).sec,
      offset
    )
  end

  def put_in_timezone(utc_time, timezone)
    offset = Rational((get_utc_offset(timezone) / 60.0 / 60.0).to_i, 24)
    dt_from_utc_time(utc_time, offset)
  end

  def compute_utc_astronomical_sunrise
    compute_utc_solar_event(108, true)
  end

  def compute_astronomical_sunrise(timezone)
    date_time = compute_utc_solar_event(108, true)
    put_in_timezone(date_time, timezone)
  end

  def compute_utc_nautical_sunrise
    compute_utc_solar_event(102, true)
  end

  def compute_nautical_sunrise(timezone)
    compute_utc_solar_event(102, true)
    put_in_timezone(compute_utc_solar_event(102, true), timezone)
  end

  def compute_utc_civil_sunrise
    compute_utc_solar_event(96, true)
  end

  def compute_civil_sunrise(timezone)
    compute_utc_solar_event(96, true)
    put_in_timezone(compute_utc_solar_event(96, true), timezone)
  end

  def compute_utc_official_sunrise
    compute_utc_solar_event(90.8333, true)
  end

  def compute_official_sunrise(timezone)
    sr = compute_utc_solar_event(90.8333, true)
    put_in_timezone(sr, timezone)
  end

  def compute_utc_official_sunset
    compute_utc_solar_event(90.8333, false)
  end

  def compute_official_sunset(timezone)
    compute_utc_solar_event(90.8333, false)
    put_in_timezone(compute_utc_solar_event(90.8333, false), timezone)
  end

  def compute_utc_civil_sunset
    compute_utc_solar_event(96, false)
  end

  def compute_civil_sunset(timezone)
    compute_utc_solar_event(96, false)
    put_in_timezone(compute_utc_solar_event(96, false), timezone)
  end

  def compute_utc_nautical_sunset
    compute_utc_solar_event(102, false)
  end

  def compute_nautical_sunset(timezone)
    compute_utc_solar_event(102, false)
    put_in_timezone(compute_utc_solar_event(102, false), timezone)
  end

  def compute_utc_astronomical_sunset
    compute_utc_solar_event(108, false)
  end

  def compute_astronomical_sunset(timezone)
    compute_utc_solar_event(108, false)
    put_in_timezone(compute_utc_solar_event(108, false), timezone)
  end

  def degrees_to_radians(degrees)
    degrees * @to_rad
  end

  def radians_to_degrees(radians)
    radians * @to_deg
  end
end
