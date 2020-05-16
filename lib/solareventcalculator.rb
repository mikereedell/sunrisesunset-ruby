require 'bigdecimal'
require 'date'
require 'tzinfo'

class SolarEventCalculator

  def initialize(date, latitude, longitude)
    @date = date
    @latitude = latitude
    @longitude = longitude
  end

  def compute_lnghour
    lngHour = @longitude / BigDecimal("15")
    lngHour.round(4)
  end

  def compute_longitude_hour(isSunrise)
    minuend = (isSunrise) ? BigDecimal("6") : BigDecimal("18")
    longHour = @date.yday + ((minuend - compute_lnghour) / BigDecimal("24"))
    longHour.round(4)
  end

  def compute_sun_mean_anomaly(longHour)
    constant = BigDecimal("0.9856")
    ((longHour * constant) - BigDecimal("3.289")).round(4)
  end

  def compute_sun_true_longitude(meanAnomaly)
    mAsRads = degrees_as_rads(meanAnomaly)
    sinM = BigDecimal(Math.sin(mAsRads.to_f).to_s)
    sinTwoM = BigDecimal(Math.sin((2 * mAsRads).to_f).to_s)
    firstParens = BigDecimal("1.916") * sinM
    secondParens = BigDecimal("0.020") * sinTwoM
    trueLong = meanAnomaly + firstParens + secondParens + BigDecimal("282.634")
    trueLong = put_in_range(trueLong, 0, 360, 360)
    trueLong.round(4)
  end

  def compute_right_ascension(sunTrueLong)
    tanL = BigDecimal(Math.tan(degrees_as_rads(sunTrueLong).to_f).to_s)
    ra = rads_as_degrees(BigDecimal(Math.atan(BigDecimal("0.91764") * tanL).to_s))

    ra = put_in_range(ra, 0, 360, 360)
    ra.round(4)
  end

  def put_ra_in_correct_quadrant(sunTrueLong)
    lQuadrant = BigDecimal("90") * (sunTrueLong / BigDecimal("90")).floor
    raQuadrant = BigDecimal("90") * (compute_right_ascension(sunTrueLong) / BigDecimal("90")).floor

    ra = compute_right_ascension(sunTrueLong) + (lQuadrant - raQuadrant)
    ra = ra / BigDecimal("15")
    ra.round(4)
  end

  def compute_sin_sun_declination(sunTrueLong)
    sinL = BigDecimal(Math.sin(degrees_as_rads(sunTrueLong).to_f).to_s)
    sinDec = sinL * BigDecimal("0.39782")
    sinDec.round(4)
  end

  def compute_cosine_sun_declination(sinSunDeclination)
    cosDec = BigDecimal(Math.cos(Math.asin(sinSunDeclination)).to_s)
    cosDec.round(4)
  end

  def compute_cosine_sun_local_hour(sunTrueLong, zenith)
    cosZenith = BigDecimal(Math.cos(degrees_as_rads(BigDecimal(zenith.to_s))).to_s)
    sinLatitude = BigDecimal(Math.sin(degrees_as_rads(@latitude)).to_s)
    cosLatitude = BigDecimal(Math.cos(degrees_as_rads(@latitude)).to_s)

    sinSunDeclination = compute_sin_sun_declination(sunTrueLong)
    top = cosZenith - (sinSunDeclination * sinLatitude)
    bottom = compute_cosine_sun_declination(sinSunDeclination) * cosLatitude

    cosLocalHour = top / bottom
    cosLocalHour.round(4)
  end

  def compute_local_hour_angle(cosSunLocalHour, isSunrise)
    acosH = BigDecimal(Math.acos(cosSunLocalHour).to_s)
    acosHDegrees = rads_as_degrees(acosH)

    localHourAngle = (isSunrise) ? BigDecimal("360") - acosHDegrees : acosHDegrees
    localHourAngle = localHourAngle / BigDecimal("15")
    localHourAngle.round(4)
  end

  def compute_local_mean_time(sunTrueLong, longHour, t,  sunLocalHour)
    h = sunLocalHour
    ra = put_ra_in_correct_quadrant(sunTrueLong)

    parens = BigDecimal("0.06571") * t
    time = h + ra - parens - BigDecimal("6.622")

    utcTime = time - longHour
    utcTime = put_in_range(utcTime, 0, 24, 24)
    utcTime.round(4)
  end

  def compute_utc_solar_event(zenith, isSunrise)
    longHour = compute_lnghour
    eventLongHour = compute_longitude_hour(isSunrise)

    meanAnomaly = compute_sun_mean_anomaly(eventLongHour)
    sunTrueLong = compute_sun_true_longitude(meanAnomaly)
    cosineSunLocalHour = compute_cosine_sun_local_hour(sunTrueLong, zenith)

    if(cosineSunLocalHour > BigDecimal("1") || cosineSunLocalHour < BigDecimal("-1"))
      return nil
    end

    sunLocalHour = compute_local_hour_angle(cosineSunLocalHour, isSunrise)
    localMeanTime = compute_local_mean_time(sunTrueLong, longHour, eventLongHour, sunLocalHour)

    timeParts = localMeanTime.to_f.to_s.split('.')
    mins = BigDecimal("." + timeParts[1]) * BigDecimal("60")
    mins = mins.truncate()
    mins = pad_minutes(mins.to_i)
    hours = timeParts[0]

    Time.utc(@date.year, @date.mon, @date.mday, hours, pad_minutes(mins.to_i))
  end

  def compute_utc_civil_sunrise
    convert_to_datetime(compute_utc_solar_event(96, true))
  end

  def compute_utc_civil_sunset
    convert_to_datetime(compute_utc_solar_event(96, false))
  end

  def compute_utc_official_sunrise
    convert_to_datetime(compute_utc_solar_event(90.8333, true))
  end

  def compute_utc_official_sunset
    convert_to_datetime(compute_utc_solar_event(90.8333, false))
  end

  def compute_utc_nautical_sunrise
    convert_to_datetime(compute_utc_solar_event(102, true))
  end

  def compute_utc_nautical_sunset
    convert_to_datetime(compute_utc_solar_event(102, false))
  end

  def compute_utc_astronomical_sunrise
    convert_to_datetime(compute_utc_solar_event(108, true))
  end

  def compute_utc_astronomical_sunset
    convert_to_datetime(compute_utc_solar_event(108, false))
  end

  def convert_to_datetime(time)
    return unless time
    DateTime.parse("#{@date.strftime}T#{time.hour}:#{time.min}:00+0000")
  end

  def compute_civil_sunrise(timezone)
    put_in_timezone(compute_utc_solar_event(96, true), timezone)
  end

  def compute_civil_sunset(timezone)
    put_in_timezone(compute_utc_solar_event(96, false), timezone)
  end

  def compute_official_sunrise(timezone)
    put_in_timezone(compute_utc_solar_event(90.8333, true), timezone)
  end

  def compute_official_sunset(timezone)
    put_in_timezone(compute_utc_solar_event(90.8333, false), timezone)
  end

  def compute_nautical_sunrise(timezone)
    put_in_timezone(compute_utc_solar_event(102, true), timezone)
  end

  def compute_nautical_sunset(timezone)
    put_in_timezone(compute_utc_solar_event(102, false), timezone)
  end

  def compute_astronomical_sunrise(timezone)
    put_in_timezone(compute_utc_solar_event(108, true), timezone)
  end

  def compute_astronomical_sunset(timezone)
    put_in_timezone(compute_utc_solar_event(108, false), timezone)
  end

  def put_in_timezone(utcTime, timezone)
    tz = TZInfo::Timezone.get(timezone)
    # puts "UTCTime #{utcTime}"
    local = utcTime + get_utc_offset(timezone)
    # puts "LocalTime #{local}"

    offset = (get_utc_offset(timezone) / 60 / 60).to_i
    offset = (offset > 0) ? "+" + offset.to_s : offset.to_s

    timeInZone = DateTime.parse("#{@date.strftime}T#{local.strftime('%H:%M:%S')}#{offset}")
    # puts "CALC:timeInZone #{timeInZone}"
    timeInZone
  end

  def get_utc_offset(timezone)
    tz = TZInfo::Timezone.get(timezone)
    noonUTC = Time.gm(@date.year, @date.mon, @date.mday, 12, 0)
    tz.utc_to_local(noonUTC) - noonUTC
  end

  def pad_minutes(minutes)
    if(minutes < 10)
      "0" + minutes.to_s
    else
      minutes
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
    radian = pi / BigDecimal("180")
    degrees * radian
  end

  def rads_as_degrees(radians)
    pi = BigDecimal(Math::PI.to_s)
    degree = BigDecimal("180") / pi
    radians * degree
  end

end
