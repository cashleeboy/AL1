//
//  BaseApplyViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class BaseApplyViewController<VM: ApplicationAuthModuleProtocol>: BaseFormerViewController {
    var moduleVM: VM
    var flowCoordinator: AuthFlowViewModel? // 流程导演

    // prepare data completion
    var dataCompletion: (() -> Void)?
    
    lazy var selectionFormer: SectionFormer = {
        let selection = SectionFormer()
            .set(headerViewFormer: zeroSpaceHeader())
        return selection
    }()
    lazy var filedSectionFormer: SectionFormer = {
        let selection = SectionFormer()
            .set(headerViewFormer: zeroSpaceHeader())
        return selection
    }()
    
    lazy var bottomContainer: BottomButtonContainer = {
        let bottom = BottomButtonContainer()
        bottom.configure(with: .customContentView(primaryTitle: "Próximo paso", topContentView: nil, bottomContentView: sslContainerView(), primaryAction: { [weak self] in
            guard let self else { return }
            bottomAction()
        }))
        return bottom
    }()
    
    init(viewModel: VM, coordinator: AuthFlowViewModel? = nil) {
        self.moduleVM = viewModel
        self.flowCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    // 子类提交成功后调用此方法
    func notifyStepFinished() {
        view.endEditing(true)
        moduleVM.submitData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                flowCoordinator?.handleModuleEntryFinished(current: moduleVM.reviewType)
            case .failure(let failure):
                showToast(failure.message)
            }
        }
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
        tableView.bounces = false
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.addSubview(bottomContainer)
        bottomContainer.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        
        let topOffset = NavigationUtility.totalTopSafeAreaHeight() * -1
        updateTableViewConstraints(
            top: topOffset,
            bottom: bottomContainer.frame.height,
            leading: 0,
            trailing: 0,
            pinToScreenTop: true
        )
        
        former.onScroll { [weak self] scrollView in
            guard let self else { return }
            let totalScrollableHeight = scrollView.contentSize.height - view.bounds.height
            guard totalScrollableHeight > 0 else { return }
            
            let calculatedAlpha = scrollView.contentOffset.y / 80
            navigation.bar.alpha = min(1.0, max(0, calculatedAlpha))
        }

    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigation.bar.alpha = 1
        navigation.item.title = moduleVM.reviewType.barTitle
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
        
        navigation.bar.backBarButtonItem?.shouldBack = { [weak self] item in
            guard let self else { return false }
            // 信息填写挽留弹窗
            showTwoDialog {
                self.flowCoordinator?.onFlowFinishedRequestRefresh?()
                self.navigationController?.popToRootViewController(animated: true)
            }
            return false
        }
    }
    
    override func loadFormer() {
        let stepRow = InformationStepsRowFormer<InformationStepsCell>(instantiateType: .Class) { cell in
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }
        
        stepRow.reviewType = moduleVM.reviewType
        let stepSection = SectionFormer(rowFormer: stepRow).set(headerViewFormer: zeroSpaceHeader())
        former.append(sectionFormer: stepSection)
    }
    
    func bottomAction() { }
    
}

extension BaseApplyViewController
{
    // Cifrado SSL de 256 bits
    private func sslContainerView() -> UIView {
        let container = UIView()
        let btn = UIButton()
        btn.backgroundColor = UIColor(hex: "#FFF1E6")
        btn.setTitle("Cifrado SSL de 256 bits", for: .normal)
        btn.setTitleColor(AppColorStyle.shared.textGray66, for: .normal)
        btn.setImage(UIImage(named: "btn_ssl_icon"), for: .normal)
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = AppFontProvider.shared.getFont12Regular()
        btn.setImageTitleLayout(.imgLeft, spacing: 1)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(0)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(170)
        }
        return container
    }
}

extension BaseApplyViewController: AuthDialogPresentable { }

