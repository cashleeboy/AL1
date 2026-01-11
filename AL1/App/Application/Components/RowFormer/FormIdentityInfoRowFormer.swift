//
//  FormIdentityInfoRowFormer.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

protocol FormIdentityInfoFormableRow: FormableRow {
    func titleFormable() -> UILabel?
    func getIdentityButtonFormable() -> UIButton?
    func getHowToPicButton() -> UIButton?
    func updateIdentityStatus(with status: IdentityStauts, for image: UIImage?)
    func updateIdentityStatus(with status: IdentityStauts, url: String)
    func updateIdentityStatus(with status: IdentityStauts, imageSource: ImageSource?)
}

class FormIdentityInfoRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable where T: FormIdentityInfoFormableRow
{
    var title: String? {
        didSet {
            if let label = cell.titleFormable() {
                label.text = title
            }
        }
    }
    var onIdentityPreHandler: (() -> Void)?
    var onHowTakePicHandler: (() -> Void)?
    
    // identify status
    var isIdentityStatus: IdentityStauts = .unfinish
    //
    func updateIdentityStatus(with status: IdentityStauts, imageSource: ImageSource?) {
        isIdentityStatus = status
        cell.updateIdentityStatus(with: isIdentityStatus, imageSource: imageSource)
    }
    
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    func identityPreHandler(_ hander: @escaping (() -> Void)) -> Self {
        onIdentityPreHandler = hander
        return self
    }
    func howTakePicHandler(_ hander: @escaping (() -> Void)) -> Self {
        onHowTakePicHandler = hander
        return self
    }
    
    override func update() {
        super.update()
        
        if let btn = cell.getIdentityButtonFormable() {
            btn.addTarget(self, action: #selector(identityAction), for: .touchUpInside)
        }
        
        if let btn = cell.getHowToPicButton() {
            btn.addTarget(self, action: #selector(howToPicAction), for: .touchUpInside)
        }
    }
    
    @objc func identityAction() {
        guard isIdentityStatus != .success else {
            return 
        }
        onIdentityPreHandler?()
    }
    
    @objc func howToPicAction() {
        onHowTakePicHandler?()
    }
    
}

