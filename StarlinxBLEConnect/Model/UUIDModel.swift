//
//  UUIDModel.swift
//  lynx
//
//  Created by user-new on 2/23/22.
//

import Foundation

public struct UUIDModel {
    var serviceId = ""
    var characteristics = ""
    var deviceId = ""
    
    func getServiceKeyWithDevice() -> String {
        return serviceId + String(deviceId.suffix(12))
    }
    
    func getCharacteristicsKeyWithDevice() -> String {
        return characteristics + String(deviceId.suffix(12))
    }
}
