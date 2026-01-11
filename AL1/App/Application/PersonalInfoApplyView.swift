//
//  PersonalInfoApplyView.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

class PersonalInfoApplyView: BaseApplyViewController<PersonalInfoModuleViewModel>
{
    private var selectedIdentityInfo: IdentityInfoModel?
    // 1. 预加载数据
    var configModel: RegionConfigModel?
    var personalInfoModel: PersonalInformationModel?
    
    private var personalInfoFields: [IdentityInfoModel]?
    private lazy var emailSuggestView = EmailRecommendationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomContainer.setPrimaryState(isEnable: true)

        moduleVM.fetchData { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                personalInfoModel = data.personalDetail
                var isUnemployed = true
                if personalInfoModel?.jobType == "4" {
                    isUnemployed = false
                }
                // remove Unemployed row
                if isUnemployed == false {
                    if let incomeRowIndex = moduleVM.filedRows.firstIndex(where: { row in
                        row.infoModel?.type == .monthlyIncome
                    }) {
                        removeMonthlyIncomeRow(at: incomeRowIndex)
                    }
                }
                moduleVM.filedRows.forEach { row in
                    guard let type = row.infoModel?.type else { return }
                    switch type {
                    case .education, .marriage, .monthlyIncome, .jobType:
                        if let keyString = data.personalDetail.valuesMap[type] {
                            row.keyStrings = [keyString]
                            row.filedText = type.getDisplayValue(for: keyString)
                        }
                    case .email:
                        if let keyString = data.personalDetail.valuesMap[.email] {
                            row.keyStrings = [keyString]
                            row.filedText = data.personalDetail.emial
                        }
                    default:
                        break
                    }
                }
                tableView.reloadData()
                loadLocalConfigAndSetupUI()
            case .failure(let error):
                showToast(error.message)
            }
        }
        
        let first = UserSession.shared.firstIdentityInfo
        if first == nil || first == false {
            // show first identity
            showRewardDialog {
                UserSession.shared.firstIdentityInfo = true
            }
        }
        
    }
    
    private func loadLocalConfigAndSetupUI() {
        // 异步加载沙盒数据并初始化界面
        SandboxManager.shared.loadRegionConfigAsync { [weak self] model in
            guard let self else { return }
            configModel = model
            
            if let addressRow = moduleVM.filedRows.filter({ row in
                return row.infoModel?.fieldType == .address
            }).first {
                let pId = personalInfoModel?.homeProvince
                let cId = personalInfoModel?.homeCity
                var addressParts: [String] = []
                var keyStrings: [String] = []
                if let province = model?.provinces.first(where: { $0.id == pId }) {
                    keyStrings.append(province.id)
                    addressParts.append(province.name)
                }
                if let city = model?.regions.first(where: { $0.id == cId }) {
                    keyStrings.append(city.id)
                    addressParts.append(city.name)
                }
                let displayText = addressParts.joined(separator: ", ")
                addressRow.filedText = displayText
                addressRow.keyStrings = keyStrings
            }
        }
    }
    
    override func loadFormer() {
        super.loadFormer()
        
        let list = moduleVM.personalInfoFields()
        personalInfoFields = list
        // 1. 抽离创建逻辑
        moduleVM.filedRows = list.map {
            createSelectionRow(with: $0)
        }
        
        filedSectionFormer.add(rowFormers: moduleVM.filedRows)
        former.append(sectionFormer: selectionFormer, filedSectionFormer)
        
    }
    
    override func bottomAction() {
        guard self.moduleVM.validate() else {
            // 进行页面所有项的校验
            moduleVM.filedRows.forEach { row in
                var isTextEmpty = true
                switch row.infoModel?.type {
                case .email:
                    if let valid = row.filedText?.isValidEmail() {
                        isTextEmpty = valid ? false : true
                    }
                default:
                    isTextEmpty = row.filedText?.isEmpty ?? true
                }
                if isTextEmpty {
                    row.fileStatus = .showRedError(message: row.infoModel?.fieldType.holderName ?? "Por favor elija")
                } else {
                    row.fileStatus = .normal
                }
            }
            tableView.reloadData()
            return
        }
        // submit info
        notifyStepFinished()
    }
}

