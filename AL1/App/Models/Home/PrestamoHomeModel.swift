//
//  PrestamoHomeModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/23.
//

import SwiftyJSON

enum OrderShowStatus: Int {
    case blacklisted = 0               // 拉黑
    case reviewingCancellable = 20     // 审核中 (可以取消)
    case reviewingUncancellable = 23   // 审核中 (不可取消)
    case rejected = 22                 // 被拒
    case lending = 30                  // 放款中 (逻辑上合并至审核不可取消)
    case inRepayment = 40              // 还款中
    case overdue = 43                  // 逾期
    case lendFailedBankReason = 51     // 账户原因放款失败 (可改卡)
    case lendFailedOtherReason = 52    // 其他原因放款失败
    case unknown = -1                  // 未知状态/默认状态
}

extension OrderShowStatus {
    /// 统一配置数据源
    var emptyConfig: (imageName: String, title: String, message: String, btnTitle: String?)? {
        switch self {
        case .reviewingCancellable:
            return ("empty_funding", "En revisión", "El préstamo se está procesando; una vez completado, se abonará en su cuenta. Espere por favor", nil)
        case .blacklisted:
            return ("empty_funding_fail", "Revista rechazada", "Mantenga un buen crédito y presente la solicitud nuevamente más tarde.", nil)
        case .rejected:
            return ("empty_funding_fail", "Revista rechazada", "Podrá volver a solicitar cuando su historial crediticio sea favorable.", nil)
        case .lending:
            return ("empty_funding", "En proceso de dar préstamos", "Su solicitud ha sido aprobada. Por favor, espere pacientemente.", nil)
        case .lendFailedBankReason:
            return ("empty_funding", "Error en el pago", "Por favor, verifique la información de su cuenta bancaria y vuelva a intentarlo.", "Modificar ahora")
        case .lendFailedOtherReason:
            return ("empty_funding", "Error en el pago", "Por favor, comuníquese a tiempo con nuestro servicio de atención al cliente para resolver el problema.", "Contactar con el servicio al cliente")
        default:
            return nil
        }
    }
}

/// 首页大分类布局类型
enum HomeLayoutType: String {
    /// 1: 未申请成功前已登录首页或未完成进件信息填写 (展示借款引导/进度补充)
    case initialOrIncomplete = "1"
    
    /// 2: 首贷用户确认额度页 (展示计算器/确认额度按钮)
    case firstLoanConfirm = "2"
    
    /// 3: 首页单状态 (展示单个订单卡片)
    case singleOrderStatus = "3"
    
    /// 4: 首页多状态 (展示多个产品或订单列表)
    case multiOrderStatus = "4"
    
    /// 兜底状态
    case unknown = ""
}

struct PrestamoHomeModel: DecodableData {
    // 对应 data 根层级
    // code :ybQh63M8qwU : yZkvyDY2J: 编号（1：[未申请成功前已登录首页或未完成进件信息填写] 2:[首贷用户确认额度页] 3：[首页单状态] 4:[首页多状态]
    let code: String                         // yZkvyDY2J
    // 业务逻辑映射
    var layoutType: HomeLayoutType {
        return HomeLayoutType(rawValue: code) ?? .unknown
    }

    let loanInfo: LoanInfoModel?            // u18FQJiSpFVVxm       2:[首贷用户确认额度页]
    let statistics: StatisticsModel?        // wi0DFjZZ
    let orderInfo: OrderInfoModel?          // jdJKKR0OUZLT     //首页展示数据信息（对应code = 3 取这个对象中数据）
    let marketLoanAmount: String            // tftbxkABZh       营销金额
    let marketLoanDays: String              // jky_anE          营销期限
    let recoverFlag: Bool                      // iaM6R8ddKv       被拒恢复标识

    init(json: JSON) {
        let data = json // 假设传入的已经是 data 层级的 JSON
        self.code = data["yZkvyDY2J"].stringValue
        self.loanInfo = LoanInfoModel(json: data["u18FQJiSpFVVxm"])
        self.statistics = StatisticsModel(json: data["wi0DFjZZ"])
        self.orderInfo = OrderInfoModel(json: data["jdJKKR0OUZLT"])
        self.marketLoanAmount = data["tftbxkABZh"].stringValue
        self.marketLoanDays = data["jky_anE"].stringValue
        self.recoverFlag = data["iaM6R8ddKv"].boolValue
    }
}

