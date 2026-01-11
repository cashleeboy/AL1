//
//  AddBankViewController.swift
//  AL1
//
//  Created by cashlee on 2026/1/8.
//

import UIKit

class AddBankViewController: BaseFormerViewController {

    var refreshBankList: (() -> Void)?
    private var selectedIdentityInfo: IdentityInfoModel?
    private var bankConfigModel: BankConfigModel?
    
    private lazy var viewModel = AddBankViewModel()
    
    private lazy var topBanner = TopBannerContainer(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
    private lazy var bottomContainer: BottomButtonContainer = {
        let bottom = BottomButtonContainer()
        bottom.configure(with: .customContentView(primaryTitle: "Próximo paso", topContentView: nil, bottomContentView: sslContainerView(), primaryAction: { [weak self] in
            guard let self else { return }
            bottomAction()
        }))
        return bottom
    }()
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "Añadir cuenta bancaria"
        
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = AppColorStyle.shared.backgroundWhite
        view.addSubview(topBanner)
        topBanner.updateBannerStatus(text: "No use tarjeta bancaria de otras personas para evitar el fallo del préstamo.", textColor: AppColorStyle.shared.brandPrimary)
        topBanner.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        view.addSubview(bottomContainer)
        bottomContainer.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        view.layoutIfNeeded()
        
        let topOffset = NavigationUtility.totalTopSafeAreaHeight() * 1
        updateTableViewConstraints(
            top: topOffset + CGRectGetMaxY(topBanner.frame),
            bottom: bottomContainer.frame.height,
            leading: 0,
            trailing: 0,
            pinToScreenTop: true
        )
        
        bindViewModel()
        viewModel.fetchBankListQuery()

    }
    
    override func loadFormer() {
        let list = viewModel.bankInfoFields()
        viewModel.bankRows = list.map { model in
            let row = FormSelectionRowFormer<FormSelectionCell>(instantiateType: .Class) { cell in
            }.configure { cell in
                cell.rowHeight = UITableView.automaticDimension
            }.selectionFieldHandler { [weak self] currentRow in
                guard let self else { return }
                switch model.fieldType {
                case .choose:
                    selectedIdentityInfo = model
//                    // TODO: selectRows
                    let selectRows: [Int] = []
                    showPickerSheet(delegate: self, dataSource: self, nameTitle: model.type.display, confirmTitle: "Confirmar", selectedRows: selectRows)
                case .bankName:
                    guard let bankConfigModel else {
                        return
                    }
                    showBankSheet(wiht: bankConfigModel.bankList) { selectItem in
                        self.viewModel.updateBankValue(for: model, value: nil, map: [
                            BackendUserBankInfoKeys.bankName: selectItem.name,
                            BackendUserBankInfoKeys.bankId: selectItem.id
                        ], displayText: selectItem.name)
                    }
                default:
                    break
                }
            }.highLightHandler { [weak self] in
                guard let self else { return }
                // cci
                showCCIDialog()
            }.textFieldTextHandler { [weak self] currentRow, text in
                guard let self, let text else { return }
                viewModel.updateBankValue(for: model, value: text, map: nil, displayText: text)
            }
            row.infoModel = model
            return row
        }
        
        let headerFormer = CustomViewFormer<FormHeaderFooterView>()
            .configure { $0.viewHeight = 0 }
        let selection = SectionFormer().set(headerViewFormer: headerFormer)
        selection.add(rowFormers: viewModel.bankRows)
        former.append(sectionFormer: selection)
    }
    
    func bottomAction() {
        // add bank
        viewModel.submitBankInfo()
    }
}


extension AddBankViewController: MZPickerControllerDelegate, MZPickerControllerDataSource {
    func numberOfComponents(in picker: MZPickerController) -> Int {
        guard selectedIdentityInfo?.fieldType == .bankName else {
            return selectedIdentityInfo?.options.count ?? 0 > 0 ? 1 : 0
        }
        return bankConfigModel?.bankList.count ?? 0 > 0 ? 1 : 0
    }
    
    func picker(_ picker: MZPickerController, numberOfRowsInComponent component: Int) -> Int  {
        guard selectedIdentityInfo?.fieldType == .bankName else {
            return selectedIdentityInfo?.options.count ?? 0
        }
        return bankConfigModel?.bankList.count ?? 0
    }
    
    func picker(_ picker: MZPickerController, titleForRow row: Int, forComponent component: Int) -> String {
        if selectedIdentityInfo?.fieldType == .bankName {
            guard let list = bankConfigModel?.bankList, list.indices.contains(row) else {
                return ""
            }
            return list[row].bankName
        }
        if let options = selectedIdentityInfo?.options, options.indices.contains(row) {
            return options[row].value
        }
        return ""
    }
    
    func picker(_ picker: MZPickerController, didSelect rows: [Int]) {
        dismiss()
        guard let selectedIdx = rows.first, let currentInfo = selectedIdentityInfo else { return }
        
        guard currentInfo.options.indices.contains(selectedIdx) else { return }
        let option = currentInfo.options[selectedIdx]
        // 更新数据: 这里传option.key
        viewModel.updateBankValue(for: currentInfo, value: String(option.key), map: nil, displayText: option.value)
    }
    
    func picker(_ picker: MZPickerController, widthForComponent component: Int) -> CGFloat {
        let screenWidth = view.frame.size.width
        return screenWidth
    }
    
    func picker(_ picker: MZPickerController, rowHeightForComponent component: Int) -> CGFloat {
        40
    }
}


extension AddBankViewController
{
    private func bindViewModel() {
        viewModel.$errorMassage
            .sink { [weak self] message in
                guard let self else { return }
                showToast(message)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$isDataComplete
            .compactMap { $0 }
            .sink { [weak self] isDone in
                guard let self else { return }
                bottomContainer.setPrimaryState(isEnable: isDone)
            }
            .store(in: &self.viewModel.cancellables)
    
        viewModel.$bankConfigModel
            .compactMap { $0 }
            .sink { [weak self] model in
                guard let self else { return }
                bankConfigModel = model
            }
            .store(in: &self.viewModel.cancellables)
        
        viewModel.$isSubmitSuccess
            .compactMap { $0 }
            .sink { [weak self] isScucess in
                guard let self else { return }
                if isScucess {
                    refreshBankList?()
                    navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &self.viewModel.cancellables)
    }
    
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

extension AddBankViewController: AuthDialogPresentable { }
