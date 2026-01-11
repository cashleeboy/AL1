//
//  PaymentMethodDialog.swift
//  AL1
//
//  Created by cashlee on 2025/12/17.
//

import UIKit

struct PaymentMethodItem {
    let id: String
    let iconName: String
    let title: String
    var isSelected: Bool = false
}

class PaymentMethodDialog: BaseDialog {
    // MARK: - 属性
    private var methods: [PaymentMethodItem] = []
    private var selectedId: String?
    
    /// 点击确认后的回调
    var onConfirm: ((String) -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - 初始化
    override init() {
        super.init()
        // 对接基类按钮文字
        primaryButton.setTitle("Pagar Ahora", for: .normal)
        titleLabel.text = "Seleccionar método de pago"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 外部通过此方法传入支付方式列表
    func configure(with methods: [PaymentMethodItem]) {
        self.methods = methods
        self.selectedId = methods.first(where: { $0.isSelected })?.id
        refreshList()
    }
    
    // MARK: - 布局设置
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(stackView)
        
        // 1. 固定对话框宽度
        contentView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
        }
        
        // 2. 标题约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 3. StackView 约束
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview() // 撑满 contentView 宽度
        }
        
        // 4. 底部按钮约束
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-24) // 确保触底
        }
    }
    
    // MARK: - 重写基类动作
    
    @objc override func handlePrimaryAction() {
        // 重写基类按钮点击逻辑，执行业务回调
        guard let id = selectedId else { return }
        onConfirm?(id)
    }
    
    // MARK: - 列表逻辑 (保持不变)
    
    private func refreshList() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, method) in methods.enumerated() {
            let itemView = createMethodItemView(method: method)
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func createMethodItemView(method: PaymentMethodItem) -> UIView {
        let container = UIView()
        container.snp.makeConstraints { make in make.height.equalTo(60) }
        
        let icon = UIImageView(image: UIImage(named: method.iconName))
        let label = UILabel()
        label.text = method.title
        label.font = AppFontProvider.shared.getFont16Medium()
        
        let checkBtn = UIButton(type: .custom)
        let isSelected = method.id == selectedId
        checkBtn.setImage(UIImage(named: isSelected ? "pre_login_enable" : "pre_login_disable"), for: .normal)
        checkBtn.isUserInteractionEnabled = false

        let line = UIView()
        line.backgroundColor = UIColor(hex: "#F5F5F5")
        
        container.addSubview(icon)
        container.addSubview(label)
        container.addSubview(checkBtn)
        container.addSubview(line)
        
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20) // 这里的 20 是相对于容器的
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        checkBtn.snp.makeConstraints { make in
            // ⭐️ 重点：这里的 trailing 是相对于 container 的边缘，
            // 只要 StackView 本身宽度正确，这里就不会冲突
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleItemTap(_:)))
        container.addGestureRecognizer(tap)
        container.tag = methods.firstIndex(where: { $0.id == method.id }) ?? 0
        
        return container
    }
    
    @objc private func handleItemTap(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        selectedId = methods[index].id
        refreshList() // 刷新 UI 状态
    }
}
