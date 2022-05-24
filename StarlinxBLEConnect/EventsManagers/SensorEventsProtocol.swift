//
//  SensorEventsProtocol.swift
//  lynx
//
//  Created by user-new on 1/30/22.
//

import Foundation

protocol SensorEventsProtocol {
    func dataFactory(data: Data)
    func handleTimeSensorMsg(data: Data)
    func handleStartTripMsg(data: Data)
    func handleEndTripMsg(data: Data)
    func handleVNumberMsg(data: Data)
    func handleBlackBoxMsg(data: Data)
    func handleManeuverMsg(data: Data)
    func getMessageType(data: Data) -> ManeuverType
}

protocol SensorEventsDelegate {
    func sensorStartTrip(dataModel: BaseFieldModel, isLogger: Bool)
    func sensorEndTripMsg(dataModel: BaseFieldModel)
    func sensorVNumberMsg(dataModel: BaseFieldModel)
    func sensorBlackBoxMsg(dataModel: BaseFieldModel)
    func sensorManeuverMsg(dataModel: BaseFieldModel)
    func sensorLocationMsg(dataModel: BaseFieldModel)
}
