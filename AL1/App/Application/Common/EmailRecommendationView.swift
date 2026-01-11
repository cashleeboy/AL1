//
//  EmailRecommendationView.swift
//  AL1
//
//  Created by cashlee on 2026/1/9.
//

import UIKit
import SnapKit

class EmailRecommendationView: UIView {
    static var emailRecommendHeight: CGFloat = 200
    var onEmailSelected: ((String) -> Void)?
    private let emailSuffixes = ["@gmail.com", "@outlook.com", "@hotmail.com", "@yahoo.com", "@yahoo.es"]
    private var currentPrefix: String = ""
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 44
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.layer.cornerRadius = 12
        tv.backgroundColor = .white
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func updatePrefix(_ prefix: String) {
        // 如果用户已经输入了 @，则停止推荐或根据已输入的后缀过滤
        if prefix.contains("@") {
            self.isHidden = true
            return
        }
        self.currentPrefix = prefix
        self.isHidden = prefix.isEmpty
        tableView.reloadData()
    }
}

extension EmailRecommendationView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailSuffixes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let suffix = emailSuffixes[indexPath.row]
        let fullEmail = currentPrefix + suffix
        
        // 设置富文本显示：前缀紫色，后缀灰色
        let attributedString = NSMutableAttributedString(string: fullEmail)
        attributedString.addAttribute(.foregroundColor, value: AppColorStyle.shared.brandPrimary, range: NSMakeRange(0, currentPrefix.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(currentPrefix.count, suffix.count))
        
        cell.textLabel?.attributedText = attributedString
        cell.textLabel?.font = AppFontProvider.shared.getFont15Regular()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onEmailSelected?(currentPrefix + emailSuffixes[indexPath.row])
    }
}
