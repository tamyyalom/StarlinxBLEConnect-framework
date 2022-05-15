//
//  EndTripModel.swift
//  lynx
//
//  Created by user-new on 2/7/22.
//

import Foundation

struct EndTripModel: BaseFieldModel {
    
    var eventType = CommunicationMessagesTypesEnum.invalidMessage
    var eventReferenceNumber = 0
    var eventGPSData: GPSDataModel
    var eventDateTime: TimeStampModel
    
    var totalDistance = 0
    var maxSpeed = 0
}
