//
//  TagManagerProtocol.swift
//  lynx
//
//  Created by user-new on 9/2/21.
//

import Foundation
import CoreBluetooth

public protocol TagManagerProtocol:AnyObject {
    
    func didChangeStatus(state: CBPeripheralState, deviceId: String)
    func didDisconnect()
    func readTagValue(data: Data)
    func dfuStateDidChange(state: String)
    func dfuProgressDidChange(part: Int,totalParts: Int, to progress: Int)
}

