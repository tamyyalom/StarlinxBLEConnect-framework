//
//  ConnectToTag.swift
//  lynx
//
//  Created by rivki glick on 14/12/2020.
//

import UIKit
import CoreBluetooth

public class BLEConnectedManager: NSObject, UIPopoverPresentationControllerDelegate, CBPeripheralDelegate, UpdateTagVersionProtocol {
    
    private var centralManager: CBCentralManager!
    public var connected = false
    
    public weak var delegate: BLEConnectedDelegate?
    
    private var peripheralP: CBPeripheral!
    private var UUIDService = [CBUUID]()
    private var UUIDCharacteristics = [CBUUID]()
    var peripheral: DiscoveredPeripheral!
    private var discoveredPeripherals = [DiscoveredPeripheral]()
    private var filteredPeripherals = [DiscoveredPeripheral]()
    private var updateTagVersion = UpdateTagVersion()
    
    var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    let reconnectInterval = 15 // seconds
    var timerForScanning: Timer?
    var reconnectCount = 0
    
    public func start(uuidModels: [UUIDModel], lastConnectedSensor: UUIDModel, completionHandler: @escaping (_ succes: Bool, _ message: String) -> Void) {
        
        centralManager = CBCentralManager(delegate: self, queue: nil/*, options: [CBCentralManagerOptionRestoreIdentifierKey: lastConnectedSensor.getServiceKeyWithDevice()]*/)

        initialServices(uuidModels: uuidModels)
        
        let permission = checkPermission()
        if permission == .allowedAlways {
            completionHandler(true, "")
        } else {
            var message = String()
            
            switch permission  {
                case .notDetermined:
                    message = "Bluetooth is not Determined"
                case .restricted:
                    message = "Bluetooth state is restricted"
                case .denied:
                    message = "Bluetooth is denied"
                default:()
            }
            LogHelper.logError(err: message)
            completionHandler(false, message)
        }
    }
    
    private func initialServices(uuidModels: [UUIDModel]) {
        UUIDService.removeAll()
        UUIDCharacteristics.removeAll()
        
        for uuidModel in uuidModels {
            UUIDService.append(CBUUID(string: uuidModel.getServiceKeyWithDevice()))
            UUIDCharacteristics.append(CBUUID(string: uuidModel.getCharacteristicsKeyWithDevice()))
        }
        LogHelper.logError(err: "UUIDService: \(UUIDService)")
        print(UUIDService)
    }
    
    public func updateTagVersion(url: String) {
        updateTagVersion.updateTagVersion(url: url, peripheral: peripheralP, delegate: self)
    }
    
    
    func checkPermission() -> CBManagerAuthorization {
        CBCentralManager.authorization
    }
    
    public func isConnected() -> Bool {
        return connected
    }
    
