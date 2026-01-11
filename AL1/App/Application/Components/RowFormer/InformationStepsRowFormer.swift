//
//  InformationStepsRowFormer.swift
//  AL1
//
//  Created by cashlee on 2025/12/18.
//

import UIKit

protocol InformationStepsFormableRow: FormableRow
{
    func updateStep(with type: InfoReviewType)
}

class InformationStepsRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable where T: InformationStepsFormableRow
{
    var reviewType: InfoReviewType = .personal
    
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    override func update() {
        super.update()
        cell.updateStep(with: reviewType)
    }
}
