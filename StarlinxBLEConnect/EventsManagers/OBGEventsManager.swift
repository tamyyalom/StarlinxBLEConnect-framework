//
//  OBGEventsManager.swift
//  lynx
//
//  Created by user-new on 1/30/22.
//

import Foundation
import UIKit

class OBGEventsManager: BaseSensorEvents, SensorEventsProtocol {
   
    var sensorUtils = SensorUtils()
    var isSentNewMessage = false
    var messageCount = 0
    var startTripMessageCount = 0
    
    func dataFactory(data: Data) {
        
        guard data.count < 2 || sensorUtils.isCheckSum(data: data) else { return }
        
        let messageType = ByteBuffer.fromByteArray([data[0]], Int.self)
        let messageTypeEnum = CommunicationMessagesTypesEnum(rawValue: messageType)
        LogHelper.logError(err: "read tag message: \(messageTypeEnum.debugDescription)")

        if messageTypeEnum == .sensorWelcome {
            handleTimeSensorMsg(data: data)
        }
        messageCount += 1
        
        switch messageTypeEnum {
        case .invalidMessage: ()
        case .readDeviceVersionMessage: ()
        case .readDeviceSettingsMessage: ()
        case .saveDeviceSettingsMessage: ()
        case .setSettingsToDefaultValuesMessage: ()
        case .performResetToDeviceMessage: ()
        case .activateDebugModeMessage: ()
        case .readDeviceVersionMessageResponse: ()
        case .readDeviceSettingsMessageResponse: ()
        case .activateDebugModeMessageResponse: ()
        case .sensorConnectedEventMessage: ()
        case .sensorDisconnectEventMessage: ()
        case .newDataRecievedEventMessage: ()
        case .maneuverReportMessageType:
            handleManeuverMsg(data: data)
        case .accidentEventReportMessage:
            handleAccidentMsg(data: data)
        case .startTripEventReportMessageType:
            handleStartTripMsg(data: data)
        case .endTripEventReportMessageType:
            handleEndTripMsg(data: data)
        case .locationReportMessageType:
            handleLocationMsg(data: data)
        case .blackboxDataMessageType: ()
        case .blackboxDataWithGyroMessageType:
            print("blackboxDataWithGyroMessageType")
        case .successUpdatedSettingsInSensorEventMessage: ()
        case .errorUpdatedSettingsInSensorEventMessage: ()
        case .gpsDebugReportMessageType: ()
        case .accelerometerDebugReportEventMessage: ()
        case .accelerometerAndGyroDebugReportEventMessage: ()
        case .saveSettingsInSensorMessage: ()
        case .activateDebugModeInSensorMessage: ()
        case .sensorWelcome: ()
        case .none: ()
        case .sensorFindGPSMessage, .sensorLostGPSMessage: ()
        }
    }
    
    
    func handleTimeSensorMsg(data: Data) {
        let welcomeMsg = parserWelcomeMsgMessage(data: data, isObg: true)
        
        LogHelper.logError(err: "Sensor On")

        guard welcomeMsg.IsDriving == 1 else { return }
        
        LogHelper.logInfo(message: "isDriving")
        NotificationCenter.default.post(name: .loggerStart, object: nil)
    }
    
