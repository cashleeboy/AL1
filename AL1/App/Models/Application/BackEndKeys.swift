//
//  BackEndKeys.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import Foundation

struct BackendUserPersonalInfoKeys {
    // 顶级节点
    static let personalInfoNode = "erdFQn7J0XH_"
    
    // 字段 Key
    static let education = "cflUfqx0Hm5rdCF5t2i"
    static let address = "t521iItdEA0qUD"
    static let homeCity = "qi4Ljjf3mE4"
    static let homeProvince = "t521iItdEA0qUD"
    static let maritalStatus = "h5ZwoWwxNU3pQhh"
    static let income = "bDLSxT_"
    static let jobType = "gom2DQegrfwHx"
    static let email = "f_ocsz"
}

struct BackendUserContactKeys {
    static let contactNode = "kpYQyyzvbe0Zaq"
    
    //  联系人姓名,示例值(contactName)
    static let contactName = "bGuOvX4"
    // 联系人手机号
    static let contactPhoneNumber = "p3nOi4vepcURroO"
    // 联系人关系 1-配偶 2-父亲 3-母亲 4-子女 5-兄弟 6-姐妹,示例值(contactRelationship)
    static let contactRelationship = "kX_zmVzAOAfx"
    static let catactId = "wGlVByadhXXG4SRrlX" // 联系人id,更新传递,示例值(id)
}

struct BackendUserBankInfoKeys {
    static let bankInfoNode = "aoAs1UcI"
    
    // 银行账户类型
    static let bankAccountCCI = "lVAVr1YrRdMw3DZ"
    static let bankAccountNo = "gpNuFV3nMla"
    static let bankAccountType = "sB29fpnkHEfSxCczPUu"
    static let bankId = "hvTDGT8j9GQ8JjT"
    static let bankName = "y0_BW"
}

struct AddBankBackendUserKeys {
    static let bankAccountType = "aoymw_Oc1g9nxw9PZw"
    static let bankCardNo = "s_0ioeu"
    
}

struct BackendORCKeys {
    // Nombre
    static let name = "foxPFFW8QXYt88"
    // apellido paterno
    static let fatherName = "tStWiy"
    // apellido materno
    static let motherName = "tc4tNeoQMkLa"
    // Genero
    // 性别 1-男性 2-女性,示例值(gender)
    static let gender = "lDL1GdY"
    // NUI Number
    static let nuiNumber = "dzwMhwX"
    // Fecha de nacimiento
    static let birthDay = "tR0Hfq39qFxtC"
    static let fromUrl = "dpc5406hX79ydBa2gjH"
}
