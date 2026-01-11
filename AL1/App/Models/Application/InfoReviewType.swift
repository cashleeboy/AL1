//
//  InfoReviewType.swift
//  AL1
//
//  Created by cashlee on 2025/12/24.
//

import Foundation

// Information review type
enum InfoReviewType: Int {
    case personal = 1
    case contact = 2
    case bank = 3
    case certificate = 4
    case faceRecognition = 5 //人脸识别
    case dataValid
    
    var barTitle: String {
        switch self {
        case .personal:
            "Informacion personal"
        case .contact:
            "Información del contacto"
        case .bank:
            "Agrega una Tarjeta Bancaria."
        case .certificate:
            "Verificar identidad"
        case .faceRecognition:
            "Reconocimiento facial"
        case .dataValid:
            "Completa la información"
        }
    }
    
    var barSubTitle: String {
        switch self {
        case .personal:
            "La información que proporcione se utilizará únicamente para la evaluación crediticia y se mantendrá segura."
        case .contact:
            "La información que proporcione se utilizará únicamente para la evaluación crediticia y se mantendrá segura."
        case .bank:
            "La información que proporcione se utilizará únicamente para la evaluación crediticia y se mantendrá segura."
        case .certificate:
            "La información que proporcione se utilizará únicamente para la evaluación crediticia y se mantendrá segura."
        default: 
            ""
        }
    }
    
}
