//
//  EnRevisionPage.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit

// 审核中页面
class EnRevisionPage: ReembolsoBasePage {
    override var isRevisionMode: Bool { return true } // 审核页面设为 true
    override func loadData() {
        // 请求“审核中”接口
        viewModel.fetchHistoryOder(with: .review)
    }
    
    override func clicAction() {
        viewModel.showPaymentMethodDialog()
    }
    
}
