#!/usr/bin/env/ruby

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solareventcalculator'
require 'date'
date = Date.today + 1
lat  = 41.95
lng  = -88.743
timezone = 'America/Chicago'
zenith = 90.833

calc = SolarEventCalculator.new(date, lat, lng)
p lngHour = calc.compute_lnghour.to_f
calc.get_utc_offset(timezone)

puts
isSunrise = true
p longHour = calc.compute_longitude_hour(isSunrise).to_f
p meanAnomaly = calc.compute_sun_mean_anomaly(longHour).to_f
p sunTrueLong = calc.compute_sun_true_longitude(meanAnomaly)
p calc.compute_right_ascension(sunTrueLong)
p calc.put_ra_in_correct_quadrant(sunTrueLong)
p sinSunDeclination = calc.compute_sine_sun_declination(sunTrueLong)
p calc.compute_cosine_sun_declination(sinSunDeclination)
p cosSunLocalHour = calc.compute_cosine_sun_local_hour(sunTrueLong, zenith)
p sunLocalHour = calc.compute_local_hour_angle(cosSunLocalHour, isSunrise)
p calc.compute_local_mean_time(sunTrueLong, longHour, lngHour,  sunLocalHour)
p rise = calc.compute_utc_solar_event(zenith, isSunrise)
p calc.put_in_timezone(rise, timezone)
puts
isSunrise = false
p longHour = calc.compute_longitude_hour(isSunrise).to_f
p meanAnomaly = calc.compute_sun_mean_anomaly(longHour).to_f
p sunTrueLong = calc.compute_sun_true_longitude(meanAnomaly)
p calc.compute_right_ascension(sunTrueLong)
p calc.put_ra_in_correct_quadrant(sunTrueLong)
p sinSunDeclination = calc.compute_sine_sun_declination(sunTrueLong)
p calc.compute_cosine_sun_declination(sinSunDeclination)
p calc.compute_cosine_sun_local_hour(sunTrueLong, zenith)
p cosSunLocalHour = calc.compute_cosine_sun_local_hour(sunTrueLong, zenith)
p sunLocalHour = calc.compute_local_hour_angle(cosSunLocalHour, isSunrise)
p calc.compute_local_mean_time(sunTrueLong, longHour, lngHour,  sunLocalHour)
p set = calc.compute_utc_solar_event(zenith, isSunrise)
p calc.put_in_timezone(set, timezone)
