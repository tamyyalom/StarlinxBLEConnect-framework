//
//  ManeuverType.swift
//  lynx
//
//  Created by rivki glick on 03/02/2021.
//

import Foundation


enum ManeuverType: Int, CaseIterable, CustomStringConvertible, Codable, RawRepresentable {

    case accelerate
    case breaking
    case leftTurn
    case rigthTurn
    case wideLeftTurn
    case wideRigthTurn
    case leftTurnWhileBreaking
    case leftTurnWhileSpeedingUp
    case wideLeftTurnWhileBreaking
    case wideLeftTurnWhileSpeedingUp
    case rigthTurnWhileBreaking
    case rigthTurnSpeedingUp
    case wideRigthTurnWhileBreaking
    case wideRigthTurnWhileSpeedingUp
    case circle
    
    case accident
    case laneChange
    case bypassing
    case bumps
    case offRoadDrivingStart
    case offRoadDrivingEnd
    case carFlipped

    case phoneUnlock
    case phoneLock
    case screenOn
    case screenOff
    case usePhone
    case stillPhone
    case callStateIdle
    case callStateRinging

    case accidentBlackBox
    case startTrip
    case endTrip
    case sensorTimeSmart
    case canvasVNumber
    
    //1-21 Maneuver message
    init?(rawValue: Int, isOBG: Bool) {
        switch rawValue {
        case 1: self = .accelerate
        case 2: self = .breaking
        case 3: self = .leftTurn
        case 4: self = .rigthTurn
        case 5: self = .wideLeftTurn
        case 6: self = .wideRigthTurn
        case 7: self = .leftTurnWhileBreaking
        case 8: self = .leftTurnWhileSpeedingUp
        case 9: self = .wideLeftTurnWhileBreaking
        case 10: self = .wideLeftTurnWhileSpeedingUp
        case 11: self = .rigthTurnWhileBreaking
        case 12: self = .rigthTurnSpeedingUp
        case 13: self = .wideRigthTurnWhileBreaking
        case 14: self = .wideRigthTurnWhileSpeedingUp
        case 15: self = .circle
        case 16:
            if isOBG {
                self = .bumps
            } else {
                self = .accident
            }
        case 17: self = .laneChange
        case 18: self = .bypassing
        case 19: self = .bumps
        case 20:
            if isOBG {
                self = .accident
            } else {
                self = .offRoadDrivingStart
            }
        case 21:
            if isOBG {
                self = .carFlipped
            } else {
                self = .offRoadDrivingEnd
            }
        case 46: self = .phoneUnlock
        case 47: self = .phoneLock
        case 48: self = .screenOn
        case 49: self = .screenOff
        case 50: self = .usePhone
        case 51: self = .stillPhone
        case 52: self = .callStateIdle
        case 53: self = .callStateRinging
        case 55: self = .accidentBlackBox
        case 56: self = .startTrip
        case 57: self = .endTrip
        case 99: self = .sensorTimeSmart
        case 100: self = .canvasVNumber
            
        default:
            return nil
        }
    }
    

//    let descriptions = MyEnum.allCases.map { $0.description }
    static var messagesCases: [ManeuverType] {
        return [.accelerate, .breaking, .leftTurn, .rigthTurn, .wideLeftTurn, .wideRigthTurn, .leftTurnWhileBreaking, .leftTurnWhileSpeedingUp, .wideLeftTurnWhileBreaking, .wideLeftTurnWhileSpeedingUp, .rigthTurnWhileBreaking, .rigthTurnSpeedingUp, .wideRigthTurnWhileBreaking, .wideRigthTurnWhileSpeedingUp, .circle, .laneChange, .bypassing, .bumps, .offRoadDrivingStart, .offRoadDrivingEnd]
        }
    
    var index: Int {
        return rawValue
    }
    
    var serverValue: Int {
        switch self {
        case .accelerate:
            return 1
        case .breaking:
            return 2
        case .leftTurn:
            return 3
        case .rigthTurn:
            return 4
        case .wideLeftTurn:
            return 5
        case .wideRigthTurn:
            return 6
        case .leftTurnWhileBreaking:
            return 7
        case .leftTurnWhileSpeedingUp:
            return 8
        case .wideLeftTurnWhileBreaking:
            return 9
        case .wideLeftTurnWhileSpeedingUp:
            return 10
        case .rigthTurnWhileBreaking:
            return 11
        case .rigthTurnSpeedingUp:
            return 12
        case .wideRigthTurnWhileBreaking:
            return 13
        case .wideRigthTurnWhileSpeedingUp:
            return 14
        case .circle:
            return 15
        case .laneChange:
            return 16
        case .bypassing:
            return 17
        case .bumps:
            return 18
        case .offRoadDrivingStart:
            return 19
        case .offRoadDrivingEnd:
            return 20
        default:
            return 0
        }
    }
}

