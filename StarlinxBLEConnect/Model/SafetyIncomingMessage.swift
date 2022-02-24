//
//  SafetyIncomingMessageModel.swift
//  lynx
//
//  Created by rivki glick on 04/02/2021.
//

import Foundation

struct SafetyIncomingMessage {
    
    var mManeuverType = ManeuverType(rawValue: 0)
    var mManeuverPowerEnum = ManeuverLevelEnum(rawValue: 1)
    var mTimeStamp = 0
    var mTotalTime = 0
    var mManuverHigestX = 0
    var mManuverHigestY = 0
    var mManuverHigestZ = 0
}

