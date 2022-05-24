//
//  BaseSensorEvents.swift
//  lynx
//
//  Created by user-new on 1/30/22.
//

import Foundation

class BaseSensorEvents {
    
    var welcomeMsg = WelcomeMsg()
    var delegate: SensorEventsDelegate?
    var isLogger = false
    
    static let MAX_BLACK_BOX_BUFFER_SIZE = 190 // 10s * ((1000ms/50ms) = 20) = (10*20=200)
    static let MAX_BLACK_BOX_TIMEOUT = 60000 // 10s * ((1000ms/50ms) = 20) = (10*20=200)


    func parserWelcomeMsgMessage(data: Data, isObg: Bool) -> WelcomeMsg {
        
        guard data.count >= 6 else { return welcomeMsg }
        
        let eventType = ByteBuffer.fromByteArray([data[0]], Int.self)
        let eventTypeEnum = ManeuverType(rawValue: eventType, isOBG: isObg)
        guard eventTypeEnum == .sensorTimeSmart else { return welcomeMsg }
        
        let messageTimeSensor = ByteBuffer.fromByteArray([data[1], data[2], data[3], data[4]], Int.self)
        let currentTime = Date().timeIntervalSince1970
        let mDiffTimeSensorConnectedSec = currentTime - Double(messageTimeSensor)
        welcomeMsg.time = Int(mDiffTimeSensorConnectedSec)
        //TODO: in android       welcomeMsg.time = messageTimeSensor
  
        if data.count >= 8 {
            let tagBattery = ByteBuffer.fromByteArray([data[5],data[6]], Int.self)
            welcomeMsg.battery = tagBattery
            
            NotificationCenter.default.post(name: .displayBattery, object: nil, userInfo: [SensorConstans.SensorNotificationKeys.battery: welcomeMsg.battery])
        }
        
        if data.count >= 9 {
            welcomeMsg.IsDriving = ByteBuffer.fromByteArray([data[7]], Int.self)
        }
        
        if data.count >= 13 {
            welcomeMsg.majorA = ByteBuffer.fromByteArray([data[8]], Int.self)
            welcomeMsg.majorB = ByteBuffer.fromByteArray([data[9]], Int.self)
            welcomeMsg.minorA = ByteBuffer.fromByteArray([data[10]], Int.self)
            welcomeMsg.minorB = ByteBuffer.fromByteArray([data[11]], Int.self)
            
            let userInfo = [SensorConstans.SensorNotificationKeys.major: [welcomeMsg.majorA, welcomeMsg.majorB], SensorConstans.SensorNotificationKeys.minor: [welcomeMsg.minorA, welcomeMsg.minorB]]
            
            NotificationCenter.default.post(name: .checkSensorVersion, object: nil, userInfo: userInfo)
        }
        
        if data.count >= 17 {
            welcomeMsg.eventReferenceNumber = ByteBuffer.fromByteArray([data[12], data[13], data[14], data[15]], Int.self)
        }
        
        return welcomeMsg
    }
    
    func isNewMsg(number: Int) -> Bool {
        
        let eventReferenceNumber = welcomeMsg.eventReferenceNumber
        guard eventReferenceNumber > 0 && number > 0 else {
            return false
        }
        
        guard eventReferenceNumber - 1 < number  else {
            return false
        }
        return true
    }
    
    
//    func handleTimeSensorMsg(data: Data) {
//    }
//    
//    func handleStartTripMsg(data: Data, maneuverType: ManeuverType) {
//    }
//    
//    func handleEndTripMsg(data: Data, maneuverType: ManeuverType) {
//    }
//    
//    func handleVNumberMsg(data: Data) {
//    }
//    
//    func handleBlackBoxMsg(data: Data) {
//    }
//    
//    func handleManeuverMsg(data: Data, maneuverType: ManeuverType) {
//    }
//    
//    func getMessageType(data: Data) -> ManeuverType {
//        let checkSum = checkSumData([data[0]])
//        return ManeuverType(rawValue: Int(checkSum))!
//    }
    
    func createSafetyIncomingMessage(res : SafetyIncomingMessage) {
        LogHelper.logError(err: "sensor createSafetyIncomingMessage for: \(res.mManeuverType?.rawValue)")
        
        delegate?.sensorManeuverMsg(dataModel: res)
    }
    
    func createBlackBoxIncomingMsg(res: BlackBoxIncomingMsg) {
        //TODO: - fix for BaseFieldModel
        delegate?.sensorBlackBoxMsg(dataModel: res as! BaseFieldModel)
    }
}
