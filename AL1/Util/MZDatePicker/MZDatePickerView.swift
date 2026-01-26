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
    var startDate: Date?
    
    /// 结束时间
    var endDate: Date?
    
    /// 当前选中时间
    var currentDate: Date?
    
    var canSelectFutureDate: Bool = true
    
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
    
    private lazy var customDatePicker: CustomDatePicker = {
        let customPicker = CustomDatePicker(frame: .zero, startYearOffset: 100, endYearOffset: 0)
        customPicker.onDateChanged = { [weak self] date in
            guard let self else { return }
            currentDate = date
        }
        return customPicker
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
        addSubview(customDatePicker)
        
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
        
        customDatePicker.snp.makeConstraints { make in
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
        guard let current = currentDate else {
            return
        }
        delegate?.datePickerViewDidClickDone(self, date: current)
        doneHandler?(current)
    }
}
