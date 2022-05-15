//
//  CommunicationMessagesTypesEnum.swift
//  lynx
//
//  Created by user-new on 2/2/22.
//

import Foundation

enum CommunicationMessagesTypesEnum: Int {
    
    case invalidMessage = 0
    case readDeviceVersionMessage = 1
    case readDeviceSettingsMessage = 2
    case saveDeviceSettingsMessage = 3
    case setSettingsToDefaultValuesMessage = 4
    case performResetToDeviceMessage = 5
    case activateDebugModeMessage = 6
    
    case readDeviceVersionMessageResponse = 10
    case readDeviceSettingsMessageResponse = 11
    case activateDebugModeMessageResponse = 12
    
    case sensorConnectedEventMessage = 20
    case sensorDisconnectEventMessage = 21
    case newDataRecievedEventMessage = 22
    case maneuverReportMessageType = 23
    case accidentEventReportMessage = 24
    case startTripEventReportMessageType = 25
    case endTripEventReportMessageType = 26
    case locationReportMessageType = 27
    case blackboxDataMessageType = 28
    case blackboxDataWithGyroMessageType = 29
    case successUpdatedSettingsInSensorEventMessage = 30
    case errorUpdatedSettingsInSensorEventMessage = 31
    case gpsDebugReportMessageType = 32
    case accelerometerDebugReportEventMessage = 33
    case accelerometerAndGyroDebugReportEventMessage = 34

    case saveSettingsInSensorMessage = 55
    case activateDebugModeInSensorMessage = 56
    case sensorFindGPSMessage = 77
    case sensorLostGPSMessage = 88
    case sensorWelcome = 99
}
