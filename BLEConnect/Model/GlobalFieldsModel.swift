//
//  GlobalFieldsModel.swift
//  lynx
//
//  Created by user-new on 2/2/22.
//

import Foundation
import CoreLocation

protocol BaseFieldModel {
    var eventType: CommunicationMessagesTypesEnum { get set }
    var eventReferenceNumber: Int { get set }
    var eventGPSData: GPSDataModel { get set }
    var eventDateTime: TimeStampModel { get set }
}


struct GlobalFieldsModel: BaseFieldModel {
    
    static let globalMessageLength = 23
    
    var eventType = CommunicationMessagesTypesEnum.invalidMessage
    var eventReferenceNumber = 0
    var eventGPSData: GPSDataModel
    var eventDateTime: TimeStampModel

    init(eventType: CommunicationMessagesTypesEnum, referenceNumber: Int, gpsData: GPSDataModel, gpsDateTime: TimeStampModel) {
        
        self.eventType = eventType
        self.eventReferenceNumber = referenceNumber
        self.eventGPSData = gpsData
        self.eventDateTime = gpsDateTime
    }

}

struct GPSDataModel {
    
    var lat = 0.0
    var lon = 0.0
    var heading = 0.0
    var speed = 0
    
    init(lat: Int, lon: Int, heading: Double, speed: Int) {
        self.lat = getLatitudeOrLongitudeValue(value: lat)
        self.lon = getLatitudeOrLongitudeValue(value: lon)
        self.heading = heading
        self.speed = speed
    }
    
    func getLatitudeOrLongitudeValue(value: Int) -> Double {
        return Double(value) / 1000000.0
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    func isValid() -> Bool {
        return (lat != 0 || lon != 0) && heading >= 0 && heading <= 359
    }
}

struct TimeStampModel {
   
    var year = 0
    var month = 0
    var day = 0
    var hour = 0
    var minutes = 0
    var seconds = 0

    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = "\(year)-\(month)-\(day) \(hour):\(minutes):\(seconds)"
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        return Date()
    }
}
