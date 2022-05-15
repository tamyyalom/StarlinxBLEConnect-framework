//
//  SafetyIncomingMessageModel.swift
//  lynx
//
//  Created by rivki glick on 04/02/2021.
//

import Foundation

struct SafetyIncomingMessage: BaseFieldModel {
    
    var eventType = CommunicationMessagesTypesEnum.invalidMessage
    var eventReferenceNumber = 0
    var eventGPSData: GPSDataModel
    var eventDateTime: TimeStampModel
    
    var mManeuverType = ManeuverType(rawValue: 0)
    var mManeuverPowerEnum = ManeuverLevelEnum(rawValue: 1)
    var mTimeStamp = 0
    var mTotalTime = 0
    var mManuverHigestX = 0
    var mManuverHigestY = 0
    var mManuverHigestZ = 0

    
    init(dataModel: GlobalFieldsModel? = nil, maneuverType: ManeuverType, maneuverPowerEnum: ManeuverLevelEnum, timeStamp: Int, totalTime: Int, manuverHigestX: Int, manuverHigestY: Int, manuverHigestZ: Int) {
        
        if let dataModel = dataModel {
            eventType = dataModel.eventType
            eventReferenceNumber = dataModel.eventReferenceNumber
            eventGPSData = dataModel.eventGPSData
            eventDateTime = dataModel.eventDateTime
        } else {
            eventType = CommunicationMessagesTypesEnum.invalidMessage
            eventReferenceNumber = 0
            eventGPSData = GPSDataModel(lat: 0, lon: 0, heading: 0, speed: 0)
            eventDateTime = TimeStampModel()
        }
        mManeuverType = maneuverType
        mManeuverPowerEnum = maneuverPowerEnum
        mTimeStamp = timeStamp
        mTotalTime = totalTime
        mManuverHigestX = manuverHigestX
        mManuverHigestY = manuverHigestY
        mManuverHigestZ = manuverHigestZ
    }
}

