//
//  MZPickerController.swift
//  MZDatePicker
//
//  Created by 曾龙 on 2021/12/27.
//

import UIKit

open class MZPickerController: UIViewController, MZPickerViewDataSource, MZPickerViewDelegate {

    /// MZPickerController数据源
    public weak var dataSource: MZPickerControllerDataSource?
    
    /// MZPickerController代理
    public weak var delegate: MZPickerControllerDelegate?
    
    var allowSelectClosure: Bool = false
    var onDismiss: (() -> Void)?
    /// 取消按钮标题
    public var nameTitle: String? {
        didSet {
            if nameTitle != nil {
                nameLabel.text = nameTitle
            }
        }
    }
    /// 取消按钮标题
    public var cancelTitle: String? {
        didSet {
            if cancelTitle != nil {
                cancelBtn.setTitle(cancelTitle, for: .normal)
            }
        }
    }
    /// 取消按钮标题
    public var cancelImage: UIImage? {
        didSet {
            if cancelImage != nil {
                cancelBtn.setImage(cancelImage, for: .normal)
            }
        }
    }
    
    /// 确定按钮标题
    public var confirmTitle: String? {
        didSet {
            if confirmTitle != nil {
                confirmBtn.setTitle(confirmTitle, for: .normal)
            }
        }
    }
    
    /// 取消按钮标题颜色
    public var cancelColor: UIColor? {
        didSet {
            if cancelColor != nil {
                cancelBtn.setTitleColor(cancelColor, for: .normal)
            }
        }
    }
    
    /// 确认按钮标题颜色
    public var confirmColor: UIColor? {
        didSet {
            if confirmColor != nil {
                confirmBtn.setTitleColor(confirmColor, for: .normal)
            }
        }
    }
    
    /// 未选中颜色
    public var normalColor: UIColor? {
        didSet {
            if normalColor != nil {
                pickerView.normalColor = normalColor!
            }
        }
    }
    
    /// 选中颜色
    public var selectedColor: UIColor? {
        didSet {
            if selectedColor != nil {
                pickerView.selectedColor = selectedColor!
            }
        }
    }
    
    /// 未选中字体
    public var normalFont: UIFont? {
        didSet {
            if normalFont != nil {
                pickerView.normalFont = normalFont!
            }
        }
    }
    
    /// 选中字体
    public var selectedFont: UIFont? {
        didSet {
            if selectedFont != nil {
                pickerView.selectedFont = selectedFont!
            }
        }
    }
    
    lazy var pickerView: MZPickerView = {
        var picker = MZPickerView(frame: CGRect(x: 20, y: 60, width: MZPickerView_SCREEN_WIDTH - 40, height: 200))
        picker.dateSource = self
        picker.delegate  = self
        return picker
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: MZPickerView_SCREEN_WIDTH - 120, height: 40))
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.text = ""
        return label
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: MZPickerView_SCREEN_WIDTH - 55, y: 0, width: 40, height: 40)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return btn
    }()
    
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 20, y: 0, width: MZPickerView_SCREEN_WIDTH - 50, height: 48)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = AppFontProvider.shared.getFont16Bold()
        btn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        btn.layer.cornerRadius = 12
        btn.backgroundColor = UIColor(hex: "#FF7307")
        return btn
    }()
    
    lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: MZPickerView_SCREEN_WIDTH, height: 50))
        view.addSubview(nameLabel)
        view.addSubview(cancelBtn)
        
        nameLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        cancelBtn.center.y = view.bounds.midY
        view.setCornerRadius(12, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        return view
    }()
    
    lazy var contentView: UIView = {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: MZPickerView_SCREEN_WIDTH, height: 310 + MZPickerView_SAFE_BOTTOM))
        contentView.addSubview(headerView)
        contentView.addSubview(pickerView)
        contentView.addSubview(confirmBtn)
        confirmBtn.frame = CGRectMake(20, CGRectGetMaxY(pickerView.frame), MZPickerView_SCREEN_WIDTH - 40, 48)
        contentView.setCornerRadius(12, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        return contentView
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        view.setCornerRadius(12, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
    }
    
    /// 获取当前列选中的行
    /// - Parameter component: 当前列
    /// - Returns: 当前行
    public func selectedRow(in component: Int) -> Int {
        return pickerView.selectedRow(in: component)
    }
    
    /// 设置默认值
    /// - Parameter rows: 默认选中行
    public func selectRows(_ rows: [Int], animated: Bool = false) {
        pickerView.selectRows(rows, animated: animated)
    }
    
    @objc func cancel() {
        onDismiss?()
    }
    
    @objc func confirm() {
        self.delegate?.picker?(self, didSelect: pickerView.rows)
        onDismiss?()
    }
    
    //MARK:- MZPickerViewDataSource
    public func numberOfComponents(in pickerView: MZPickerView) -> Int {
        return self.dataSource?.numberOfComponents(in: self) ?? 1
    }
    
    public func pickerView(_ pickerView: MZPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource?.picker(self, numberOfRowsInComponent: component) ?? 0
    }
    
    //MARK:- MZPickerViewDelegate
    
    public func pickerView(_ pickerView: MZPickerView, widthForComponent component: Int) -> CGFloat {
        return self.delegate?.picker?(self, widthForComponent: component) ?? pickerView.frame.size.width / CGFloat(self.dataSource?.numberOfComponents(in: self) ?? 1)
    }

    public func pickerView(_ pickerView: MZPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.delegate?.picker?(self, rowHeightForComponent: component) ?? 40.0
    }
    
    public func pickerView(_ pickerView: MZPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return self.delegate?.picker?(self, titleForRow: row, forComponent: component) ?? "\(component)-\(row)"
    }
    
    public func pickerView(_ pickerView: MZPickerView, didSelectRow row: Int, inComponent component: Int) {
        if allowSelectClosure {
            delegate?.picker?(self, didSelect: pickerView.rows)
        }
    }
    
    @objc func contentViewTap() {
        dismiss(animated: true)
    }
}

let MZPickerView_SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 底部安全区域高度
let MZPickerView_SAFE_BOTTOM: CGFloat = {
    // 1. 获取当前活跃的 WindowScene
    let window: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }()
    
    // 2. 获取安全区域底部间距
    if #available(iOS 11.0, *) {
        return window?.safeAreaInsets.bottom ?? 0
    }
    return 0
}()
