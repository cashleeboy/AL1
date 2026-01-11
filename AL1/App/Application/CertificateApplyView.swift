//
//  CertificateApplyView.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit

class CertificateApplyView: BaseApplyViewController<CertificateModuleViewModel>
{
    //
    var identityInfoRowFormer: FormIdentityInfoRowFormer<FormIdentityInfoCell>? {
        get { moduleVM.identityInfoRow }
        set { moduleVM.identityInfoRow = newValue }
    }
    var selectionRowFormer: FormSelectionRowFormer<FormSelectionCell>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        moduleVM.isDataCompletePublisher
//            .compactMap { $0 }
//            .sink { [weak self] isDone in
//                guard let self else { return }
//                self.bottomContainer.setPrimaryState(isEnable: isDone)
//            }
//            .store(in: &moduleVM.cancellables)

        moduleVM.$identityStatus
            .compactMap { $0 }
            .sink { [weak self] status in
                guard let self else { return }
                self.identityInfoRowFormer?.updateIdentityStatus(with: status, imageSource: ImageSource.none)
                switch status {
                case .failure:
                    bottomContainer.setPrimaryState(with: "Vuelva a tomarla")
                case .success:
                    bottomContainer.setPrimaryState(with: "Confirmar")
                default:
                    // unfinish
                    bottomContainer.setPrimaryState(with: "Próximo paso")
                    break
                }
            }
            .store(in: &moduleVM.cancellables)
        
//        moduleVM.fetchData { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case .success(let data):
//                if !data.frontUrl.isEmpty {
//                    self.identityInfoRowFormer?.updateIdentityStatus(with: .success, imageSource: .remote(data.frontUrl))
//                }
//                if !data.idCardNumber.isEmpty {
//                    showIdentifyRows(with: data)
//                }
//                break
//            case .failure(_):
//                break
//            }
//        }
    }
    
    override func loadFormer() {
        super.loadFormer()
        
        identityInfoRowFormer = FormIdentityInfoRowFormer<FormIdentityInfoCell>(instantiateType: .Class) { cell in
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }.identityPreHandler { [weak self] in
            guard let self else { return }
            returnToTake()
        }.howTakePicHandler { [weak self] in
            guard let self else { return }
            showRecognizeSheet {
                self.returnToTake()
            }
        }
        if let identityInfoRowFormer {
            selectionFormer.add(rowFormers: [identityInfoRowFormer])
        }
        former.append(sectionFormer: selectionFormer)
    }
    
    override func bottomAction() {
        // 校验提示
        if let verifyResult = self.moduleVM.validate() {
            switch verifyResult {
            case .ocr, .nuiNumber:
                showToast("Complete su número de cédula de identidad")
            case .name:
                showToast("Por favor, complete su nombre")
            case .lastName:
                showToast("Por favor, complete su apellido paterno")
            case .genero:
                showToast("Por favor seleccione su género")
            case .birthday:
                showToast("Por favor seleccione su fecha de nacimiento")
            default:
                break
            }
            return
        }
        let getTextByType: (PersonalType) -> String = { type in
            let row = self.moduleVM.certRows.first {
                ($0 as? FormSelectionRowFormer<FormSelectionCell>)?.infoModel?.type == type
            } as? FormSelectionRowFormer<FormSelectionCell>
            return row?.filedText ?? ""
        }
        let items = [
            ConfirmItem(title: "Nombre y Apellido：", content: getTextByType(.name)),
            ConfirmItem(title: "Número de identificación：", content: getTextByType(.nuiNumber))
        ]
        showInformation(with: "verifique su información de identidad", items: items) { [weak self] in
            guard let self else { return }
            notifyStepFinished()
        }
    }
}


extension CertificateApplyView {
    // return to take
    private func returnToTake() {
        showUploadPhotoSheet { [weak self] source in
            guard let self else { return }
            
            let type: PermissionType = (source == .camera) ? .camera : .photoLibrary
            PermissionsManager.shared.requestPermission(for: type) { granted, isFirst in
                if granted {
                    self.handleSourceAction(source, isFirst: isFirst)
                } else {
                    self.showPermissionAlert(for: type, viewControllerToPresent: self)
                }
            }
        }
    }
    
