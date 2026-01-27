//
//  ConfirmLoanViewModel.swift
//  AL1
//
//  Created by cashlee on 2026/1/26.
//

import Combine
import StoreKit
import Foundation
import SwiftEntryKit

class ConfirmLoanViewModel {
    private lazy var repository = PrestamoRepository()
    
    var cancellables = Set<AnyCancellable>()

    @Published var applyModel: LoanApplyModel?
    @Published var errorMessage: String?
    @Published var selectedProductsMap: [String: Any] = [:]
    @Published var bottomTitle: String = "Solicitar 1 producto con un clic"
    
    func fetchApply() {
        repository.fetchApplySuccess { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                applyModel = data
            case .failure(let failure):
                errorMessage = failure.message
            }
        }
    }
    
    func buildLoanSections() -> [any TableItemProtocol] {
        var items: [any TableItemProtocol] = []
        
        let model = ConfirmLoanHeaderModel()
        items.append(model)
        
        guard let productList = applyModel?.productList else {
            return items
        }
        let isOnlyOne = productList.count == 1
        selectedProductsMap.removeAll()

        let list = productList.map{ model -> ConfirmLoanItemModel in
            let item = ConfirmLoanItemModel(item: model, isOnlyOne: isOnlyOne) { [weak self] uuid, isSelected in
                guard let self else { return }
                guard isOnlyOne == false else {
                    errorMessage = "El límite mínimo de endeudamiento es uno"
                    return
                }
                if isSelected {
                    self.selectedProductsMap[uuid] = true
                } else {
                    self.selectedProductsMap.removeValue(forKey: uuid)
                }
            }
            selectedProductsMap[item.uuid] = true
            return item
        }
        items.append(contentsOf: list)
        
        return items
    }
}

extension ConfirmLoanViewModel
{
    // 检查是否已经请求过评分
    var hasRated: Bool {
        get { UserDefaults.standard.bool(forKey: "kHasUserRatedApp") }
        set { UserDefaults.standard.set(newValue, forKey: "kHasUserRatedApp") }
    }

    func showRatingIfNeeded() {
        guard !hasRated else { return }
        
        let ratingDialog = RatingDialog()
        ratingDialog.primaryAction = { [weak self] in
            guard let self else { return }
            SwiftEntryKit.dismiss()
            
            hasRated = true
            requestSystemReview()
        }
        
        // 关闭动作
        ratingDialog.cancelAction = {
            SwiftEntryKit.dismiss()
        }
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: ratingDialog, using: attributes)
    }
}

extension ConfirmLoanViewModel {
    func requestSystemReview() {
        // 获取当前的 WindowScene
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                // iOS 14 以下的旧版写法
                SKStoreReviewController.requestReview()
            }
        }
    }
}
