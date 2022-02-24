//
//  ManeuverLevel.swift
//  lynx
//
//  Created by rivki glick on 04/02/2021.
//

import Foundation
import UIKit

enum ManeuverLevelEnum : Int, CaseIterable, Codable {
    case NORMAL = 1
    case AGGRESSIVE
    case DNAGEROUS
    
    var levelColor: UIColor {
        return UIColor.green
    }
}