    private func handleSourceAction(_ source: PhotoSource, isFirst: Bool) {
        switch source {
        case .camera:
            // 这里的 delay 逻辑保留，用于处理相机启动冲突
            let delay: TimeInterval = isFirst ? 1.5 : 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                ShootCoverViewController.push(from: self.navigationController, orientation: .landscapeLeft) { [weak self] image in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.processIdentityImage(image, from: .camera)
                    }
                }
            }
        case .gallery:
            ImagePickerManager.shared.openGallery(from: self) { [weak self] selectedImage in
                guard let self = self, let image = selectedImage else { return }
                self.processIdentityImage(image, from: .gallery)
            }
        }
    }
    
    /// 统一处理图片提取后的业务逻辑
    private func processIdentityImage(_ image: UIImage, from source: PhotoSource) {
        self.moduleVM.currentImage = image
        self.moduleVM.photoSource = source
        
        moduleVM.submitOcrData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                let status: IdentityStauts = data.isSuccess ? .success : .failure
                self.identityInfoRowFormer?.updateIdentityStatus(with: status, imageSource: .local(image))
                if status == .success {
                    self.showIdentifyRows(with: data)
                } else if status == .failure {
                    showRecognizeSheet { }
                }
            case .failure(let error):
                self.identityInfoRowFormer?.updateIdentityStatus(with: .failure, imageSource: ImageSource.none)
                showRecognizeSheet { }
                self.showToast(error.message)
            }
        }
    }
}

extension CertificateApplyView {    
    // show identity rows
    private func showIdentifyRows(with result: OCRDataProtocol?) {
        if moduleVM.certRows.isEmpty {
            let fieldModels = moduleVM.orcInfoFields()
            // 2. 将模型转换为对应的 Former Row
            moduleVM.certRows = fieldModels.map { model -> RowFormer in
                switch model.fieldType {
                case .gender:
                    return createGenderRow(for: model, with: result)
                default:
                    return createSelectionRow(for: model, with: result)
                }
            }
            selectionFormer.add(rowFormers: moduleVM.certRows)
        } else {
            moduleVM.certRows.forEach { row in
                if let generoRow = row as? FormGeneroRowFormer<FormGeneroCell> {
                    if let result, let info = generoRow.infoModel {
                        generoRow.currentGener = GeneroType.genders(with: result.gender)
                        moduleVM.updateCertValue(for: info, value: result.gender)
                    }
                } else if let identityRow = row as? FormSelectionRowFormer<FormSelectionCell> {
                    if let info = identityRow.infoModel,
                        let data = result,
                        let keyPath = info.type.ocrKeyPath {
                        identityRow.filedText = data[keyPath: keyPath]
                        
                        moduleVM.updateCertValue(for: info, value: data[keyPath: keyPath])
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - 构建性别行
    private func createGenderRow(for model: IdentityInfoModel, with result: OCRDataProtocol?) -> RowFormer {
        let generoRow = FormGeneroRowFormer<FormGeneroCell>(instantiateType: .Class) { cell in
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }.selectedGeneroHandler { [weak self] type in
            guard let self else { return }
            genderDidChanged(for: model, type: type)
        }
        moduleVM.certRows.append(generoRow)
        if let gender = result?.gender, !gender.isEmpty {
            generoRow.currentGener = GeneroType.genders(with: gender)
        }
        return generoRow
    }
    
    // MARK: - 构建通用选择行 (单选或地址)
    private func createSelectionRow(for model: IdentityInfoModel, with result: OCRDataProtocol?) -> RowFormer {
        let row = FormSelectionRowFormer<FormSelectionCell>(instantiateType: .Class) { cell in
        }.configure { cell in
            cell.rowHeight = UITableView.automaticDimension
        }.selectionFieldHandler { [weak self] currentRow in
            guard let self else { return }
            view.endEditing(true)
            if model.fieldType == .birth {
                showDateSheet { date in
                    let dateString = MZDateUtil.string(from: date)
                    
                    if let filter = self.moduleVM.certRows.filter({ filterRow in
                        if let filter = filterRow as? FormSelectionRowFormer<FormSelectionCell> {
                            return filter.infoModel?.type == model.type
                        }
                        return false
                    }).first as? FormSelectionRowFormer<FormSelectionCell> {
                        filter.filedText = dateString
                    }
                    self.pickerDidSelected(for: model, value: dateString)
                }
            }
        }.textFieldTextHandler { [weak self] currentRow, text in
            guard let self, let text else { return }
            currentRow.filedText = text
            self.pickerDidSelected(for: model, value: text)
        }
        row.infoModel = model
        if let data = result, let keyPath = model.type.ocrKeyPath {
            row.filedText = data[keyPath: keyPath]
            moduleVM.updateCertValue(for: model, value: data[keyPath: keyPath])
        }
        return row
    }
    
    // 性别选择回调
    private func genderDidChanged(for info: IdentityInfoModel, type: GeneroType) {
        moduleVM.updateCertValue(for: info, value: type.genderValue)
    }

    // 其他选择回调
    private func pickerDidSelected(for info: IdentityInfoModel, value: String) {
        moduleVM.updateCertValue(for: info, value: value)
    }

}
