//
//  ManeuverType.swift
//  lynx
//
//  Created by rivki glick on 03/02/2021.
//

import Foundation


enum ManeuverType: Int, CaseIterable, CustomStringConvertible, Codable {

    case accelerate = 1
    case breaking = 2
    case leftTurn = 3
    case rigthTurn = 4
    case wideLeftTurn = 5
    case wideRigthTurn = 6
    case leftTurnWhileBreaking = 7
    case leftTurnWhileSpeedingUp = 8
    case wideLeftTurnWhileBreaking = 9
    case wideLeftTurnWhileSpeedingUp = 10
    case rigthTurnWhileBreaking = 11
    case rigthTurnSpeedingUp = 12
    case wideRigthTurnWhileBreaking = 13
    case wideRigthTurnWhileSpeedingUp = 14
    case circle = 15
    
    case accident = 16
    case laneChange = 17
    case bypassing = 18
    case bumps = 19
    case offRoadDrivingStart = 20
    case offRoadDrivingEnd = 21

    case usePhone = 50
    case stillPhone = 51
    case callStateIdle = 52
    case callStateRinging = 53

    case accidentBlackBox = 55
    case startTrip = 56
    case endTrip = 57
    case sensorTimeSmart = 99
    case canvasVNumber = 100

    //1-21 Maneuver message

//    let descriptions = MyEnum.allCases.map { $0.description }
    static var messagesCases: [ManeuverType] {
        return [.accelerate, .breaking, .leftTurn, .rigthTurn, .wideLeftTurn, .wideRigthTurn, .leftTurnWhileBreaking, .leftTurnWhileSpeedingUp, .wideLeftTurnWhileBreaking, .wideLeftTurnWhileSpeedingUp, .rigthTurnWhileBreaking, .rigthTurnSpeedingUp, .wideRigthTurnWhileBreaking, .wideRigthTurnWhileSpeedingUp, .circle, .laneChange, .bypassing, .bumps, .offRoadDrivingStart, .offRoadDrivingEnd]
        }
    
    var index: Int {
        return rawValue
    }
    
    var description: String {
        return ""
    }
}
