//
//  ReembolsoBaseViewModel.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import Combine
import SwiftEntryKit

class ReembolsoBaseViewModel {
    // toggle product
    // key: 下标
    // value: 是否被选中
    var toggleProductData: [Int: Bool] = [:]
    
    private lazy var repository = ReembolsoRepository()
    // 发布错误信息，用于显示 Toast
    @Published private(set) var errorMessage: String?
    // 发布加载状态
    @Published private(set) var isLoading: Bool = false
    @Published var items: [OrderListItem] = []
    
    var cancellables = Set<AnyCancellable>()

    func fetchHistoryOder(with status: HistoryOrderStatus) {
        isLoading = true
        repository.fetchHistoryOrder(with: status) { [weak self] result in
            guard let self else { return }
            isLoading = false
            switch result {
            case .success(let success):
                items = success.orderList
            case .failure(let failure):
                errorMessage = failure.message
            }
        }
    }
    
    func setupToggleProduct(with index: Int, result: Bool) {
        if result {
            toggleProductData[index] = true
        } else {
            toggleProductData.removeValue(forKey: index)
        }
    }
    
    // 是否展示bottom button
    func isShowBottomBtn() -> Bool {
        return toggleProductData.values.contains(true)
    }
    
    /// 获取当前选中的所有下标 (可选辅助方法)
    func getSelectedIndexes() -> [Int] {
        return Array(toggleProductData.keys)
    }

    func getBottomBtnTitle() -> String? {
        return nil
    }
    
    func showPaymentMethodDialog() {
        let dialog = PaymentMethodDialog()
        let items = [
            PaymentMethodItem(id: "1", iconName: "bank_icon", title: "Pandapay", isSelected: true),
            PaymentMethodItem(id: "2", iconName: "store_icon", title: "Pandapay"),
            PaymentMethodItem(id: "3", iconName: "other_icon", title: "Pandapay")
        ]
        dialog.configure(with: items)
        dialog.onConfirm = { [weak self] id in
            guard let self else { return }

            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
}
