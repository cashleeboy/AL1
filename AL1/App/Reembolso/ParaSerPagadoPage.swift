//
//  ParaSerPagadoPage.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit

// 待还款页面
class ParaSerPagadoPage: ReembolsoBasePage {
    
    override func loadData() {
        // 请求“待还款”接口
        viewModel.fetchHistoryOder(with: .tobePay)
    }
    
    
    override func clicAction() {
        viewModel.showPaymentMethodDialog()
    }
}
