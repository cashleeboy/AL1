//
//  UserBankListViewController.swift
//  AL1
//
//  Created by cashlee on 2026/1/6.
//

import UIKit



class UserBankListViewController: BaseTableViewController {
    let entry: UserBankListEntry
    
    var toModifyBankInfo: ((BankModel) -> Void)?
    
    init(entry: UserBankListEntry) {
        self.entry = entry
        
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var viewModel = UserBankLisViewModel()
    private var indexPathsToReload: [IndexPath] = [] {
        didSet {
            let hasSelection = dataSources.contains { ($0 as? UserBankCardItem)?.isSelected == true }
            bottomContainer.setPrimaryState(isEnable: hasSelection)
            if let idx = indexPathsToReload.first?.row,
                let item = dataSources[safe: idx] as? UserBankCardItem {
                viewModel.selectedBankCard = item
            }
        }
    }
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "lista de bancos"
        
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "Confirmar") { [weak self] in
            guard let self else { return }
            // 修改银行卡
            viewModel.queryBankInfo()
        }
        bottomContainer.configure(with: style)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF0
        tableView.backgroundColor = AppColorStyle.shared.backgroundWhiteF0
        tableView.register(UserBankCardTableViewCell.self, forCellReuseIdentifier: UserBankCardTableViewCell.baseIdentifier)
        tableView.register(AddBankCardTableViewCell.self, forCellReuseIdentifier: AddBankCardTableViewCell.baseIdentifier)
        
        configureTopBanner(with: "No use tarjeta bancaria de otras personas para evitar el fallo del préstamo.",
                           textColor: AppColorStyle.shared.brandPrimary)
        isShowTopBannerContainer = true
        
        isShowBottomButtonContainer = entry == .home ? true : false
        bottomContainer.setPrimaryState(isEnable: false)
        updateTableViewTop(to: .safeArea, animated: false)
        
        setupPullToRefresh()
        bindViewModel()
        
        setupTableFooterView()
    }
    
    override func refresh() {
        viewModel.fetchBankList()
    }
    
    func bindViewModel() {
        viewModel.$errorMassage
            .sink { [weak self] message in
                guard let self else { return }
                showToast(message)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$bankList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self, let items else { return }
                dataSources = items
                
                switch entry {
                case .home:
                    if let idx = items.firstIndex(where: { $0.isSelected == true }) {
                        let indexPath = IndexPath(row: idx, section: 0)
                        indexPathsToReload = [indexPath]
                    }
                default:
                    break
                }
                stopPullToRefresh()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$selectedBankModelItem
            .compactMap { $0 }
            .sink { [weak self] item in
                guard let self else { return }
                toModifyBankInfo?(item)
                self.navigationController?.popViewController(animated: true)
            }
            .store(in: &viewModel.cancellables)
    }
    
}

extension UserBankListViewController
{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSources.count < 5 {
            return dataSources.count + 1
        }
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSources.count < 5 && indexPath.row == dataSources.count {
            guard let addCell = tableView.dequeueReusableCell(withIdentifier: AddBankCardTableViewCell.baseIdentifier, for: indexPath) as? AddBankCardTableViewCell else {
                return UITableViewCell()
            }
            // 如果 AddBankCardTableViewCell 需要配置数据（如静态 Model），在此处调用
            // addCell.configure(with: ...)
            return addCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserBankCardTableViewCell.baseIdentifier, for: indexPath) as? UserBankCardTableViewCell else {
            return UITableViewCell()
        }
        if let item = dataSources[indexPath.row] as? UserBankCardItem {
            cell.configure(with: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if dataSources.count < 5 && indexPath.row == dataSources.count {
            // 1. 处理“添加银行卡”跳转逻辑
            navigateToAddBankCardPage()
        } else {
            // 2. 处理已有银行卡的选中逻辑
            switch entry {
            case .home:
                handleSelectedLogic(at: indexPath)
            default:
                break
            }
        }
    }
}

extension UserBankListViewController
{
    private func navigateToAddBankCardPage() {
        let vc = AddBankViewController()
        vc.refreshBankList = { [weak self] in
            guard let self else { return }
            startPullToRefresh()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSelectedLogic(at indexPath: IndexPath) {
        guard indexPath.row < dataSources.count,
              var clickedItem = dataSources[indexPath.row] as? SelectableItem else { return }

        let previousSelectedIndex = dataSources.firstIndex { item in
            return (item as? SelectableItem)?.isSelected == true
        }

        if clickedItem.isSelected {
            // 如果点击已选中的，则取消选中
            clickedItem.isSelected = false
            dataSources[indexPath.row] = clickedItem
            indexPathsToReload = [indexPath]
        } else {
            var paths: [IndexPath] = [indexPath]
            if let prevIdx = previousSelectedIndex {
                if var prevItem = dataSources[prevIdx] as? SelectableItem {
                    prevItem.isSelected = false
                    dataSources[prevIdx] = prevItem
                    paths.append(IndexPath(row: prevIdx, section: 0))
                }
            }
            clickedItem.isSelected = true
            dataSources[indexPath.row] = clickedItem
            indexPathsToReload = paths
        }

        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
    
    /// 配置 TableView Footer
    private func setupTableFooterView() {
        let footer = tableViewFooterView()
        
        let size = footer.systemLayoutSizeFitting(
            CGSize(width: tableView.frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        footer.frame = CGRect(origin: .zero, size: size)
        tableView.tableFooterView = footer
    }
    
    private func tableViewFooterView() -> UIView {
        let footerContainer = UIView()
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Puede agregar hasta 5 cuentas bancarias. Si no puede usar la tarjeta agregada, comuníquese con atención al cliente."
        label.textColor = UIColor(hex: "#A0A0A0")
        label.font = AppFontProvider.shared.getFont11Regular()
        label.textAlignment = .left // 根据 UI 习惯通常为左对齐
        
        footerContainer.addSubview(label)
        
        label.snp.makeConstraints { make in
            // 使用内边距，确保文字不会紧贴边缘，同时为底部留出呼吸空间
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        return footerContainer
    }
}
