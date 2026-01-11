//
//  OrderStatus.swift
//  AL1
//
//  Created by cashlee on 2026/1/9.
//

import UIKit


enum OrderStatus: Int {
   /// 20: 审核中
   case auditing = 20
   /// 22: 审核拒绝
   case rejected = 22
   /// 3: 放款中
   case disbursing = 3
   /// 4: 还款中
   case repaying = 4
   /// 5: 放款失败未关闭
   case disburseFailed = 5
   /// 6: 还款完成 (结清)
   case settled = 6
   /// 7: 异常关闭
   case abnormalClosed = 7
   /// 兜底状态
   case unknown = -1

   /// 根据状态返回对应的标签颜色
   var tagcolor: UIColor {
       switch self {
       case .auditing:
           // 进行中：蓝色或品牌色
           return UIColor(hex: "#FFECC7")
       case .disbursing:
           return UIColor(hex: "#FFECC7")
       case .repaying:
           // 待还款：橙色或强调色
           return AppColorStyle.shared.brandPrimary
       default:
           return UIColor(hex: "#FFECC7")
       }
   }
   
   var titleColor: UIColor {
       switch self {
       case .auditing:
           return UIColor(hex: "#FE5656")
       default:
           return UIColor(hex: "#FE5656")
       }
   }
   
   var buttonTitle: String {
       switch self {
       case .auditing, .rejected:
           return "Comprobar los detalles"
       default:
           return ""
       }
   }
   
   var buttonTitleColor: UIColor {
       switch self {
       case .auditing:
           return AppColorStyle.shared.backgroundWhite
       case .rejected:
           return UIColor(hex: "#868383")
       default:
           return UIColor(hex: "#868383")
       }
   }
   
   var buttonTitleBgColor: UIColor {
       switch self {
       case .auditing:
           return AppColorStyle.shared.brandPrimary
       case .rejected:
           return AppColorStyle.shared.backgroundWhiteF0
       default:
           return AppColorStyle.shared.backgroundWhiteF0
       }
   }
}

extension OrderStatus {
   /// 统一处理状态描述文案的逻辑
   func formatStatusStr(_ rawStr: String) -> String {
       switch self {
       case .auditing:
           // 如果包含逗号，则取分割后的第一个元素，否则返回原字符串
           return rawStr.components(separatedBy: ",").first ?? rawStr
       default:
           return rawStr
       }
   }
}

extension OrderStatus {
   /// 状态标题描述
   var statusTitle: String {
       switch self {
       case .auditing: return "Su solicitud está en revisión. Por favor espere con paciencia."
       case .rejected: return "No pasó la revisión"
       case .disbursing: return "Desembolsando..."
       default: return ""
       }
   }

   /// 时间提示文案
   var timeHint: String? {
       switch self {
       case .auditing: return "El tiempo de revisión es de 1 a 5 minutos."
       default: return nil
       }
   }
}

