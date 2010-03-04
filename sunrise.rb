require 'bigdecimal'
require 'date'

class SolarEventCalculator

  @date
  @latitude
  @longitude

  def initialize(date, latitude, longitude)
    @date = date
    @latitude = latitude
    @longitude = longitude
  end

  def compute_longitude_hour
    lngHour = @longitude / BigDecimal.new("15")
  end

  def compute_rise_longitude_hour
    @date.yday + ((BigDecimal.new("6") - compute_longitude_hour) / BigDecimal.new("6"))
  end

  def compute_sun_mean_anomaly
    constant = BigDecimal.new("0.9856")
    (compute_rise_longitude_hour * constant) - BigDecimal.new("3.289")
  end

  def compute_sun_true_longitude
    meanAnomaly = compute_sun_mean_anomaly
    mAsRads = degrees_as_rads(meanAnomaly)
    sinM = BigDecimal.new(Math.sin(mAsRads.to_f).to_s)
    sinTwoM = BigDecimal.new(Math.sin((2 * mAsRads).to_f).to_s)
    firstParens = BigDecimal.new("1.916") * sinM
    secondParens = BigDecimal.new("0.020") * sinTwoM
    trueLong = meanAnomaly + firstParens + secondParens + 282.634

    put_in_range(trueLong, 0, 360, 360)
  end

  def compute_right_ascension
    tanL = BigDecimal.new(Math.tan(degrees_as_rads(compute_sun_true_longitude).to_f).to_s)
    ra = rads_as_degrees(BigDecimal.new(Math.atan(BigDecimal.new("0.91764") * tanL).to_s))

    put_in_range(ra, 0, 360, 360)
  end

  def put_in_range(number, lower, upper, adjuster)
    if number > upper then
      number -= adjuster
    elsif number < lower then
      number += adjuster
    else
      number
    end
  end

  def put_ra_in_correct_quadrant
    lQuadrant = BigDecimal.new("90") * (compute_sun_true_longitude / BigDecimal.new("90")).floor
    raQuadrant = BigDecimal.new("90") * (compute_right_ascension / BigDecimal.new("90")).floor

    ra = compute_right_ascension + (lQuadrant - raQuadrant)
    ra = ra / BigDecimal.new("15")
  end

  def compute_sin_sun_declination
    sinL = BigDecimal.new(Math.sin(degrees_as_rads(compute_sun_true_longitude).to_f).to_s)
    sinDec = sinL * BigDecimal.new("0.39782")
  end

  def compute_cosine_sun_declination
    BigDecimal.new(Math.cos(Math.asin(compute_sin_sun_declination)).to_s)
  end

  def compute_cosine_sun_local_hour
    cosZenith = BigDecimal.new(Math.cos(degrees_as_rads(BigDecimal.new("96"))).to_s)
    sinLatitude = BigDecimal.new(Math.sin(degrees_as_rads(@latitude)).to_s)
    cosLatitude = BigDecimal.new(Math.cos(degrees_as_rads(@latitude)).to_s)

    top = cosZenith - (compute_sin_sun_declination * sinLatitude)
    bottom = compute_cosine_sun_declination * cosLatitude
    cosLocalHour = top / bottom
  end

  def compute_local_hour_angle
    acosH = Math.acos(compute_cosine_sun_local_hour)
    localHourAngle = BigDecimal.new("360") - rads_as_degrees(acosH)
    localHourAngle = localHourAngle / BigDecimal.new("15")
  end

  def compute_local_mean_time
    h = compute_local_hour_angle
    ra = put_ra_in_correct_quadrant
    t = compute_rise_longitude_hour

    parens = BigDecimal.new("0.06571") * t
    time = h + ra - parens - BigDecimal.new("6.622")

    utcTime = time - compute_longitude_hour
  end

  def compute_utc_sunrise
    timeParts = compute_local_mean_time.to_s.split('.')
    mins = BigDecimal.new("." + timeParts[1]) * BigDecimal.new("60")
    mins = mins.truncate()

    hours = timeParts[0]
    Time.gm(@date.year, @date.mon, @date.mday, hours, pad_minutes(mins.to_i))
  end

  def compute_utc_sunset

  end

  def pad_minutes(minutes)
    if(minutes < 10)
      "0" + minutes.to_s
    end
  end

  def degrees_as_rads(degrees)
    pi = BigDecimal(Math::PI.to_s)
    radian = pi / BigDecimal.new("180")
    degrees * radian
  end

  def rads_as_degrees(radians)
    pi = BigDecimal(Math::PI.to_s)
    degree = BigDecimal.new("180") / pi
    radians * degree
  end
end
