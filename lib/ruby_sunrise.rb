# frozen_string_literal: true

require "ruby_sunrise/identity"

require "bigdecimal"
require "date"
require "tzinfo"

class SolarEventCalculator
  def initialize(date, latitude, longitude)
    @date = date
    @latitude = latitude
    @longitude = longitude
  end

  def compute_longitude_event_hour(is_sunrise)
    longitude_event_hour(is_sunrise).then { |hour| hour - compute_longitude_hour }
                                    .then { |hour| hour / BigDecimal("24") }
                                    .then { |hour| date.yday + hour }
                                    .then { |hour| hour.round(4) }
  end

  def longitude_event_hour(is_sunrise)
    is_sunrise ? BigDecimal("6") : BigDecimal("18")
  end

  def compute_longitude_hour
    (longitude / BigDecimal("15")).round(4)
  end

  def compute_sun_mean_anomaly(longitude_hour)
    (longitude_hour * BigDecimal("0.9856")).then { |mean| mean - BigDecimal("3.289") }
                                           .then { |mean| mean.round(4) }
  end

  def compute_sun_true_longitude(mean_anomaly)
    radians = degrees_as_radians(mean_anomaly)
    sine_1 = BigDecimal(Math.sin(radians.to_f).to_s)
    size_2 = BigDecimal(Math.sin((2 * radians).to_f).to_s)
    parens_1 = BigDecimal("1.916") * sine_1
    parens_2 = BigDecimal("0.020") * size_2

    (mean_anomaly + parens_1 + parens_2 + BigDecimal("282.634")).then { |longitude| put_in_range(longitude, 0, 360, 360) }
                                                                .then { |longitude| longitude.round(4) }
  end

  def compute_right_ascension(sun_true_longitude)
    degrees_as_radians(sun_true_longitude).then { |radians| Math.tan(radians.to_f) }
                                          .then { |tangent| BigDecimal(tangent.to_s) }
                                          .then { |tangent| Math.atan(BigDecimal("0.91764") * tangent) }
                                          .then { |arc_tangent| BigDecimal(arc_tangent.to_s) }
                                          .then { |arc_tangent| radians_as_degrees(arc_tangent) }
                                          .then { |degrees| put_in_range(degrees, 0, 360, 360) }
                                          .then { |degrees| degrees.round(4) }
  end

  def compute_sin_sun_declination(sun_true_longitude)
    degrees_as_radians(sun_true_longitude).then { |radians| Math.sin(radians.to_f) }
                                          .then { |sine| BigDecimal(sine.to_s) }
                                          .then { |sine| sine * BigDecimal("0.39782") }
                                          .then { |sine| sine.round(4) }
  end

  def compute_cosine_sun_declination(number)
    Math.asin(number).then { |arc_sine| Math.cos(arc_sine) }
                     .then { |cosine| BigDecimal(cosine.to_s) }
                     .then { |decimal| decimal.round(4) }
  end

  def compute_cosine_sun_local_hour(sun_true_long, zenith)
    cosine_zenith = BigDecimal(Math.cos(degrees_as_radians(BigDecimal(zenith.to_s))).to_s)
    sine_latitude = BigDecimal(Math.sin(degrees_as_radians(@latitude)).to_s)
    cosine_latitude = BigDecimal(Math.cos(degrees_as_radians(@latitude)).to_s)

    sine_sun_declination = compute_sin_sun_declination(sun_true_long)
    top = cosine_zenith - (sine_sun_declination * sine_latitude)
    bottom = compute_cosine_sun_declination(sine_sun_declination) * cosine_latitude

    (top / bottom).round(4)
  end

  def compute_local_hour_angle(cos_sun_local_hour, is_sunrise)
    Math.acos(cos_sun_local_hour).then { |arc_cosine| BigDecimal(arc_cosine.to_s) }
                                 .then { |arc_cosine| radians_as_degrees(arc_cosine) }
                                 .then { |degrees| is_sunrise ? BigDecimal("360") - degrees : degrees }
                                 .then { |angle| angle / BigDecimal("15") }
                                 .then { |angle| angle.round(4) }
  end

  def compute_local_mean_time(sun_true_longitude, longitude_hour, longitude_event_hour, sun_local_hour)
    correct_quadrant_for_right_ascension(sun_true_longitude).then { |radians| sun_local_hour + radians }
                                                            .then { |time| time - (BigDecimal("0.06571") * longitude_event_hour) }
                                                            .then { |time| time - BigDecimal("6.622") }
                                                            .then { |time| time - longitude_hour }
                                                            .then { |time| put_in_range(time, 0, 24, 24) }
                                                            .then { |time| time.round(4) }
  end

  def correct_quadrant_for_right_ascension(sun_true_long)
    l_quadrant = BigDecimal("90") * (sun_true_long / BigDecimal("90")).floor
    right_ascension_quadrant = BigDecimal("90") * (compute_right_ascension(sun_true_long) / BigDecimal("90")).floor

    compute_right_ascension(sun_true_long).then { |right_ascension| right_ascension + (l_quadrant - right_ascension_quadrant) }
                                          .then { |right_ascension| right_ascension / BigDecimal("15") }
                                          .then { |right_ascension| right_ascension.round(4) }
  end

  def compute_utc_solar_event(zenith, is_sunrise)
    longitude_event_hour = compute_longitude_event_hour(is_sunrise)

    sun_mean_anomaly = compute_sun_mean_anomaly(longitude_event_hour)
    sun_true_longitude = compute_sun_true_longitude(sun_mean_anomaly)
    cosine_sun_local_hour = compute_cosine_sun_local_hour(sun_true_longitude, zenith)

    return if (cosine_sun_local_hour > BigDecimal("1") || cosine_sun_local_hour < BigDecimal("-1"))

    sun_local_hour = compute_local_hour_angle(cosine_sun_local_hour, is_sunrise)
    local_mean_time = compute_local_mean_time(sun_true_longitude, compute_longitude_hour, longitude_event_hour, sun_local_hour)

    time_parts = local_mean_time.to_f.to_s.split(".")
    hours = time_parts[0]

    (BigDecimal("." + time_parts[1]) * BigDecimal("60")).then(&:truncate)
                                                        .then { |minutes| zero_pad(minutes) }
                                                        .then { |minutes| Time.utc(date.year, date.mon, date.mday, hours, zero_pad(minutes)) }
  end

  def compute_utc_civil_sunrise
    to_datetime(compute_utc_solar_event(96, true))
  end

  def compute_utc_civil_sunset
    to_datetime(compute_utc_solar_event(96, false))
  end

  def compute_utc_official_sunrise
    to_datetime(compute_utc_solar_event(90.8333, true))
  end

  def compute_utc_official_sunset
    to_datetime(compute_utc_solar_event(90.8333, false))
  end

  def compute_utc_nautical_sunrise
    to_datetime(compute_utc_solar_event(102, true))
  end

  def compute_utc_nautical_sunset
    to_datetime(compute_utc_solar_event(102, false))
  end

  def compute_utc_astronomical_sunrise
    to_datetime(compute_utc_solar_event(108, true))
  end

  def compute_utc_astronomical_sunset
    to_datetime(compute_utc_solar_event(108, false))
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

  private

  attr_reader :date, :latitude, :longitude

  def to_datetime(time)
    return unless time

    DateTime.parse("#{date.strftime}T#{time.hour}:#{time.min}:00+0000")
  end

  def degrees_as_radians(degrees)
    BigDecimal(Math::PI.to_s).then { |pi| pi / BigDecimal("180") }
                             .then { |radians| radians * degrees }
  end

  def radians_as_degrees(radians)
    BigDecimal(Math::PI.to_s).then { |pi| BigDecimal("180") / pi }
                             .then { |degrees| degrees * radians }
  end

  def zero_pad(minutes)
    String(minutes).rjust 2, "0"
  end

  def get_utc_offset(timezone)
    tz = TZInfo::Timezone.get(timezone)
    noonUTC = Time.gm(@date.year, @date.mon, @date.mday, 12, 0)
    tz.utc_to_local(noonUTC) - noonUTC
  end

  def put_in_range(number, lower, upper, adjuster)
    if number > upper
      number - adjuster
    elsif number < lower
      number + adjuster
    else
      number
    end
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
end
