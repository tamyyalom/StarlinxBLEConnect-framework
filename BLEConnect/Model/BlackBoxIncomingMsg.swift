//
//  BlackBoxIncomingMsg.swift
//  lynx
//
//  Created by rivki glick on 09/02/2021.
//

import UIKit

struct BlackBoxIncomingMsg {
    
    var mManeuverType = ManeuverType(rawValue: 0)
    var timeStamp = 0
    var msgLength = 0
    var blackBoxPointList = [BlackBoxPoint]()
    var mDiffTimeSensorConnectedSec = 0
}

struct BlackBoxPoint {
    
    var mManuverHigestX = 0
    var mManuverHigestY = 0
    var mManuverHigestZ = 0
}
