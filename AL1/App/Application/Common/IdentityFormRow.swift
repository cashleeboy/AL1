//
//  IdentityFormRow.swift
//  AL1
//
//  Created by cashlee on 2025/12/21.
//

import Foundation

protocol IdentityFormRow {
    // 基本信息
    var infoModel: IdentityInfoModel? { get }
    // 性别
    var currentGener: GeneroType? { get }
}
