//
//  UserOcrIdentityModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import SwiftyJSON

protocol OCRDataProtocol {
    var idCardNumber: String { get }
    var firstName: String { get }
    var middleName: String { get }
    var lastName: String { get }
    var gender: String { get }
    var birthday: String { get }
    var frontUrl: String { get }
    var backUrl: String { get }
    var isUpdate: Int { get }
}

struct UserOcrIdentityModel: DecodableData, OCRDataProtocol {
    let firstName: String           // foxPFFW8QXYt88
    let middleName: String          // tc4tNeoQMkLa
    let lastName: String            // tStWiy
    let birthday: String            // tR0Hfq39qFxtC
    let gender: String              // lDL1GdY
    let idCardNumber: String        // dzwMhwX
    
    // 图片资源信息
    let frontUrl: String      // dpc5406hX79ydBa2gjH
    let backUrl: String       // oK5ed9WV8K84D

    var isUpdate: Int = 0
    
    init(json: JSON) {
        // 定位到核心数据层 civiwTyRgTQyL
        let data = json["civiwTyRgTQyL"]
        isUpdate = data.isEmpty ? 0 : 1
        
        self.firstName = data["foxPFFW8QXYt88"].stringValue
        self.middleName = data["tc4tNeoQMkLa"].stringValue
        self.lastName = data["tStWiy"].stringValue
        self.birthday = data["tR0Hfq39qFxtC"].stringValue
        self.gender = data["lDL1GdY"].stringValue
        self.idCardNumber = data["dzwMhwX"].stringValue
        
        self.frontUrl = data["dpc5406hX79ydBa2gjH"].stringValue
        self.backUrl = data["oK5ed9WV8K84D"].stringValue
    }
}


// 客户OCR校验
struct CustomerOCRResultModel: DecodableData, OCRDataProtocol {
    var isUpdate: Int
    
    var firstName: String
    var middleName: String
    var lastName: String
    
    let idCardNumber: String        // dzwMhwX (身份证号)
    
    let gender: String              // lDL1GdY
    let birthday: String            // tR0Hfq39qFxtC
    let type: String                // mgkeUyzUHHGmht
    let isSuccess: Bool             // adDxbiUVC5jNoa3muba1
    let frontUrl: String            // yIax4fl_5TVRbR78LPWC (正面照 URL)
    let backUrl: String             // teDPHZBnu_7zZVrk8v (背面照 URL)
    
    let documentNumber: String      // kgkoMvcxP7ukB8Xa (证件号)
    
    init(json: JSON) {
        isUpdate = 0
        // 映射混淆的后端 Key
        self.firstName = json["pUHPZyYRkT0hyzzjSi"].stringValue
        self.middleName = json["n9Mrj"].stringValue
        self.lastName = json["oBSX33x8DOeJnWBTNP"].stringValue
        
        self.idCardNumber = json["dzwMhwX"].stringValue
        self.documentNumber = json["kgkoMvcxP7ukB8Xa"].stringValue
        self.gender = json["lDL1GdY"].stringValue
        self.birthday = json["tR0Hfq39qFxtC"].stringValue
        self.type = json["mgkeUyzUHHGmht"].stringValue
        
        // 注意：有些字段可能是 Bool 或 Int，根据实际后端返回调整
        self.isSuccess = json["adDxbiUVC5jNoa3muba1"].boolValue
        
        self.frontUrl = json["yIax4fl_5TVRbR78LPWC"].stringValue
        self.backUrl = json["teDPHZBnu_7zZVrk8v"].stringValue
    }
}
