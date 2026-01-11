//
//  LoanOrderDetailViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import Combine
import UIKit

class LoanOrderDetailViewModel {
    let orderId: String
    let status: OrderStatus?
    lazy var cancellables = Set<AnyCancellable>()
    
    @Published var detailModel: OrderDetailModel?
    @Published var errorMessage: String?
    
    private lazy var repository = ReembolsoRepository()
    var onContactService: (() -> Void)?
    
    init(orderId: String, status: OrderStatus? = nil, errorMessage: String? = nil, onContactService: (() -> Void)? = nil) {
        self.orderId = orderId
        self.status = status
        self.errorMessage = errorMessage
        self.onContactService = onContactService
    }
    
    
    func fetchOrderDetail() {
        repository.fetchOrderDetail(with: [orderId]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                detailModel = success
            case .failure(let failure):
                errorMessage = failure.message
            }
        }
    }
    
    func orderDetailSections(with detailModel: OrderDetailModel) -> [any TableItemProtocol] {
        // 1. 获取首个 Loan 信息，若为空则映射为默认的 auditing 状态
        guard let model = detailModel.loanOrderDetails.first else {
            return [createOrderDetailSection(status: .auditing, date: nil)]
        }

        // 2. 根据状态返回对应的 Section
        switch model.status {
        case .auditing, .rejected:
            return [createOrderDetailSection(status: model.status, date: model.loanDate)]
        default:
            // 处理其他状态或返回空
            return []
        }
    }
}

extension LoanOrderDetailViewModel {

    // MARK: - Private Helper
    private func createOrderDetailSection(status: OrderStatus, date: String?) -> LoanOrderDetailSectionModel {
        return LoanOrderDetailSectionModel(
            status: status,
            statusStr: status.statusTitle,
            timeHint: status.timeHint,
            subHintAttributed: getSubHint(for: status, date: date),
            onContactService: { [weak self] in
                self?.onContactService?()
            }
        )
    }

    /// 统一管理复杂的富文本逻辑
    private func getSubHint(for status: OrderStatus, date: String?) -> NSMutableAttributedString {
        switch status {
        case .auditing:
            return "Una vez aprobada la solicitud de préstamo, el préstamo se transferirá a su cuenta.".attributed
            
        case .rejected:
            var fullText = "Inténtelo de nuevo más tarde para obtener un préstamo."
            var boldParts: [String] = []
            
            if let date = date, !date.isEmpty {
                fullText = "Intente pedir prestado nuevamente después del \(date)"
                boldParts = [date]
            }
            return NSMutableAttributedString.makeStyledText(
                fullText: fullText,
                boldParts: boldParts,
                font: AppFontProvider.shared.getFont14Regular(),
                textColor: AppColorStyle.shared.textBlack33,
                boldTextColor: UIColor(hex: "#FF0000"),
                alignment: .center
            )
            
        default:
            return "".attributed
        }
    }
}
