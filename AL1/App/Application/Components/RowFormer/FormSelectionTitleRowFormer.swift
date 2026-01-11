//
//  FormSelectionTitleRowFormer.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

protocol FormSelectionTitleFormableRow: FormableRow {
    func titleFormable() -> UILabel?
}

class FormSelectionTitleRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable where T: FormSelectionTitleFormableRow
{
    var title: String? {
        didSet {
            if let label = cell.titleFormable() {
                label.text = title
            }
        }
    }
    var attributedTitle: String? {
        didSet {
            if let label = cell.titleFormable(), let string = attributedTitle {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                let attributedString = NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle])
                label.attributedText = attributedString
            }
        }
    }
    
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
        
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    override func update() {
        super.update()
    }
}

