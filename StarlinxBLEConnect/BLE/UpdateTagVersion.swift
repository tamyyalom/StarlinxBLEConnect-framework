//
//  UpdateTagVersion.swift
//  lynx
//
//  Created by rivki glick on 15/06/2021.
//

import Foundation
import NordicDFU
import CoreBluetooth


public protocol UpdateTagVersionProtocol: AnyObject {
    
    func dfuStateDidChange(state: String)
    func dfuProgressDidChange(part: Int,totalParts: Int, to progress: Int)
}


public class UpdateTagVersion: DFUServiceDelegate, DFUProgressDelegate {

    private var dfuController: DFUServiceController!
    private weak var delegate: UpdateTagVersionProtocol?
    
    public class func loadFileSync(url: NSURL, completion:(_ path: String, _ error:NSError?) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent!)
        if FileManager().fileExists(atPath: destinationUrl!.path) {
            print("file already exists [\(destinationUrl?.path ?? "")]")
            completion(destinationUrl!.path, nil)
        } else if let dataFromURL = NSData(contentsOf: url as URL){
            if dataFromURL.write(to: destinationUrl!, atomically: true) {
                print("file saved [\(destinationUrl?.path ?? "")]")
                completion((destinationUrl?.path)!, nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl!.path, error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl!.path, error)
        }
    }

//    class func loadFileAsync(url: NSURL, completion:(_ path:String, _ error:NSError?) -> Void) {
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
//        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent!)
//        if FileManager().fileExists(atPath: destinationUrl?.path ?? "") {
//            print("file already exists [\(destinationUrl?.path ?? "")]")
//            completion(destinationUrl!.path, nil)
//        } else {
//            let sessionConfig = URLSessionConfiguration.default
//            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//            let request = NSMutableURLRequest(url: url as URL)
//            request.httpMethod = "GET"
//            let task = session.dataTaskWithRequest(request as URLRequest, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
//                if (error == nil) {
//                    if let response = response as? NSHTTPURLResponse {
//                        println("response=\(response)")
//                        if response.statusCode == 200 {
//                            if data.writeToURL(destinationUrl, atomically: true) {
//                                println("file saved [\(destinationUrl.path!)]")
//                                completion(path: destinationUrl.path!, error:error)
//                            } else {
//                                println("error saving file")
//                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
//                                completion(path: destinationUrl.path!, error:error)
//                            }
//                        }
//                    }
//                }
//                else {
//                    println("Failure: \(error.localizedDescription)");
//                    completion(path: destinationUrl.path!, error:error)
//                }
//            })
//            task.resume()
//        }
//    }
    
    
    public func updateTagVersion(url: String, peripheral: CBPeripheral, delegate: UpdateTagVersionProtocol) {
        
        self.delegate = delegate
        guard let firmware = DFUFirmware(urlToZipFile: URL(string: url)!) else {
            LogHelper.logError(err: "updata tag version: can not create Firmware")
            
//            callback(.failure(QuickError(message: "Can not create Firmware")))
            return
        }
        LogHelper.logDebug(message: "updata tag version: success")
        
        let initiator = DFUServiceInitiator().with(firmware: firmware)
        
        initiator.delegate = self
        initiator.progressDelegate = self
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        dfuController = initiator.start(target: peripheral)
    }
    
    // MARK: - DFUProgressDelegate
    
    public func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        LogHelper.logDebug(message: "dfuProgressDidChange")
        
//        delegate?.dfuProgressDidChange(part: part, totalParts: totalParts, to: progress)
    }
    
    public func dfuStateDidChange(to state: DFUState) {
        LogHelper.logDebug(message: "dfuProgressDidChange")

        if state == .completed {
            dfuController = nil
        }

        print(state.description())
//        delegate?.dfuStateDidChange(state: state.description())
    }
    
    public func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuController = nil
        LogHelper.logError(err: "dfuError")
    }
    
}