    func handleStartTripMsg(data: Data) {
        
        let globalFieldsModel = getEventGlobalFields(data: data)
        guard let dataModel = globalFieldsModel else { return }
        
        LogHelper.logError(err: "start trip date: \(dataModel.eventDateTime.toDate())")
        
        isLogger = !isNewMsg(number: dataModel.eventReferenceNumber)
        delegate?.sensorStartTrip(dataModel: dataModel, isLogger: isLogger)
        
        //check if log finished
        startTripMessageCount = messageCount
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
            if self.startTripMessageCount == self.messageCount && !self.isSentNewMessage {
                self.isSentNewMessage = true
                NotificationCenter.default.post(name: .loggerFinished, object: nil)
            }
        })
    }
    
    func handleEndTripMsg(data: Data) {
        let globalFieldsModel = getEventGlobalFields(data: data)
        let index = GlobalFieldsModel.globalMessageLength

        guard let dateModel = globalFieldsModel, data.count >= 5 else { return }
        
        let tripTotalDistance = ByteBuffer.fromByteArray([data[index], data[index + 1], data[index + 2], data[index + 3]], Int.self)
        let tripMaxSpeed = ByteBuffer.fromByteArray([data[index + 4]], Int.self)
        
        let endTripModel = EndTripModel(eventType: dateModel.eventType, eventReferenceNumber: dateModel.eventReferenceNumber, eventGPSData: dateModel.eventGPSData, eventDateTime: dateModel.eventDateTime, totalDistance: tripTotalDistance, maxSpeed: tripMaxSpeed)
        
        LogHelper.logError(err: "end trip date: \(endTripModel.eventDateTime.toDate())")

        delegate?.sensorEndTripMsg(dataModel: endTripModel)
    }
    
    func handleVNumberMsg(data: Data) {
        
    }
    
    func handleBlackBoxMsg(data: Data) {
        
    }
    
    func handleManeuverMsg(data: Data) {
        let globalFieldsModel = getEventGlobalFields(data: data)
        let index = GlobalFieldsModel.globalMessageLength
        
        guard let dataModel = globalFieldsModel, data.count >= index + 12 else { return }
        
        let messageType = ByteBuffer.fromByteArray([data[index]], Int.self)
        let messageTypeEnum = ManeuverType(rawValue: messageType, isOBG: true)
        guard messageTypeEnum != nil else { return }
        
        let level = ManeuverLevelEnum(rawValue:Int(data[index + 1])) ?? .NORMAL
        let timeStamp = Int((dataModel.eventDateTime.toDate()).timeIntervalSince1970)
        let totalTime = ByteBuffer.fromByteArray([data[index + 2], data[index + 3], data[index + 4], data[index + 5]], Int.self)
        let manuverHigestX = ByteBuffer.fromByteArray([data[index + 6], data[index + 7]], Int.self)
        let manuverHigestY = ByteBuffer.fromByteArray([data[index + 8], data[index + 9]], Int.self)
        let manuverHigestZ = ByteBuffer.fromByteArray([data[index + 10], data[index + 11]], Int.self)
        
        let safetyIncomingMessage = SafetyIncomingMessage(dataModel: dataModel, maneuverType: messageTypeEnum!, maneuverPowerEnum: level, timeStamp: timeStamp, totalTime: totalTime, manuverHigestX: manuverHigestX, manuverHigestY: manuverHigestY, manuverHigestZ: manuverHigestZ)
        
        isLogger = !isNewMsg(number: dataModel.eventReferenceNumber)
        createSafetyIncomingMessage(res: safetyIncomingMessage)
    }
    
    func handleLocationMsg(data: Data) {
        
        guard let globalFieldsModel = getEventGlobalFields(data: data) else { return }
        
        isLogger = !isNewMsg(number: globalFieldsModel.eventReferenceNumber)
        delegate?.sensorLocationMsg(dataModel: globalFieldsModel)
    }
    
    func handleAccidentMsg(data: Data) {
        let globalFieldsModel = getEventGlobalFields(data: data)
        let index = GlobalFieldsModel.globalMessageLength
        
        guard let dataModel = globalFieldsModel, data.count >= index + 7 else { return }
        
        let accidentType = ByteBuffer.fromByteArray([data[index]], Int.self)
        let highestOrLowestX = ByteBuffer.fromByteArray([data[index + 1], data[index + 2]], Int.self)
        let highestOrLowestY = ByteBuffer.fromByteArray([data[index + 3], data[index + 4]], Int.self)
        let highestOrLowestZ = ByteBuffer.fromByteArray([data[index + 5], data[index + 6]], Int.self)
        
        /*
         return new AccidentEvent(headerMsg, accidentType, highestOrLowestX, highestOrLowestY, highestOrLowestZ);
         */
    }
    
    func getMessageType(data: Data) -> ManeuverType {
        let checkSum = sensorUtils.checkSumData([data[0]])
        return ManeuverType(rawValue: Int(checkSum), isOBG: true)!
    }
    
    private func getBodyMsg(data: Data) -> Data {
        let bodyMessage = data[GlobalFieldsModel.globalMessageLength...]
        return bodyMessage
    }
    
    func getEventGlobalFields(data: Data) -> GlobalFieldsModel? {
        
        guard data.count >= GlobalFieldsModel.globalMessageLength else { return nil }
        
        let eventByte = ByteBuffer.fromByteArray([data[0]], Int.self)
        guard let eventType = CommunicationMessagesTypesEnum(rawValue: eventByte) else { return nil }
        
        let eventReferenceNumber = ByteBuffer.fromByteArray([data[1], data[2], data[3], data[4]], Int.self)
        let lat = ByteBuffer.fromByteArray([data[5], data[6], data[7], data[8]], Int.self)
        let lon = ByteBuffer.fromByteArray([data[9], data[10], data[11], data[12]], Int.self)
        let heading = ByteBuffer.fromByteArray([data[13], data[14]], Int.self)
        let speed = ByteBuffer.fromByteArray([data[15]], Int.self)
        
        let year = ByteBuffer.fromByteArray([data[16], data[17]], Int.self)
        let month =  ByteBuffer.fromByteArray([data[18]], Int.self)
        let day = ByteBuffer.fromByteArray([data[19]], Int.self)
        let hour = ByteBuffer.fromByteArray([data[20]], Int.self)
        let minutes = ByteBuffer.fromByteArray([data[21]], Int.self)
        let seconds = ByteBuffer.fromByteArray([data[22]], Int.self)
        
        let gpsData = GPSDataModel(lat: lat, lon: lon, heading: Double(heading), speed: speed)

        let timeModel = TimeStampModel(year: year, month: month, day: day, hour: hour, minutes: minutes, seconds: seconds)
        
        isLogger = !isNewMsg(number: eventReferenceNumber)
        if !isLogger && !isSentNewMessage {
            isSentNewMessage = true
            NotificationCenter.default.post(name: .loggerFinished, object: nil)
        }

        return GlobalFieldsModel(eventType: eventType, referenceNumber: eventReferenceNumber, gpsData: gpsData, gpsDateTime: timeModel)
    }
}