extension PersonalInfoApplyView
{
    // MARK: - 创建 Row
    private func createSelectionRow(with model: IdentityInfoModel) -> FormSelectionRowFormer<FormSelectionCell> {
        let row = FormSelectionRowFormer<FormSelectionCell>(instantiateType: .Class) { cell in
            // 如果没有展示，则将其添加到页面中
            if self.emailSuggestView.superview == nil {
                self.view.addSubview(self.emailSuggestView)
            }
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }.selectionFieldHandler { [weak self] currentRow in
            guard let self else { return }
            view.endEditing(true)
            handleSelectionFieldTap(currentRow: currentRow)
        }.textFieldTextHandler { [weak self] currentRow, text in
            guard let self, let text else { return }
            switch currentRow.infoModel?.type {
            case .email:
                if text.isEmpty {
                    self.emailSuggestView.isHidden = true
                    return
                }
                if let key = model.keys.values.first {
                    self.moduleVM.updateWithText(for: model, text: text, keyString: key)
                }
                let rectInView = self.tableView.convert(currentRow.cell.frame, to: self.view)
                self.emailSuggestView.frame = CGRectMake(
                    CGRectGetMinX(rectInView),
                    CGRectGetMinY(rectInView) - EmailRecommendationView.emailRecommendHeight,
                    CGRectGetWidth(rectInView),
                    EmailRecommendationView.emailRecommendHeight
                )
                
                emailSuggestView.isHidden = false
                emailSuggestView.updatePrefix(text)
                emailSuggestView.onEmailSelected = { [weak self] fullEmail in
                    self?.emailSuggestView.isHidden = true
                    if let key = model.keys.values.first {
                        self?.moduleVM.updateWithText(for: model, text: fullEmail, keyString: key)
                    }
                    currentRow.filedText = fullEmail
                }
            default:
                break
            }
        }.textFieldDidEndEditHandler { [weak self] text in
            guard let self else { return }
            emailSuggestView.isHidden = true
        }
        row.infoModel = model
        return row
    }

    private func handleSelectionFieldTap(currentRow: FormSelectionRowFormer<FormSelectionCell>) {
        guard let model = currentRow.infoModel else { return }
        
        switch model.fieldType {
        case .choose, .address:
            selectedIdentityInfo = model
            let selectRows = calculateSelectedRows(for: currentRow)
            
            showPickerSheet(
                delegate: self,
                dataSource: self,
                nameTitle: model.type.display,
                confirmTitle: "Confirmar",
                selectedRows: selectRows
            )
        default:
            break
        }
    }

    private func calculateSelectedRows(for currentRow: FormSelectionRowFormer<FormSelectionCell>) -> [Int] {
        var selectRows: [Int] = []
        let keys = currentRow.keyStrings ?? []
        
        if currentRow.infoModel?.fieldType == .address {
            if let first = keys.first, let index = configModel?.getProvinceIndex(id: first) {
                selectRows.append(index)
                if let last = keys.last, let index = configModel?.getRegionIndex(id: last, provinceId: first) {
                    selectRows.append(index)
                }
            }
        } else {
            keys.forEach { key in
                if let index = currentRow.infoModel?.type.getIndexValue(for: key) {
                    selectRows.append(index)
                }
            }
        }
        return selectRows
    }
    
    /// 专门处理字段间的联动依赖
    private func handleDependencyLogic(for currentInfo: IdentityInfoModel, selectedOption option: IdentityOption) {
        // 仅处理职业类型的特殊联动
        guard currentInfo.type == .jobType else { return }
        let isUnemployed = (option.key == 4) // 封装判断逻辑
        // 查找月收入行的当前索引（封装重复代码）
        let incomeRowIndex = moduleVM.filedRows.firstIndex { row in
            row.infoModel?.type == .monthlyIncome
        }
        if isUnemployed {
            if let index = incomeRowIndex {
                removeMonthlyIncomeRow(at: index)
            }
        } else {
            if incomeRowIndex == nil {
                addMonthlyIncomeRow()
                moduleVM.updateValue(for: currentInfo, selectedOption: option)
            }
        }
    }
    
    private func removeMonthlyIncomeRow(at index: Int) {
        filedSectionFormer.remove(atIndex: index)
        moduleVM.filedRows.remove(at: index)
        if let model = personalInfoFields?.first(where: { $0.type == .monthlyIncome }) {
            moduleVM.removeValue(with: Array(model.keys.values))
        }
    }