// MARK: - 借款详情模块 (u18FQJiSpFVVxm)
struct LoanInfoModel {
    let bankCardName: String                // c9hWsHC
    let bankId: String
    let bankCardNo: String                  // s_0ioeu
    let loanAmount: String                  // fS2chxKewoa7dtFQSV
    let serviceFee: String                  //
    let compServiceFee: Int                 // egDPL
    let products: [LoanProductModel]        // ycXVWRngyL6yKJ
    let repayDate: String                   // jknobDslqwT
    let showType: String            //展示类型: 1、默认展示营销 2、只展示最小可借 3、只展示最大可借 4、展示范围
    let repaymentAmount: Int                //  还款金额 pKvuYmz8
    let rent: Int                           // 总利息，单位为分 iqdGp98
    let receiptAmount: Int                  // 到账金额 orkhVnsORxaaV4WEBu
    
    init(json: JSON) {
        self.bankCardName = json["c9hWsHC"].stringValue
        self.bankId = json["hvTDGT8j9GQ8JjT"].stringValue
        self.bankCardNo = json["s_0ioeu"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.serviceFee = json["iMuLp_O74wA2"].stringValue
        self.compServiceFee = json["egDPL"].intValue
        self.products = json["ycXVWRngyL6yKJ"].arrayValue.map { LoanProductModel(json: $0) }
//        self.products = json["ycXVWRngyL6yKJ"].arrayValue.flatMap {
//            return [
//                LoanProductModel(json: $0),
//                LoanProductModel(json: $0)
//            ]
//        }
        self.repayDate = json["jknobDslqwT"].stringValue
        self.showType = json["luULO4MDZNnihj"].stringValue
        self.repaymentAmount = json["pKvuYmz8"].intValue
        self.rent = json["iqdGp98"].intValue
        self.receiptAmount = json["orkhVnsORxaaV4WEBu"].intValue
    }
}

// MARK: - 产品详情模块 (ycXVWRngyL6yKJ)
struct LoanProductModel {
    let appOrderId: String                  // poW1L_VZhHh appOrderId
    let productLogo: String                 // eHxx_I
    let productName: String                 // eODIjjJ
    let productCode: String                 // btdxX7JuiyUOwNdk
    let loanAmount: String                  // fS2chxKewoa7dtFQSV        产品金额
    let term: String                        // rhG4oMUGgnfR     分期期数
    let daysPerTerm: String                 // axrVe1gbs_brah 每期天数
    let repaymentPlans: [RepaymentPlanModel]// rkqlch1Nq7z
    let feeDetail: FeeDetailModel?          // eHp5mtR601Vd
    let isCheck: Bool                       // mkEfI7jNRkCs8gO
    let repayDate: String
    let totalDays: Int                      // 期限 总天数 pS9x0qIsa
    let compServiceFee: Int                 // 综合服务费 egDPL
    let repaymentAmount: Int                //  应还金额 pKvuYmz8
    let receiptAmount: Int                  // 到账金额 orkhVnsORxaaV4WEBu
    let interest: Int

    init(json: JSON) {
        self.appOrderId = json["poW1L_VZhHh"].stringValue
        self.productLogo = json["eHxx_I"].stringValue
        self.productName = json["eODIjjJ"].stringValue
        self.productCode = json["btdxX7JuiyUOwNdk"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.daysPerTerm = json["axrVe1gbs_brah"].stringValue
        self.term = json["rhG4oMUGgnfR"].stringValue
        self.repaymentPlans = json["rkqlch1Nq7z"].arrayValue.map { RepaymentPlanModel(json: $0) }
        self.feeDetail = FeeDetailModel(json: json["eHp5mtR601Vd"])
        self.isCheck = json["mkEfI7jNRkCs8gO"].boolValue
        self.repayDate = json["yfB94TdOW1tDNAGp"].stringValue
        self.totalDays = json["pS9x0qIsa"].intValue
        self.compServiceFee = json["egDPL"].intValue
        self.receiptAmount = json["orkhVnsORxaaV4WEBu"].intValue
        self.repaymentAmount = json["pKvuYmz8"].intValue
        self.interest = json["aTGXpg0"].intValue
    }
    
    func fetchComfirmLoan() -> [String: String] {
        var params: [String: String] = [
            "btdxX7JuiyUOwNdk" : productCode,
            "fS2chxKewoa7dtFQSV" : loanAmount
        ]
        if !appOrderId.isEmpty {
            params["poW1L_VZhHh"] = appOrderId
        }
        return params
    }
    
}

// MARK: - 还款计划 (rkqlch1Nq7z)
struct RepaymentPlanModel {
    let installmentNum: String              // gqiWcyT
    let installmentAmount: String           // uIvghAN
    let repayDateStr: String                // enpJvKYQzP09n
    let principal: String                   // hLLA1leONtnagmEKZ
    let interest: String                    // aTGXpg0

