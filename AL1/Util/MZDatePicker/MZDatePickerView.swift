//
//  MZDatePickerView.swift
//  MZDatePicker
//
//  Created by 曾龙 on 2021/12/27.
//

import UIKit

protocol MZDatePickerViewDelegate: AnyObject {
    func datePickerView(_ pickerView: MZDatePickerView, didSelectDate date: Date)
    func datePickerViewDidClickDone(_ pickerView: MZDatePickerView, date: Date)
    func datePickerViewDidClickCancel(_ pickerView: MZDatePickerView)
}

class MZDatePickerView: UIView {
    /// 建议的视图高度
    static let defaultHeight: CGFloat = 260.0
    
    weak var delegate: MZDatePickerViewDelegate?
    var doneHandler: ((Date) -> Void)?
    var cancelHandler: (() -> Void)?
    
    // MARK: - 属性配置
    /// 起始时间
    var startDate: Date? {
        didSet { datePicker.minimumDate = startDate }
    }
    
    /// 结束时间
    var endDate: Date? {
        didSet { datePicker.maximumDate = endDate }
    }
    
    /// 当前选中时间
    var currentDate: Date {
        get { return datePicker.date }
        set { datePicker.setDate(newValue, animated: false) }
    }
    
    var canSelectFutureDate: Bool = true {
        didSet {
            // 如果不允许选未来，则将最大时间设为现在；否则设回默认的远期时间
            datePicker.maximumDate = canSelectFutureDate ?
                Calendar.current.date(byAdding: .year, value: 100, to: Date()) :
                Date()
        }
    }
    
    // MARK: - UI 组件
    private lazy var toolBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Done", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        // 设置语言为当前系统语言，会自动显示对应的单位
        picker.locale = Locale.current
        
        // 适配 iOS 13.4+ 强制使用滚轮样式
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        addSubview(toolBar)
        toolBar.addSubview(cancelButton)
        toolBar.addSubview(doneButton)
        addSubview(datePicker)
        
        // 默认范围设置（保持你之前的 1900 到 当前+100年）
        let minDate = Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1))
        let maxDate = Calendar.current.date(byAdding: .year, value: 100, to: Date())
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        
        // SnapKit 布局
        toolBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(toolBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 事件响应
    @objc private func dateChanged(_ picker: UIDatePicker) {
        delegate?.datePickerView(self, didSelectDate: picker.date)
    }
    
    @objc private func cancelClick() {
        delegate?.datePickerViewDidClickCancel(self)
        cancelHandler?()
    }
    
    @objc private func doneClick() {
        delegate?.datePickerViewDidClickDone(self, date: datePicker.date)
        doneHandler?(datePicker.date)
    }
}
