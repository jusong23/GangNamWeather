// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let openWeather = try? JSONDecoder().decode(OpenWeather.self, from: jsonData)

import Foundation

// MARK: - OpenWeather
struct OpenWeather: Codable {
    let lat, lon: Double?
    let timezone: String
    let timezoneOffset: Double?
    let current: Current
    let minutely: [Minutely]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, minutely, daily
    }
}

// MARK: - Current
struct Current: Codable {
    let dt, sunrise, sunset: Double?
    let temp, feelsLike: Double?
    let pressure, humidity: Double?
    let dewPoint: Double?
    let uvi, clouds, visibility: Double?
    let windSpeed: Double?
    let windDeg: Double?
    let windGust: Double?
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case uvi, clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Double?
    let main, description, icon: String
}

// MARK: - Daily
struct Daily: Codable {
    let dt, sunrise, sunset, moonrise: Double?
    let moonset: Double?
    let moonPhase: Double?
    let temp: Temp
    let feelsLike: FeelsLike
    let pressure, humidity: Double?
    let dewPoint, windSpeed: Double?
    let windDeg: Double?
    let windGust: Double?
    let weather: [Weather]
    let clouds: Double?
    let pop: Double?
    let uvi: Double?
    let rain, snow: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather, clouds, pop, uvi, rain, snow
    }
}

// MARK: - FeelsLike
struct FeelsLike: Codable {
    let day, night, eve, morn: Double?
}

// MARK: - Temp
struct Temp: Codable {
    let day, min, max, night: Double?
    let eve, morn: Double?
}

// MARK: - Minutely
struct Minutely: Codable {
    let dt, precipitation: Double?
}