    init(json: JSON) {
        self.installmentNum = json["gqiWcyT"].stringValue
        self.installmentAmount = json["uIvghAN"].stringValue
        self.repayDateStr = json["enpJvKYQzP09n"].stringValue
        self.principal = json["hLLA1leONtnagmEKZ"].stringValue
        self.interest = json["aTGXpg0"].stringValue
    }
}

// MARK: - 费用详情 (eHp5mtR601Vd)
struct FeeDetailModel {
    let creditServiceFee: Int            //征信服务费 g80pYruWY
    let interest: Int                    // 利息 aTGXpg0
    let payChannelFee: Int               //支付通道费 dNuTf
    let serviceFee: Int                  // 服务费 iMuLp_O74wA2
    let taxation: Int                    // 费 i7zlLwtp8i6sf1

    init(json: JSON) {
        self.creditServiceFee = json["g80pYruWY"].intValue
        self.interest = json["aTGXpg0"].intValue
        self.payChannelFee = json["dNuTf"].intValue
        self.serviceFee = json["iMuLp_O74wA2"].intValue
        self.taxation = json["i7zlLwtp8i6sf1"].intValue
    }
}

// MARK: - 统计信息模块 (wi0DFjZZ)
struct StatisticsModel {
    let finishLoanCount: Int                // aCUtTa
    let totalLoanAmount: String             // dMZ7Ivn5KJfEXqqBF
    let pendingOrders: [PendingOrderModel]  // lOi3Y5GIDj4uRMqa

    init(json: JSON) {
        self.finishLoanCount = json["e4dpCO_"]["aCUtTa"].intValue
        self.totalLoanAmount = json["e4dpCO_"]["dMZ7Ivn5KJfEXqqBF"].stringValue
        self.pendingOrders = json["lOi3Y5GIDj4uRMqa"].arrayValue.map { PendingOrderModel(json: $0) }
    }
}

struct PendingOrderModel {
    let totalAmount: String                 // p71LNzm5Rc1
    let countDownTime: Int                  // oZvYo5M

    init(json: JSON) {
        self.totalAmount = json["p71LNzm5Rc1"].stringValue
        self.countDownTime = json["oZvYo5M"].intValue
    }
}

// MARK: - 订单信息模块 (jdJKKR0OUZLT)
struct OrderInfoModel {
    let orderShowType: OrderShowStatus // 使用枚举类型
    let lastOrder: LastOrderModel?

    init(json: JSON) {
        // 将获取到的 Int 转为枚举，如果不在定义范围内则设为 .unknown
        let rawType = json["cw575eS8zYl"].intValue
        self.orderShowType = OrderShowStatus(rawValue: rawType) ?? .unknown
        self.lastOrder = LastOrderModel(json: json["eBJrYnqZAay2X"])
    }
}


struct LastOrderModel {
    let productName: String                 // eODIjjJ
    let loanAmount: String                  // fS2chxKewoa7dtFQSV
    let repayAmount: String                 // qmxrJ0hkFPoe62zPS
    let repayDate: String                   // jknobDslqwT

    init(json: JSON) {
        self.productName = json["eODIjjJ"].stringValue
        self.loanAmount = json["fS2chxKewoa7dtFQSV"].stringValue
        self.repayAmount = json["qmxrJ0hkFPoe62zPS"].stringValue
        self.repayDate = json["jknobDslqwT"].stringValue
    }
}
