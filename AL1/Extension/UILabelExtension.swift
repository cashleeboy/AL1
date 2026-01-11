//
//  UILabelExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit

extension UILabel {
    /// 自动识别并设置 text 或 attributedText
    var anyText: Any? {
        get { attributedText ?? text }
        set {
            if let attributed = newValue as? NSAttributedString {
                self.attributedText = attributed
            } else if let string = newValue as? String {
                self.text = string
            } else {
                self.text = nil
            }
        }
    }
}
