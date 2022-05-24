//
//  SensonUtils.swift
//  lynx
//
//  Created by user-new on 2/2/22.
//

import Foundation

struct SensorUtils {
    
    func isCheckSum(data: Data) -> Bool {
        if data.count < 2 {
            return false
        }
        var values = [UInt8]()
        
        var i = 0
        
        for num in data {
            if i < (data.count - 1) {
                i = i + 1
                values.append((num as UInt8))
            }
        }
        let checkSum = checkSumData(values)
        
        return (checkSum == data[data.count - 1])
    }
    
    func checkSumData(_ values: [UInt8]) -> UInt8 {
        let result = values.reduce(0) { ($0 + UInt32($1)) & 0xff }
        return UInt8(result)
    }
}
