//
//  UploadDataPageView.swift
//  AL1
//
//  Created by cashlee on 2026/1/4.
//

import UIKit

class UploadDataPageView: BaseTableViewController {
    let step: AuthStepType
    var flowCoordinator: AuthFlowViewModel?
    
    private lazy var viewModel = UploadDataPageViewModel()
    
    private var progressTimer: Timer?
    private var currentMockProgress: CGFloat = 0
    // 在类定义中增加状态变量
    private var isCompleting: Bool = false
    
    var onFinishedRequestRefresh: (() -> Void)?
    
    init(step: AuthStepType, coordinator: AuthFlowViewModel? = nil) {
        self.step = step
        self.flowCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        tableView.bounces = false
        tableView.rowHeight = UITableView.automaticDimension
        isShowBottomButtonContainer = false
        updateTableViewTop(to: .safeArea, animated: false)
        
        // 1. 开始模拟进度 (从 0 到 95%，留 5% 给真正的接口完成)
        startSimulatingProgress()
        
        // 这个post接口，所以帮我模拟一个progress的过程
        viewModel.submitCustomerUploaded { [weak self] in
            guard let self else { return }
            completeProgress() // 成功：强制到 100%
        } onFail: { [weak self] message in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            showToast(message)
        }

    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = step.title
        
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
        
        navigation.bar.backBarButtonItem?.shouldBack = { [weak self] item in
            guard let self else { return true }
            flowCoordinator?.finishFlowAndRefresh()
            return true
        }
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func setupData() {
        super.setupData()
        updateToStatusUI(step: .uploading)
    }

}

extension UploadDataPageView
{
    private func updateToStatusUI(step: FaceAuthStepType) {
        let statusItem = FaceAuthStatusItem(step: step)
        renderRows(with: [statusItem])
    }
 
    private func renderRows(with items: [any TableItemProtocol]) {
        let rows: [RowRepresentable] = items.compactMap { item in
            // 如果 Model 遵循了转换协议，则调用其转换方法
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { selectedItem in
                    
                })
            }
            return nil
        }
        reloadData(with: rows)
    }

}

// MARK: - 进度模拟逻辑
extension UploadDataPageView {
    
    private func startSimulatingProgress() {
        currentMockProgress = 0
        isCompleting = false // 重置状态
        stopTimer()
        
        // 每 0.1 秒更新一次，模拟平滑增长
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 如果已经快到临界点了，保持在 95%
            if self.currentMockProgress >= 0.95 {
                self.currentMockProgress = 0.95
                self.updateUIProgress(0.95)
                self.stopTimer()
                return
            }
            // 模拟减速增长逻辑：越接近 100 增加越慢
            let step = (1.0 - self.currentMockProgress) / 40.0 + 0.005
            self.currentMockProgress += step
            self.updateUIProgress(self.currentMockProgress)
        }
    }
    
    private func completeProgress() {
        // 1. 立即加锁，防止 Timer 异步回调覆盖 100% 状态
        isCompleting = true
        stopTimer()
        
        self.currentMockProgress = 1.0
        updateUIProgress(1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 根据业务跳转下一步
            AppRootSwitcher.switchToMain()
        }
    }
    
    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateUIProgress(_ value: CGFloat) {
        let safeValue = min(max(value, 0.0), 1.0)
        
        guard let sections = tableController?.sections,
              let firstSection = sections.first else { return }
        
        if let index = firstSection.firstIndex(where: { $0.item.identifier == FaceAuthStatusItem.reuseIdentifier }) {
            let row = firstSection[index]
            if var statusItem = row.item as? FaceAuthStatusItem {
                // ⭐️ 关键防御：如果当前 UI 已经是 100，拒绝任何非 100 的更新
                let currentUIValue = statusItem.currentProgess ?? 0
                if currentUIValue >= 1.0 && safeValue < 1.0 {
                    return
                }
                
                if safeValue < currentUIValue {
                    return
                }
                statusItem.currentProgess = safeValue
                self.updateData(with: statusItem, animated: false)
            }
        }
    }
}
