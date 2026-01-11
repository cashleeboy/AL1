//
//  FormGeneroRowFormer.swift
//  AL1
//
//  Created by cashlee on 2025/12/19.
//

import UIKit

enum GeneroType: Int, CaseIterable {
    case Hombre = 1        // 男
    case Mujer = 2         // 女
    
    var title: String {
        switch self {
        case .Hombre: return "Hombre"
        case .Mujer:  return "Mujer"
        }
    }
    
    var genderValue: String {
        switch self {
        case .Hombre: return "1"
        case .Mujer: return "2"
        }
    }
    
    var option: IdentityOption {
        return IdentityOption(key: self.rawValue, value: self.title)
    }
    
    // 静态属性：直接作为数据源提供给 Picker
    static var allOptions: [IdentityOption] {
        return self.allCases.map { $0.option }
    }
    
    static func genders(with gender: String) -> GeneroType {
        if let val = Int(gender), let type = GeneroType(rawValue: val) {
            return type
        }
        return .Hombre
    }
}

class FormGeneroRowFormer<T: UITableViewCell>: BaseRowFormer<T>, IdentityFormRow, Formable where T: FormableRow
{
    var onSelectedGeneroHandler: ((GeneroType) -> Void)?
    var infoModel: IdentityInfoModel?
    var currentGener: GeneroType? {
        didSet {
            cell.updateWithRowFormer(self)
        }
    }
    
    required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    override func cellInitialized(_ cell: T) {
        super.cellInitialized(cell)
    }
    
    func selectedGeneroHandler(_ handler: @escaping ((GeneroType) -> Void)) -> Self {
        onSelectedGeneroHandler = handler
        return self
    }
    
    override func update() {
        super.update()
        if let generoCell = cell as? FormGeneroCell {
            generoCell.onSelectGenero = { [weak self] type in
                guard let self else { return }
                currentGener = type
                self.onSelectedGeneroHandler?(type)
            }
        }
    }
}

