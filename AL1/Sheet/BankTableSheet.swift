//
//  BankTableSheet.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import UIKit
import SnapKit

class BankTableSheet: BaseSheet {
    // MARK: - Constants
    private let rowHeight: CGFloat = 56.0

    // MARK: - Properties
    private var allBanks: [BankModel] = []       // 原始数据源
    private var filteredBanks: [BankModel] = []  // 搜索后的数据源
    
    var onSelected: ((BankModel) -> Void)?
    
    // MARK: - UI Components

    private lazy var textField: AppInputTextField = {
        let textField = AppInputTextField()
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(hex: "#F8F8F8")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: "#9092A1"),
            .font: AppFontProvider.shared.getFont13Regular()
        ]
        let attributedString = NSAttributedString(string: "Buscar el nombre del banco", attributes: attributes)
        textField.attributedPlaceholder = attributedString
        textField.setLeftIcon(UIImage(named: "textField_left_icon"))
        
        // 设置右侧按钮为 rightButton
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 32))
        rightButton.frame = CGRect(x: 0, y: 0, width: 72, height: 32)
        container.addSubview(rightButton)
        textField.rightView = container
        textField.rightViewMode = .always
        return textField
    }()

    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = AppColorStyle.shared.brandPrimary
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFontProvider.shared.getFont14Semibold()
        button.setTitle("Buscar", for: .normal)
        button.addTarget(self, action: #selector(handleSearchAction), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableV = UITableView(frame: .zero, style: .plain)
        tableV.delegate = self
        tableV.dataSource = self
        tableV.separatorStyle = .none
        tableV.rowHeight = 56
        tableV.register(BankCell.self, forCellReuseIdentifier: "BankCell")
        return tableV
    }()
    
    // MARK: - Setup
    override func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        titleLabel.text = "Seleccionar un Banco"
        
        contentView.addSubview(textField)
        contentView.addSubview(tableView)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0).priority(250)
        }
        
        // 搜索实时逻辑
        textField.textChanged = { [weak self] text in
            guard let self else { return }
            // 取消之前的待执行任务，防止频繁刷新
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(self.executeSearch(_:)), with: text, afterDelay: 0.25)
        }
    }
    
    @objc private func executeSearch(_ text: String?) {
        let filterText = text?.trimmed
        filterContentForSearchText(filterText)
    }

    // MARK: - Public Method
    func updateData(banks: [BankModel]) {
        self.allBanks = banks
        self.filteredBanks = banks
        self.tableView.reloadData()
        
        // 2. 动态计算并更新高度
        updateSheetHeight(count: banks.count)
    }

    private func updateSheetHeight(count: Int) {
        self.layoutIfNeeded()
        let screenHeight = UIScreen.main.bounds.height
        let minH = screenHeight * 0.5
        let maxH = screenHeight * 0.65
        
        let contentHeight = CGFloat(count) * rowHeight
        let finalHeight = max(minH, min(contentHeight, maxH))
        tableView.snp.updateConstraints { make in
            make.height.equalTo(finalHeight).priority(250)
        }
    }
    
    // MARK: - Actions
    @objc private func handleSearchAction() {
        endEditing(true)
        performSearch(with: textField.text ?? "")
    }

    private func filterContentForSearchText(_ searchText: String?) {
        guard let searchText else { return }
        if searchText.isEmpty {
            filteredBanks = allBanks
        } else {
            filteredBanks = allBanks
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
        tableView.reloadData()
    }
    
    private func filterBanks(with text: String) {
        filteredBanks = text.isEmpty ? allBanks : allBanks.filter { $0.name.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }
    
    private func performSearch(with text: String?) {
        let query = (text ?? "").lowercased().trimmingCharacters(in: .whitespaces)
        
        if query.isEmpty {
            filteredBanks = allBanks
        } else {
            filteredBanks = allBanks.filter { $0.name.lowercased().contains(query) }
        }
        
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate & DataSource
extension BankTableSheet: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBanks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankCell", for: indexPath) as! BankCell
        let model = filteredBanks[indexPath.row]
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = filteredBanks[indexPath.row].id
        
        for i in 0..<filteredBanks.count {
            filteredBanks[i].isSelected = (filteredBanks[i].id == selectedId)
        }
        
        for i in 0..<allBanks.count {
            allBanks[i].isSelected = (allBanks[i].id == selectedId)
        }
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
            let selectedModel = filteredBanks[indexPath.row]
            onSelected?(selectedModel)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       endEditing(true)
    }
}

// MARK: - Custom Cell
class BankCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let selectIcon = UIImageView()
    private let line = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        nameLabel.font = AppFontProvider.shared.getFont15Regular()
        nameLabel.textColor = AppColorStyle.shared.textBlack
        
        selectIcon.image = UIImage(named: "bank_selected_icon")
        selectIcon.contentMode = .scaleAspectFit
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(selectIcon)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(selectIcon.snp.leading).offset(-10)
            make.top.bottom.equalToSuperview().inset(12)
        }

        selectIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with model: BankModel) {
        nameLabel.text = model.name
        selectIcon.isHidden = !model.isSelected
    }
}
