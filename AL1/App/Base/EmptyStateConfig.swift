//
//  EmptyStateConfig.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit

enum EmptyStateConfig {
    case noPrdido
    case noIndexData
    case noNetwork
    case noRepay
    case noResults(query: String) // 搜索无结果
    case connectionError // 网络连接错误
    case noAvailable(message: String)
    case imageTitleMessage(image: UIImage?, title: String, message: String, buttonTitle: String?)
    
    var configuration:(image: UIImage?, title: String?, subtitle: String?, buttonTitle: String?) {
        switch self {
        case .noPrdido:
            return (
                image: UIImage(named: "empty_actualmente"),
                title: "Aún no hay pedidos",
                subtitle: nil,
                buttonTitle: "pedir prestado dinero"
            )
        case .noIndexData, .noNetwork:
            return (
                image: UIImage(named: "empty_favor"),
                title: "Por favor verifique su conexión de red",
                subtitle: nil,
                buttonTitle: "Actualizar"
            )
        case .noRepay:
            return (
                image: UIImage(named: "empty_actualmente"),
                title: "Aún no hay pedidos",
                subtitle: nil,
                buttonTitle: "Actualizar"
            )
        case .noResults(let query):
            return (
                image: UIImage(named: "empty_actualmente"),
                title: "No se encontraron resultados para '\(query)'",
                subtitle: nil,
                buttonTitle: "Reiniciar búsqueda"
            )
        case .connectionError:
            return (
                image: UIImage(named: "empty_network_icon"),
                title: "Error de conexión",
                subtitle: "Comprueba tu conexión a Internet.",
                buttonTitle: "Reintentar"
            )
        case .noAvailable(let message):
            return (
                image: nil,
                title: message,
                subtitle: nil,
                buttonTitle: nil
            )
        case .imageTitleMessage(let image, let title, let message, let buttonTitle):
            return (
                image: image,//UIImage(named: "empty_funding"),
                title: title,
                subtitle: message,
                buttonTitle: buttonTitle
            )
        default:
            return (
                image: UIImage(named: "empty_prdido_icon"),
                title: nil,
                subtitle: nil,
                buttonTitle: "Pedir dinero ahora"
            )
        }
    }
}
