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
    lngHour.round(4)
  end

  def compute_rise_longitude_hour
    longHour = @date.yday + ((BigDecimal.new("6") - compute_longitude_hour) / BigDecimal.new("24"))
    longHour.round(4)
  end

  def compute_set_longitude_hour
    longHour = @date.yday + ((BigDecimal.new("18") - compute_longitude_hour) / BigDecimal.new("24"))
    longHour.round(4)
  end

  def compute_sun_mean_anomaly(longHour)
    constant = BigDecimal.new("0.9856")
    ((longHour * constant) - BigDecimal.new("3.289")).round(4)
  end

  def compute_sun_true_longitude(meanAnomaly)
    mAsRads = degrees_as_rads(meanAnomaly)
    sinM = BigDecimal.new(Math.sin(mAsRads.to_f).to_s)
    sinTwoM = BigDecimal.new(Math.sin((2 * mAsRads).to_f).to_s)
    firstParens = BigDecimal.new("1.916") * sinM
    secondParens = BigDecimal.new("0.020") * sinTwoM
    trueLong = meanAnomaly + firstParens + secondParens + BigDecimal.new("282.634")
    trueLong = put_in_range(trueLong, 0, 360, 360)
    trueLong.round(4)
  end

  def compute_right_ascension(sunTrueLong)
    tanL = BigDecimal.new(Math.tan(degrees_as_rads(sunTrueLong).to_f).to_s)
    ra = rads_as_degrees(BigDecimal.new(Math.atan(BigDecimal.new("0.91764") * tanL).to_s))

    ra = put_in_range(ra, 0, 360, 360)
    ra.round(4)
  end

  def put_ra_in_correct_quadrant(sunTrueLong)
    lQuadrant = BigDecimal.new("90") * (sunTrueLong / BigDecimal.new("90")).floor
    raQuadrant = BigDecimal.new("90") * (compute_right_ascension(sunTrueLong) / BigDecimal.new("90")).floor

    ra = compute_right_ascension(sunTrueLong) + (lQuadrant - raQuadrant)
    ra = ra / BigDecimal.new("15")
    ra.round(4)
  end

  def compute_sin_sun_declination(sunTrueLong)
    sinL = BigDecimal.new(Math.sin(degrees_as_rads(sunTrueLong).to_f).to_s)
    sinDec = sinL * BigDecimal.new("0.39782")
    sinDec.round(4)
  end

  def compute_cosine_sun_declination(sinSunDeclination)
    cosDec = BigDecimal.new(Math.cos(Math.asin(sinSunDeclination)).to_s)
    cosDec.round(4)
  end

  def compute_cosine_sun_local_hour(sunTrueLong, zenith)
    cosZenith = BigDecimal.new(Math.cos(degrees_as_rads(BigDecimal.new(zenith.to_s))).to_s)
    sinLatitude = BigDecimal.new(Math.sin(degrees_as_rads(@latitude)).to_s)
    cosLatitude = BigDecimal.new(Math.cos(degrees_as_rads(@latitude)).to_s)

    sinSunDeclination = compute_sin_sun_declination(sunTrueLong)
    top = cosZenith - (sinSunDeclination * sinLatitude)
    bottom = compute_cosine_sun_declination(sinSunDeclination) * cosLatitude

    cosLocalHour = top / bottom
    cosLocalHour.round(4)
  end

  def compute_local_hour_angle(cosSunLocalHour)
    acosH = BigDecimal.new(Math.acos(cosSunLocalHour).to_s)
    localHourAngle = BigDecimal.new("360") - rads_as_degrees(acosH)
    localHourAngle = localHourAngle / BigDecimal.new("15")
    localHourAngle.round(4)
  end

  def compute_set_local_hour_angle
    acosH = Math.acos(compute_cosine_sun_local_hour)
    localHourAngle = acosH / BigDecimal.new("15")
  end

  def compute_local_mean_time(sunTrueLong, longHour, sunLocalHour)
    h = sunLocalHour
    ra = put_ra_in_correct_quadrant(sunTrueLong)
    t = compute_rise_longitude_hour

    parens = BigDecimal.new("0.06571") * t
    time = h + ra - parens - BigDecimal.new("6.622")

    utcTime = time - longHour
    utcTime = put_in_range(utcTime, 0, 24, 24)
    utcTime.round(4)
  end

  def compute_utc_sunrise(zenith)
    longHour = compute_longitude_hour
    riseLongHour = compute_rise_longitude_hour

    meanAnomaly = compute_sun_mean_anomaly(riseLongHour)
    sunTrueLong = compute_sun_true_longitude(meanAnomaly)
    cosineSunLocalHour = compute_cosine_sun_local_hour(sunTrueLong, zenith)

    if(cosineSunLocalHour > BigDecimal.new("1") || cosineSunLocalHour < BigDecimal.new("-1"))
      return nil
    end

    sunLocalHour = compute_local_hour_angle(cosineSunLocalHour)
    localMeanTime = compute_local_mean_time(sunTrueLong, longHour, sunLocalHour)

    timeParts = localMeanTime.to_s('F').split('.')
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

  def put_in_range(number, lower, upper, adjuster)
    if number > upper then
      number -= adjuster
    elsif number < lower then
      number += adjuster
    else
      number
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