    private func tryReconnect(_ central: CBCentralManager, to peripheral: CBPeripheral) {
        reconnectCount += 1
        LogHelper.logError(err: "try Reconnect!!!!")
        DispatchQueue.main.async { // while in background mode Timer would work only being in main queue
            self.backgroundTaskId = UIApplication.shared.beginBackgroundTask (withName: "reconnectAgain") {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
                self.backgroundTaskId = .invalid
            }
            
            self.timerForScanning?.invalidate()
            self.timerForScanning = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.reconnectInterval), repeats: false) { _ in
//                if CurrentTripManager.shared.getCurrentTrip() == nil {
//                    //TODO: - check this!
//                    let arrayOfServices: [CBUUID] = [McuMgrBleTransport.SMP_SERVICE]
//                    self.centralManager.scanForPeripherals(withServices: arrayOfServices, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
//                } else {
                    central.connect(peripheral, options: [:])
//                }
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
                self.backgroundTaskId = .invalid
            }
        }
    }
    
    public func stopLookingForTag() {
        if centralManager != nil {
            centralManager = nil
            backgroundTaskId = .invalid
            timerForScanning?.invalidate()
            timerForScanning = nil
            delegate?.didChangeStatus(state: .disconnected, deviceId: "")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        // Get peripheral's services.
        guard let services = peripheral.services else {
            return
        }
        // Find the service matching the SMP service UUID.
        for service in services {
            let index = UUIDService.firstIndex(of: service.uuid)
            guard let index = index else {
                continue
            }
            
            peripheral.discoverCharacteristics([UUIDCharacteristics[index]], for: service)
            return
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        guard error == nil else { return }
        
        // Get service's characteristics.
        guard let characteristics = service.characteristics else { return }
        
        // Find the characteristic matching the SMP characteristic UUID.
        for characteristic in characteristics {
            
            guard let index = UUIDCharacteristics.firstIndex(of: characteristic.uuid) else {
                continue
            }
            
            if ((characteristic.properties.contains(.notify))) {
                peripheral.setNotifyValue(true, for: characteristic)
                //Do your Write here
            }
            if characteristic.properties.contains(.write) {
                peripheral.writeValue(Data([1]), for: characteristic, type: .withResponse)
                
                let deviceId = String(UUIDCharacteristics[index].uuidString.suffix(12))
                sensorConnected(deviceId: deviceId)
            }
            return
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic,
                           error: Error?) {
        
        guard error == nil else { return }

        guard let index = UUIDCharacteristics.firstIndex(of: characteristic.uuid) else {
            return
        }

        let deviceId = String(UUIDCharacteristics[index].uuidString.suffix(12))
        sensorConnected(deviceId: deviceId)
        
    }
    
    public func dfuStateDidChange(state: String) {
        delegate?.dfuStateDidChange(state: state)
    }
    
    public func dfuProgressDidChange(part: Int,totalParts: Int, to progress: Int) {
        delegate?.dfuProgressDidChange(part: part, totalParts: totalParts, to: progress)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else { return }

        guard (UUIDCharacteristics.firstIndex(of: characteristic.uuid) != nil) else {
            return
        }
        
        guard let data = characteristic.value else { return }
        
        delegate?.readTagValue(data: data)
        print("readTagValue: \(data)")
    }
    
    func sensorConnected(deviceId: String) {
        connected = true
        reconnectCount = 0
        
        UserDefaults.standard.setValue(Date(), forKey: SensorConstans.SensorDefaultsKeys.connectToTagDate)
        delegate?.didChangeStatus(state: .connected, deviceId: deviceId)
    }
}

extension BLEConnectedManager: CBCentralManagerDelegate {
    
    
    // MARK: - CBCentralManagerDelegate
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Find peripheral among already discovered ones, or create a new object if it is a new one.
        
        var discoveredPeripheral = discoveredPeripherals.first(where: { $0.basePeripheral.identifier == peripheral.identifier })
        
        discoveredPeripheral = DiscoveredPeripheral(peripheral)
        guard !discoveredPeripherals.contains(discoveredPeripheral!) else { return }
        
        discoveredPeripherals.append(discoveredPeripheral!)
        self.peripheral = discoveredPeripheral
        print(peripheral)
        peripheralP = peripheral
        
        central.connect(peripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            guard peripherals.count > 0 else { return }
            LogHelper.logDebug(message: "Peripheral found")
            
            let peripheral = peripherals[0]
            let discoveredPeripheral = DiscoveredPeripheral(peripheral)
            discoveredPeripherals.append(discoveredPeripheral)
            self.peripheral = discoveredPeripheral
            peripheral.delegate = self
            
            if self.peripheral.basePeripheral.state == .connected {
                centralManager.stopScan()
                
                let deviceId = String(self.peripheral.basePeripheral.identifier.uuidString.suffix(12))
                sensorConnected(deviceId: deviceId)
                
                peripheral.discoverServices(UUIDService)
                central.connect(peripheral, options: nil)
            }
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print(peripheral)
        centralManager.stopScan()
        
        let deviceId = String(peripheral.identifier.uuidString.suffix(12))
        delegate?.didChangeStatus(state: .connecting, deviceId: deviceId)
        peripheral.delegate = self
        peripheral.discoverServices(UUIDService)
    }
    
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error:Error?) {
        
        LogHelper.logError(err: "peripheral didFailToConnect")
        connected = false
        let deviceId = String(peripheral.identifier.uuidString.suffix(12))
        delegate?.didChangeStatus(state: .disconnected, deviceId: deviceId)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogHelper.logError(err: "peripheral didDisconnectPeripheral")
        
        guard let cbError = error as? CBError else { return }
        
        print(cbError.localizedDescription)
        LogHelper.logError(err: "\(cbError.localizedDescription)!!!!!!!!!!")
        
        if cbError.code == .peripheralDisconnected || cbError.code == .connectionTimeout {
            centralManager = nil
        }
        
        let deviceId = String(peripheral.identifier.uuidString.suffix(12))
        connected = false
        delegate?.didDisconnect()
        delegate?.didChangeStatus(state: .disconnected, deviceId: deviceId)
        
//        if UIApplication.shared.applicationState == .background && reconnectCount < 4 {
//            self.tryReconnect(central, to: peripheral)
//        } else {
            var discoveredPeripheral = discoveredPeripherals.first(where: { $0.basePeripheral.identifier == peripheral.identifier })
            if discoveredPeripheral == nil {
                discoveredPeripheral = DiscoveredPeripheral(peripheral)
                discoveredPeripherals.append(discoveredPeripheral!)
                self.peripheral = discoveredPeripheral
            }
//        }
    }
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state != .poweredOn {
            LogHelper.logError(err: "Central is not powered on")
            if isConnected() {
                connected = false
                delegate?.didDisconnect()
                delegate?.didChangeStatus(state: .disconnected, deviceId: "")
            }
        } else if checkPermission() == .allowedAlways {
            
            centralManager.scanForPeripherals(withServices: UUIDService, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
}