    private func addMonthlyIncomeRow() {
        guard let model = personalInfoFields?.first(where: { $0.type == .monthlyIncome }) else { return }
        
        let row = createSelectionRow(with: model)
        moduleVM.filedRows.append(row)
        filedSectionFormer.add(rowFormers: [row])
    }
    
    private func handleUnFinishLogic() {
        // 选择成功一项后自动弹出下一个未选择的信息选择项
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let unFinishRow = self.moduleVM.filedRows.first { row in
                let isTextEmpty = row.filedText?.isEmpty ?? true
                let isKeysEmpty = row.keyStrings?.isEmpty ?? true
                return isTextEmpty || isKeysEmpty
            }
            if let row = unFinishRow {
                self.handleSelectionFieldTap(currentRow: row)
            }
        }
    }
}

extension PersonalInfoApplyView: MZPickerControllerDelegate, MZPickerControllerDataSource {
    func numberOfComponents(in picker: MZPickerController) -> Int {
        guard selectedIdentityInfo?.fieldType == .address else {
            return selectedIdentityInfo?.options.count ?? 0 > 0 ? 1 : 0
        }
        return configModel?.count ?? 0
    }
    
    func picker(_ picker: MZPickerController, numberOfRowsInComponent component: Int) -> Int  {
        guard selectedIdentityInfo?.fieldType == .address else {
            return selectedIdentityInfo?.options.count ?? 0
        }
        guard let config = configModel else { return 0 }
        
        if component == 0 {
            return config.provinces.count
        } else {
            let selectedProvinceIdx = picker.selectedRow(in: 0)
            if let province = config.item(at: 0, row: selectedProvinceIdx) {
                return config.getRegions(forProvinceId: province.id).count
            }
        }
        return 0
    }
    
    func picker(_ picker: MZPickerController, titleForRow row: Int, forComponent component: Int) -> String {
        guard selectedIdentityInfo?.fieldType == .address else {
            if let options = selectedIdentityInfo?.options, options.indices.contains(row) {
                return options[row].value
            }
            return ""
        }
        guard let config = configModel else { return "" }
        
        if component == 0 {
            return config.item(at: 0, row: row)?.name ?? ""
        } else {
            let selectedProvinceIdx = picker.selectedRow(in: 0)
            if let province = config.item(at: 0, row: selectedProvinceIdx) {
                let cities = config.getRegions(forProvinceId: province.id)
                return cities.indices.contains(row) ? cities[row].name : ""
            }
        }
        return ""
    }
    
    func picker(_ picker: MZPickerController, didSelect rows: [Int]) {
        dismiss()
        
        guard let currentInfo = selectedIdentityInfo else { return }
        guard currentInfo.fieldType == .address else {
            guard let selectedIdx = rows.first,
                  currentInfo.options.indices.contains(selectedIdx) else { return }
            
            let option = currentInfo.options[selectedIdx]
            moduleVM.updateValue(for: currentInfo, selectedOption: option)
            // 处理失业逻辑
            handleDependencyLogic(for: currentInfo, selectedOption: option)
            tableView.reloadData()
            
            handleUnFinishLogic()
            return
        }

        guard let config = configModel, rows.count >= 2 else { return }
        
        let provinceIdx = rows[0]
        let cityIdx = rows[1]
        
        guard let province = config.item(at: 0, row: provinceIdx) else { return }
        
        let cities = config.getRegions(forProvinceId: province.id)
        guard cities.indices.contains(cityIdx) else { return }
        let city = cities[cityIdx]

        let displayAddress = "\(province.name), \(city.name)"
        
        moduleVM.updateAddressValue(for: currentInfo,
                                    provinceId: province.id,
                                    cityId: city.id,
                                    displayText: displayAddress)
        
        handleUnFinishLogic()
    }
    
    func picker(_ picker: MZPickerController, widthForComponent component: Int) -> CGFloat {
        guard let currentInfo = selectedIdentityInfo else { return 0.0 }
        let screenWidth = view.frame.size.width
        if currentInfo.fieldType != .address {
            return screenWidth
        }

        let componentCount = CGFloat(configModel?.count ?? 2)
        let baseWidth = screenWidth / componentCount
        if component == 0 {
            return baseWidth * 0.9
        } else {
            return baseWidth * 1.0
        }
    }
    
    func picker(_ picker: MZPickerController, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
}
