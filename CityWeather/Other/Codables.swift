//
//  Codables.swift
//  CityWeather
//
//  Created by Ezenwa Okoro on 28/08/2021.
//

import UIKit

struct Object: Codable {
    
    let coord: Coordinates
    let name: String
    let timezone: Int
}

struct RequestError: Codable {
    
    let cod: String
    let message: String
}

struct Coordinates: Codable {
    
    let lat: Double
    let lon: Double
}

struct Response: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case latitude = "lat"
        case longitude = "lon"
        case timezone
        case timezoneOffset = "timezone_offset"
        case current
        case minutely = "minutely"
    }
    
    let longitude: Double
    let latitude: Double
    let timezone: String
    var timezoneOffset: Int
    let current: CurrentConditions
    let minutely: [Precipitation]?
    var name = ""
}

struct CurrentConditions: Codable {
    
    let unixTime: Int
    let sunrise: Int
    let sunset: Int
    let temperature: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Int
    let dewPoint: Double
    let uvIndex: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let windDirection: Int
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case unixTime = "dt"
        case sunrise = "sunrise"
        case sunset = "sunset"
        case temperature = "temp"
        case feelsLike = "feels_like"
        case pressure = "pressure"
        case humidity = "humidity"
        case dewPoint = "dew_point"
        case uvIndex = "uvi"
        case clouds = "clouds"
        case visibility = "visibility"
        case windSpeed = "wind_speed"
        case windDirection = "wind_deg"
        case weather = "weather"
    }
}

struct Weather: Codable {
    
    let title: String
    let description: String

    enum CodingKeys: String, CodingKey {
        
        case title = "main"
        case description = "description"
        
    }
}

// MARK: - Minutely
struct Precipitation: Codable {
    
    let unixTime: Int
    let precipitation: Double

    enum CodingKeys: String, CodingKey {
        
        case unixTime = "dt"
        case precipitation
    }
}
