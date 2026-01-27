//
//  LoanConfirmModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import SwiftyJSON
import Foundation

struct LoanConfirmModel: DecodableData {    
    var firstConfirm: Bool
    
    init(json: JSON) {
        self.firstConfirm = json["axwwwDR2OQvCZc9lrDK"].boolValue
        
    }
}
