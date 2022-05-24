//
//  TagEventsManager.swift
//  lynx
//
//  Created by user-new on 9/30/21.
//

import Foundation

class TagEventsManager: BaseSensorEvents, SensorEventsProtocol {
    
    var sensorUtils = SensorUtils()
    
    func dataFactory(data: Data) {
        let maneuverType = getMessageType(data: data)
        LogHelper.logDebug(message: "get maneuver: \(maneuverType.rawValue)")

        if maneuverType == .sensorTimeSmart {
            handleTimeSensorMsg(data: data)
        } else if maneuverType == .startTrip {
            handleStartTripMsg(data: data)
        } else if maneuverType == .endTrip {
            handleEndTripMsg(data: data)
        } else if maneuverType == .canvasVNumber {
            handleVNumberMsg(data: data)
        } else if maneuverType == .accidentBlackBox {
            handleBlackBoxMsg(data: data)
        } else {
            handleManeuverMsg(data: data)
        }
    }
    
    func handleTimeSensorMsg(data: Data) {
        let welcomeMsg = parserWelcomeMsgMessage(data: data, isObg: false)
        guard welcomeMsg.IsDriving == 1 else { return }
        
        LogHelper.logInfo(message: "isDriving")
        LogHelper.logError(err: "TagManager Tag On")
    }
    
    func handleStartTripMsg(data: Data) {
        if let safetyIncomingMessage = parserManeuverMessage(data: data) {
            delegate?.sensorStartTrip(dataModel: safetyIncomingMessage, isLogger: false)
        }
        LogHelper.logError(err: "START_TRIP")
    }
    
    func handleEndTripMsg(data: Data) {
        if let safetyIncomingMessage = parserManeuverMessage(data: data) {
            delegate?.sensorEndTripMsg(dataModel: safetyIncomingMessage)
        }
    }
    
    func handleVNumberMsg(data: Data) {
        if data.count >= 19 {
            print("parserVNumberMessage")
        }
      //TODO: save in user defualt like android?
    }
    
    func handleBlackBoxMsg(data: Data) {
        //TODO: not finish develop in server
//        let blackBoxIncomingMsg = parserBlackBoxMessage(data: data)
//      createBlackBoxIncomingMsg(res: blackBoxIncomingMsg)
    }
    
    func handleManeuverMsg(data: Data) {
        guard let safetyIncomingMessage = parserManeuverMessage(data: data) else { return }
        
        let connectToTagDate = (UserDefaults.standard.value(forKey: SensorConstans.SensorDefaultsKeys.connectToTagDate) as! Date)
        if safetyIncomingMessage.mTimeStamp >=  Int(connectToTagDate.timeIntervalSince1970) {
            createSafetyIncomingMessage(res: safetyIncomingMessage)
            LogHelper.logInfo(message: "parserManeuverMessage")
        } else {
            print("get message before!@!@!@!@")
        }
    }
    
    func getMessageType(data: Data) -> ManeuverType {
        let checkSum = sensorUtils.checkSumData([data[0]])
        return ManeuverType(rawValue: Int(checkSum), isOBG: false)!
    }
    
    func parserManeuverMessage(data: Data) -> SafetyIncomingMessage? {
                
        guard data.count >= 15 else { return nil }
        
        LogHelper.logDebug(message: "parserManeuverMessage:")
        
        var index = 1
        let messageType = getMessageType(data: data)
        
        let messageTimeStamp = ByteBuffer.fromByteArray([data[index],data[index + 1],data[index + 2],data[index + 3]], Int.self)
        let mDiffTimeSensorConnectedSec = welcomeMsg.time +  messageTimeStamp
        
        index = index + 4
        let messageTotalTime = ByteBuffer.fromByteArray([data[index], data[index + 1]], Int.self)
        
        index = index + 2
        
        if data[index] == 0 {
            print(data[index])
        }
        
        let level = ManeuverLevelEnum(rawValue:Int(data[index])) ?? .NORMAL
        
        index = index + 1
                
        let messageManuverHigestX = ByteBuffer.fromByteArray([data[index], data[index + 1]], Int.self)
        
        index = index + 2
        let messageManuverHigestY = ByteBuffer.fromByteArray([data[index], data[index + 1]], Int.self)
        
        index = index + 2
        let messageManuverHigestZ = ByteBuffer.fromByteArray([data[index], data[index + 1]], Int.self)

        return SafetyIncomingMessage(maneuverType: messageType, maneuverPowerEnum: level, timeStamp: mDiffTimeSensorConnectedSec, totalTime: messageTotalTime, manuverHigestX: messageManuverHigestX, manuverHigestY: messageManuverHigestY, manuverHigestZ: messageManuverHigestZ)
    }
    
    func parserBlackBoxMessage(data: Data) -> BlackBoxIncomingMsg {
        var blackBoxIncomingMsg = BlackBoxIncomingMsg()
        
        guard data.count >= 10 else { return blackBoxIncomingMsg }
        
        LogHelper.logDebug(message: "parserBlackBoxMessage")
        
        var index = 0
        
        blackBoxIncomingMsg.mManeuverType = .accidentBlackBox
        index = index + 1
        
        let messageTimeStamp =  Int(ByteBuffer.fromByteArray([data[index], data[index + 1], data[index + 2], data[index + 3]], Int.self))
        let mDiffTimeSensorConnectedSec = welcomeMsg.time + messageTimeStamp
        let epochTime = TimeInterval(mDiffTimeSensorConnectedSec)
        let date1 = Date(timeIntervalSince1970: epochTime)
        let currentTime1 = UInt64(date1.timeIntervalSince1970)
        blackBoxIncomingMsg.timeStamp = Int(currentTime1)
        index = index + 4
        
        blackBoxIncomingMsg.msgLength = Int(data[index])
        let msgLength = Int(data[index])
        index = index + 1
        
        for _ in 0..<msgLength
        {
            if (index + 5) < (data.count - 1) {
                
                var blackBoxPoint = BlackBoxPoint()
                
                let x = ByteBuffer.fromByteArray([data[index],data[index + 1]], Int.self)
                blackBoxPoint.mManuverHigestX = x
                index = index + 2
                
                let y = ByteBuffer.fromByteArray([data[index],data[index + 1]], Int.self)
                blackBoxPoint.mManuverHigestY = y
                index = index + 2
                
                let z = ByteBuffer.fromByteArray([data[index],data[index + 1]], Int.self)
                blackBoxPoint.mManuverHigestZ = z
                index = index + 2
                
                blackBoxIncomingMsg.blackBoxPointList.append(blackBoxPoint)
            }
        }
        return blackBoxIncomingMsg
    }
}


class ByteBuffer {
    static func fromByteArray<T>(_ array: [UInt8], _: T.Type) -> T {
        //    let array : [UInt8] =  [0,1,109,26]; // tu array of bytes
        var value : Int = 0;
        for byte in array {
            value = value << 8;
            value = value | Int(byte);
        }
        return value as! T
    }
}
