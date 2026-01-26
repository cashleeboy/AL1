//
//  CustomDatePicker.swift
//  AL1
//
//  Created by cashlee on 2026/1/22.
//

import UIKit

class CustomDatePicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let picker = UIPickerView()
    
    // MARK: - 数据源
    private var allMonths = Array(1...12)
    private var years: [Int] = []
    
    // 动态变化的数据源
    private var currentDisplayMonths: [Int] = Array(1...12)
    private var currentDisplayDays: [Int] = Array(1...31)
    
    private let calendar = Calendar.current
    private let now = Date()
    
    // 配置项
    private let startYearOffset: Int
    private let endYearOffset: Int
    
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - 初始化
    init(frame: CGRect, startYearOffset: Int = 100, endYearOffset: Int = 0) {
        self.startYearOffset = startYearOffset
        self.endYearOffset = endYearOffset
        super.init(frame: frame)
        setupYears()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupYears() {
        let currentYear = calendar.component(.year, from: now)
        let start = currentYear - startYearOffset
        let end = currentYear + endYearOffset
        self.years = Array(start...end)
    }
    
    private func setup() {
        addSubview(picker)
        picker.delegate = self
        picker.dataSource = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: topAnchor),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // 默认定位到今天
        scrollToDate(now, animated: false)
    }
    
    // MARK: - UIPickerView DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // 日、月、年
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return currentDisplayDays.count
        case 1: return currentDisplayMonths.count
        case 2: return years.count
        default: return 0
        }
    }
    
    // MARK: - UIPickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(currentDisplayDays[row])"
        case 1: return "\(currentDisplayMonths[row])"
        case 2: return "\(years[row])"
        default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updatePickerComponents(animated: true)
        notifyDateChange()
    }
    
    // MARK: - 核心逻辑：限制未来时间
    
    private func updatePickerComponents(animated: Bool) {
        let selectedYear = years[picker.selectedRow(inComponent: 2)]
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        let currentDay = calendar.component(.day, from: now)
        
        // 1. 更新月份数组
        if endYearOffset == 0 && selectedYear == currentYear {
            currentDisplayMonths = Array(1...currentMonth)
        } else {
            currentDisplayMonths = Array(1...12)
        }
        picker.reloadComponent(1)
        
        // 修正月份越界
        let monthRow = picker.selectedRow(inComponent: 1)
        if monthRow >= currentDisplayMonths.count {
            picker.selectRow(currentDisplayMonths.count - 1, inComponent: 1, animated: animated)
        }
        
        // 2. 更新日期数组
        let selectedMonth = currentDisplayMonths[picker.selectedRow(inComponent: 1)]
        
        if endYearOffset == 0 && selectedYear == currentYear && selectedMonth == currentMonth {
            // 如果是今年今月，天数不能超过今天
            currentDisplayDays = Array(1...currentDay)
        } else {
            // 正常计算该月最大天数
            let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
            if let date = calendar.date(from: dateComponents),
               let range = calendar.range(of: .day, in: .month, for: date) {
                currentDisplayDays = Array(1...range.count)
            }
        }
        picker.reloadComponent(0)
        
        // 修正日期越界
        let dayRow = picker.selectedRow(inComponent: 0)
        if dayRow >= currentDisplayDays.count {
            picker.selectRow(currentDisplayDays.count - 1, inComponent: 0, animated: animated)
        }
    }
    
    // MARK: - 公开方法
    
    func scrollToDate(_ date: Date, animated: Bool = true) {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        if let yearIndex = years.firstIndex(of: year) {
            picker.selectRow(yearIndex, inComponent: 2, animated: animated)
        }
        
        // 先触发一次组件更新，确保月份和日期数组长度正确
        updatePickerComponents(animated: animated)
        
        // 再选中月和日
        if let monthIndex = currentDisplayMonths.firstIndex(of: month) {
            picker.selectRow(monthIndex, inComponent: 1, animated: animated)
        }
        
        updatePickerComponents(animated: animated)
        
        if let dayIndex = currentDisplayDays.firstIndex(of: day) {
            picker.selectRow(dayIndex, inComponent: 0, animated: animated)
        }
    }
    
    private func notifyDateChange() {
        let dIdx = picker.selectedRow(inComponent: 0)
        let mIdx = picker.selectedRow(inComponent: 1)
        let yIdx = picker.selectedRow(inComponent: 2)
        
        guard dIdx < currentDisplayDays.count,
              mIdx < currentDisplayMonths.count,
              yIdx < years.count else { return }
        
        var components = DateComponents()
        components.year = years[yIdx]
        components.month = currentDisplayMonths[mIdx]
        components.day = currentDisplayDays[dIdx]
        
        if let date = calendar.date(from: components) {
            onDateChanged?(date)
        }
    }
}
