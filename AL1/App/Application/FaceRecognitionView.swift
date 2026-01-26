//
//  FaceRecognitionView.swift
//  AL1
//
//  Created by cashlee on 2025/12/22.
//

import UIKit

class FaceRecognitionView: BaseTableViewController {
    var moduleVM: FaceRecognitionViewModel
    var flowCoordinator: AuthFlowViewModel? // 流程导演
    private var formItems: [any TableItemProtocol] = []
    // 声明一个变量来保存 Model 引用
    private var recognitionModel: FaceRecognitionSectionModel?
    
    init(viewModel: FaceRecognitionViewModel, coordinator: AuthFlowViewModel? = nil) {
        self.moduleVM = viewModel
        self.flowCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        isShowBottomButtonContainer = true
        
        updateTableViewTop(to: .safeArea, animated: false)
        
        moduleVM.fetchCurrentLocation()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = moduleVM.reviewType.barTitle
        
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
        
        navigation.bar.backBarButtonItem?.shouldBack = { [weak self] item in
            guard let self else { return false }
            if moduleVM.uploadingType == .success {
                self.flowCoordinator?.finishFlowAndRefresh()
                return false
            }
            // 确保在主线程执行，并稍微延迟以避开当前的 Dismiss 动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showTwoDialog {
                    self.flowCoordinator?.finishFlowAndRefresh()
                }
            }
            return false
        }
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "Empezar a identificar") { [weak self] in
            guard let self else { return }
            // 执行触发拍照逻辑
            if moduleVM.uploadingType == .failure {
                setupData()
            } else {
                recognitionModel?.triggerCapture?()
                #if DEBUG
                debugCamera()
                #endif
            }
        }
        bottomContainer.configure(with: style)
    }
    
    override func setupData() {
        super.setupData()
        moduleVM.uploadingType = nil
        let imageCapturedClosure: ((UIImage) -> Void) = { [weak self] img in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.recognitionModel?.onStopRuningCapture?()
            }
            let fixImg = img.fixImageOrientation()
            self.bottomContainer.setPrimaryState(isEnable: false)
            
            self.moduleVM.customerOCRVerify(with: fixImg, from: .camera, progressHandler: { progress in
                
            }) { [weak self] result in
                guard let self = self else { return }
                self.bottomContainer.setPrimaryState(isEnable: true)
                
                switch result {
                case .success(let response):
                    // 根据接口返回的 isSuccess 决定显示哪个状态
                    let step: FaceAuthStepType = response.isSuccess ? .success : .failure
                    self.updateToStatusUI(step: step)
                    
                    
                    if response.isSuccess {
                        // after 1.08
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.06) {
                            self.flowCoordinator?.handleModuleEntryFinished(current: self.moduleVM.reviewType)
                        }
                    }
                case .failure(let error):
                    // 接口报错处理：可以显示失败 UI 或弹窗
                    self.showToast(error.localizedDescription)
                    self.updateToStatusUI(step: .failure)
                }
            }
        }
        let model = FaceRecognitionSectionModel(onImageCaptured: imageCapturedClosure)
        self.recognitionModel = model
        renderRows(with: [model])
    }
}

extension FaceRecognitionView
{
    /// 刷新表格行映射
    private func renderRows(with items: [any TableItemProtocol]) {
        // 每次渲染新行前，确保旧相机关掉
        if items.contains(where: { $0 is FaceAuthStatusItem }) {
            recognitionModel?.onStopRuningCapture?()
        }
        
        let rows: [RowRepresentable] = items.compactMap { item in
            if let temp = item as? FaceAuthStatusItem {
                return ConcreteRow<FaceAuthStatusItem, FaceAuthStatusCell>(item: temp)
            } else if let temp = item as? FaceRecognitionSectionModel {
                return ConcreteRow<FaceRecognitionSectionModel, FaceRecognitionSectionCell>(item: temp)
            }
            return nil
        }
        reloadData(with: rows)
    }

    /// 切换到状态 UI (成功或失败)
    private func updateToStatusUI(step: FaceAuthStepType) {
        let statusItem = FaceAuthStatusItem(step: step)
        moduleVM.uploadingType = step
        
        // 清空当前行，只显示状态行
        self.renderRows(with: [statusItem])
        
        // 如果失败，更新底部按钮为“重试”
        if step == .failure {
            bottomContainer.setPrimaryState(with: "Intentar otra vez")
            bottomContainer.isHidden = false
        }
        else {
            // 如果成功，隐藏或禁用按钮
            bottomContainer.isHidden = true
        }
    }
    
    private func debugCamera() {
        guard let fixImg = UIImage(named: "face")?.fixImageOrientation() else {
            return
        }
        self.bottomContainer.setPrimaryState(isEnable: false)
        self.moduleVM.customerOCRVerify(with: fixImg, from: .camera, progressHandler: { progress in
        }) { [weak self] result in
            guard let self = self else { return }
            self.bottomContainer.setPrimaryState(isEnable: true)
            
            switch result {
            case .success(let response):
                // 根据接口返回的 isSuccess 决定显示哪个状态
                let step: FaceAuthStepType = response.isSuccess ? .success : .failure
                self.updateToStatusUI(step: step)
                
                // after 1.08
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.06) {
                    self.flowCoordinator?.handleModuleEntryFinished(current: self.moduleVM.reviewType)
                }
                
            case .failure(let error):
                // 接口报错处理：可以显示失败 UI 或弹窗
                self.showToast(error.localizedDescription)
                self.updateToStatusUI(step: .failure)
               
            }
        }
    }
}

extension FaceRecognitionView: AuthDialogPresentable { }

