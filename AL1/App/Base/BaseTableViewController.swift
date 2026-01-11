//
//  BaseTableViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/16.
//

import UIKit
import SnapKit
import SwiftEntryKit

enum TableViewTopAnchorType {
    case safeArea
    case viewTop
    case customOffset(CGFloat)
}

class BaseTableViewController: UIViewController {
    
    private lazy var tableViewModel = BaseTableViewModel()
    
    // MARK: - 状态控制属性
    var isShowTopBannerContainer = false { didSet { updateTopBannerLayout() } }
    var isShowBottomButtonContainer = false { didSet { updateBottomLayout() } }
    
    // 顶部位置类型 (针对 TableView 顶部的灵活调整)
    var currentTopType: TableViewTopAnchorType = .safeArea {
        didSet {
            updateBottomLayout()
        }
    }
    
    lazy var safeViewTopInset = 0.0
    var onScroll: ((UIScrollView) -> Void)?
    
    // MARK: - UI 组件
    lazy var topBanner = TopBannerContainer(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
    lazy var bottomContainer = BottomButtonContainer()
    lazy var emptyView = EmptyStateView()
    internal lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    
    internal var tableController: ModelDrivenTableController?
    var dataSources: [Any] = [] {
        didSet {
            tableView.reloadData()
            updateEmptyViewState()
        }
    }
    
    // 外部配置 EmptyView
    private var _internalConfig: EmptyStateConfig? = .noIndexData
    var emptyStateConfig: EmptyStateConfig? {
        get { return _internalConfig }
        set { _internalConfig = newValue }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var shouldAutorotate: Bool {
        false
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        safeViewTopInset = NavigationUtility.totalTopSafeAreaHeight()
        view.backgroundColor = AppColorStyle.shared.backgroundWhite
        
        setupBaseUI()
        setupNavigationBar()
        
        // 如果子类是模型驱动的，可以在这里初始化
        initTableController()
        
        setupData()          // 供子类填充数据
        setupEmptyViewUI()   // 配置空状态
    }
    
    // MARK: - 初始化逻辑封装
    
    func initTableController() {
        // 默认不初始化，子类如果需要 ModelDriven 模式可手动或在此判断
        // tableController = ModelDrivenTableController(tableView: tableView)
    }

    private func setupBaseUI() {
        
        view.addSubview(topBanner)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(bottomContainer)
        
        // 初始隐藏状态
        topBanner.isHidden = true
        bottomContainer.isHidden = true
        emptyView.isHidden = true
        
        tableView.snp.makeConstraints { make in
            // 顶部逻辑
            if isShowTopBannerContainer {
                make.top.equalTo(topBanner.snp.bottom)
            } else {
                switch currentTopType {
                case .safeArea: make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                case .viewTop: make.top.equalTo(view.snp.top)
                case .customOffset(let offset): make.top.equalTo(view.snp.top).offset(offset)
                }
            }
            make.leading.trailing.equalToSuperview()
            if isShowBottomButtonContainer {
                make.bottom.equalTo(bottomContainer.snp.top)
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            }
        }
        
        // 基础约束：EmptyView 始终居中在 TableView 上
        emptyView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(tableView)
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }

    func setupNavigationBar() {
        navigation.bar.titleTextAttributes = [
            .foregroundColor : AppColorStyle.shared.backgroundWhite,
            .font: AppFontProvider.shared.getFont16Medium()
        ]
        navigation.bar.tintColor = .white
        setupServiceNavigationItem()
    }
    
    // 更新TableView顶部约束并记录状态
    func updateTableViewTop(to type: TableViewTopAnchorType, animated: Bool = true) {
        self.currentTopType = type
    }
    
    func configureTopBanner(with text: String, textColor: UIColor = AppColorStyle.shared.textBlack33) {
        topBanner.updateBannerStatus(text: text, textColor: textColor)
    }
    
    func showDialog(with dialog: UIView) {
        let attributes = EKAttributes.centerDialog()
        SwiftEntryKit.display(entry: dialog, using: attributes)
    }
    
    func dismissDialog() {
        SwiftEntryKit.dismiss()
    }
    
    @objc func setupData() { } // 子类重写
    
    func handleEmptyStateAction(for config: EmptyStateConfig) { }
    func configureBottomButton() { }
    
    func refresh() { }
}

extension BaseTableViewController {
    private func updateTopBannerLayout(animated: Bool = false) {
        guard isViewLoaded else { return }
        topBanner.isHidden = !isShowTopBannerContainer
        
        topBanner.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        performLayoutAnimation(animated)
    }
    
    private func updateBottomLayout(animated: Bool = false) {
        guard isViewLoaded else { return }

        // 更新 TableView 约束 (处理顶部和底部的联动)
        tableView.snp.remakeConstraints { make in
            // 顶部逻辑
            if isShowTopBannerContainer {
                make.top.equalTo(topBanner.snp.bottom)
            } else {
                switch currentTopType {
                case .safeArea: make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                case .viewTop: make.top.equalTo(view.snp.top)
                case .customOffset(let offset): make.top.equalTo(view.snp.top).offset(offset)
                }
            }
            make.leading.trailing.equalToSuperview()
            
            // 底部逻辑
            if isShowBottomButtonContainer {
                make.bottom.equalTo(bottomContainer.snp.top)
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            }
        }
        bottomContainer.isHidden = !isShowBottomButtonContainer
        
        // 更新底部容器约束
        if isShowBottomButtonContainer {
            configureBottomButton()
            bottomContainer.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        } else {
            bottomContainer.snp.remakeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        }
        
        performLayoutAnimation(animated)
    }
    
    private func performLayoutAnimation(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateEmptyViewState() {
        guard isViewLoaded else { return }
        let hasData = (tableController?.sections.count ?? 0) > 0 || dataSources.count > 0
        emptyView.isHidden = hasData
        tableView.isHidden = !hasData
    }

    private func setupEmptyViewUI() {
        guard let config = _internalConfig else { return }
        let conf = config.configuration
        emptyView.configure(image: conf.image, title: conf.title, subtitle: conf.subtitle, buttonTitle: conf.buttonTitle) { [weak self] in
            self?.handleEmptyStateAction(for: config)
        }
    }

}

// MARK: - 数据与业务逻辑
extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource
{
    // 默认 TableView 实现
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}


// MARK: action
extension BaseTableViewController
{
    // MARK: - 便捷方法 (供子类调用)
    func reloadData(with rows: [RowRepresentable]) {
        tableController?.reload(with: [rows])
        checkDataPresence()
        if rows.isEmpty { setupEmptyViewUI() } // 重新刷新空状态文案
    }
    
    func setupPullToRefresh(to autoStart: Bool = true) {
        let header: ESRefreshProtocol & ESRefreshAnimatorProtocol = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
//        header.trigger = 120
//        header.insets = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)
        tableView.es.addPullToRefresh(animator: header) { [weak self] in
            self?.refresh()
        }
        if autoStart {
            startPullToRefresh()
        }
    }
    
    func startPullToRefresh() {
        UIView.animate(withDuration: 0.2) {
            self.emptyView.alpha = 0
            self.tableView.alpha = 1
        }
        self.emptyView.isHidden = true
        self.tableView.isHidden = false
        tableView.es.startPullToRefresh()
    }
    
    func stopPullToRefresh() {
        tableView.es.stopPullToRefresh()
        checkDataPresence()
        tableView.reloadData()
    }
    
    func checkDataPresence() {
        let hasModelData = (tableController?.sections.compactMap({$0}).first?.count ?? 0) > 0
        let hasDataSourceData = !dataSources.isEmpty
        let hasData = hasModelData || hasDataSourceData

        // 动画切换显隐
        UIView.animate(withDuration: 0.2) {
            self.emptyView.alpha = hasData ? 0 : 1
            self.tableView.alpha = hasData ? 1 : 0
        }
        self.emptyView.isHidden = hasData
    }
    
    func updateData(with row: any TableItemProtocol, animated: Bool = true) {
        tableController?.update(with: row, animated: animated)
    }
    
    override func serviceAction() {
        tableViewModel.fetchServiceInfo { [weak self] items, error in
            guard let self else { return }
            guard let items else {
                showToast(error)
                return
            }
            showServiceDialog(with: items)
        }
    }
}
