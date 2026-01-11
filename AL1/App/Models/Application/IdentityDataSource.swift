//
//  IdentityDataSource.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import Foundation

enum IdentityFieldType {
    case choose
    case address
    case contact
    case bankName
    case bankNumber
    case gender
    case birth
    case write
    case enter
    case email
    
    var holderName: String {
        switch self {
        case .choose, .address, .contact, .birth, .bankName:
            "Por favor elija"
        case .write:
            "Por favor escriba" //write
        case .enter:
            "Por favor ingrese" //enter
        case .bankNumber:
            "Por favor ingrese su propia cuenta bancaria"
        case .email:
            "Por favor ingrese la dirección de correo electrónico correcta"
        default:
            ""
        }
    }
    
    /// 是否属于“输入类”字段（需要弹出键盘）
    var isKeyboardInput: Bool {
        switch self {
        case .write, .email, .enter, .bankNumber:
            return true
        default:
            return false
        }
    }
    
    var isInputRightView: Bool {
        switch self {
        case .choose, .contact:
            return true
        default:
            return false
        }
    }
}

struct IdentityDataSource {
    static let education = [
        IdentityOption(key: 1, value: "Nada"),
        IdentityOption(key: 2, value: "Escuela Primaria"),
        IdentityOption(key: 3, value: "Escuela secundaria"),
        IdentityOption(key: 4, value: "Cursos de certificación/vocational"),
        IdentityOption(key: 5, value: "Licenciatura"),
        IdentityOption(key: 6, value: "Maestría/Doctorado"),
        IdentityOption(key: 7, value: "Doctorado")
    ]
    
    static let maritalStatus = [
        IdentityOption(key: 1, value: "Soltero/a"),
        IdentityOption(key: 2, value: "Casado/a"),
        IdentityOption(key: 3, value: "Divorciado/a; Separado/a"),
        IdentityOption(key: 4, value: "Viudo/a")
    ]
    
    static let jobType = [
        IdentityOption(key: 1, value: "Trabajador de BPO"),
        IdentityOption(key: 2, value: "Profesor/ra; Profesorado"),
        IdentityOption(key: 3, value: "OFW"),
        IdentityOption(key: 4, value: "Desempleado/a"),
        IdentityOption(key: 5, value: "Estudiante"),
        IdentityOption(key: 6, value: "Especialista profesional"),
        IdentityOption(key: 7, value: "Propietario de negocio"),
        IdentityOption(key: 8, value: "Funcionario"),
        IdentityOption(key: 9, value: "Trabajador de fábrica"),
        IdentityOption(key: 10, value: "Director/Administrador"),
        IdentityOption(key: 11, value: "Empleado contratado"),
        IdentityOption(key: 12, value: "Pensionista; Jubilado/a"),
        IdentityOption(key: 13, value: "Ama de casa"),
        IdentityOption(key: 14, value: "Otros")
    ]
    
    static let income = [
        IdentityOption(key: 1, value: "< S/1000"),
        IdentityOption(key: 2, value: "S/1001~S/3000"),
        IdentityOption(key: 3, value: "S/3001~S/5000"),
        IdentityOption(key: 4, value: "S/5001~S/7000"),
        IdentityOption(key: 5, value: "> S/7000")
    ]
    /// 工作年限
    static let workExperience = [
        IdentityOption(key: 1, value: "Entre 0-3 meses"),
        IdentityOption(key: 2, value: "Entre 3-6 meses"),
        IdentityOption(key: 3, value: "Entre 6-12 meses"),
        IdentityOption(key: 4, value: "Entre 1-2 años"),
        IdentityOption(key: 5, value: "Entre 2-5 años"),
        IdentityOption(key: 6, value: "más de 5 years")
    ]
    
    /// 工资支付频率
    static let payFrequency = [
        IdentityOption(key: 1, value: "Semanal"),
        IdentityOption(key: 2, value: "Dos veces al mes"),
        IdentityOption(key: 3, value: "Una vez al mes"),
        IdentityOption(key: 4, value: "Diario")
    ]
    
    /// 联系人关系
    static let contactRelation = [
        IdentityOption(key: 1, value: "cónyuge"),
        IdentityOption(key: 2, value: "padre"),
        IdentityOption(key: 3, value: "madre"),
        IdentityOption(key: 4, value: "hijo/a"),
        IdentityOption(key: 5, value: "hermano"),
        IdentityOption(key: 6, value: "hermana")
    ]
    
    /// 性别
    static let gender = [
        IdentityOption(key: 1, value: "Masculino"),
        IdentityOption(key: 2, value: "Femenino")
    ]
    
    /// 银行卡账号类型
    static let bankAccountType = [
        IdentityOption(key: 1, value: "Corriente"),
        IdentityOption(key: 2, value: "Vista"),
        IdentityOption(key: 3, value: "Ahorro"),
        IdentityOption(key: 4, value: "RUT"),
        IdentityOption(key: 5, value: "Salary")
    ]
    
    /// 是否器官捐献
    static let organDonation = [
        IdentityOption(key: 1, value: "Sí"),
        IdentityOption(key: 2, value: "No")
    ]
}


extension IdentityDataSource {
    /// 通过 KeyPath 动态查找
    /// 调用示例: IdentityDataSource.find(key: 3, at: \.maritalStatus)
    static func find(key: Int, at path: KeyPath<IdentityDataSource.Type, [IdentityOption]>) -> IdentityOption? {
        let source = IdentityDataSource.self[keyPath: path]
        return source.first(where: { $0.key == key })
    }
    
    /// 通过key 动态查找 下标
    /// /// 通过 key 动态查找其在数组中的下标 (Index)
    /// 调用示例: IdentityDataSource.findIndex(key: 3, at: \.maritalStatus)
    static func findIndex(key: Int, at path: KeyPath<IdentityDataSource.Type, [IdentityOption]>) -> Int? {
        let source = IdentityDataSource.self[keyPath: path]
        return source.firstIndex(where: { $0.key == key })
    }
}
