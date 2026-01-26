//
//  ModelDrivenTableController.swift
//  AL1
//
//  Created by cashlee on 2025/12/13.
//

import Foundation
import UIKit

final class ModelDrivenTableController: NSObject {
    
    var onScroll: ((UIScrollView) -> Void)?
    
    private weak var tableView: UITableView?
    // 数据结构：二维数组，存储 Section 和 Row 对象
    var sections: [[RowRepresentable]] = []
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - 核心更新方法
    
    func reload(with newSections: [[RowRepresentable]]) {
        for section in newSections {
            for row in section {
                tableView?.register(row.cellClass, forCellReuseIdentifier: row.reuseIdentifier)
            }
        }
        
        // 2. 更新数据并刷新表格
        self.sections = newSections
        tableView?.reloadData()
    }
    
    /// 更新单个 TableItemProtocol 模型
    /// - 通过 TableItemProtocol 的 identifier 查找对应的 RowRepresentable，
    /// - 然后使用 RowRepresentable 的 clone 方法创建一个新的 Row，并替换旧的 Row。
    func update(with item: TableItemProtocol, animated: Bool = true) {
        guard let tableView = tableView else { return }
        
        // 1. 查找目标 Row 的 IndexPath
        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.firstIndex(where: {
                return $0.reuseIdentifier == item.identifier
            }) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                let oldRow = sections[sectionIndex][rowIndex]
                let newRow = oldRow.clone(with: item)
                
                sections[sectionIndex][rowIndex] = newRow
                
                if animated {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                } else {
                    if let cell = tableView.cellForRow(at: indexPath) {
                        newRow.configure(cell: cell)
                    }
                }
                return
            }
        }
    }
    // ⭐️ 必须依赖外部工厂方法来将 TableItemProtocol 转换为 RowRepresentable
    typealias RowFactory = ([any TableItemProtocol]) -> [any RowRepresentable]
    typealias SingleRowFactory = (any TableItemProtocol) -> any RowRepresentable
    
    /// 更新/添加 Section：替换整个 Section 或添加到末尾
    func update(with newSectionItems: [any TableItemProtocol],
                at index: Int,
                animation: UITableView.RowAnimation = .automatic,
                rowFactory: RowFactory) {
        
        guard let tableView = tableView else { return }
        
        let newSectionRows = rowFactory(newSectionItems) // 使用 Factory 转换为 Rows
        
        // 1. 注册所有 Cell
        newSectionRows.forEach { row in
            tableView.register(row.cellClass, forCellReuseIdentifier: row.reuseIdentifier)
        }
        
        let sectionIndexSet = IndexSet(integer: index)
        
        if index < sections.count {
            sections[index] = newSectionRows
            tableView.reloadSections(sectionIndexSet, with: animation)
        } else if index == sections.count {
            sections.append(newSectionRows)
            tableView.insertSections(sectionIndexSet, with: animation)
        }
    }
    
    /// 插入 Row
    func insert(item: any TableItemProtocol,
                at indexPath: IndexPath,
                animation: UITableView.RowAnimation = .automatic,
                rowFactory: SingleRowFactory) { // ⭐️ 接受 SingleRowFactory
        
        guard let tableView = tableView, indexPath.section < sections.count else { return }
        let newRow = rowFactory(item) // 使用 Factory 转换为 Row
        tableView.register(newRow.cellClass, forCellReuseIdentifier: newRow.reuseIdentifier)
        sections[indexPath.section].insert(newRow, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: animation)
    }
    
    /// 删除 Row
    func remove(at indexPath: IndexPath, animation: UITableView.RowAnimation = .automatic) {
        guard let tableView = tableView, indexPath.section < sections.count, indexPath.row < sections[indexPath.section].count else { return }
        
        // 1. 删除数据
        sections[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: animation)
        if sections[indexPath.section].isEmpty {
            removeSection(at: indexPath.section, animation: animation)
        }
    }
    
    func removeSection(at index: Int, animation: UITableView.RowAnimation = .automatic) {
        guard let tableView = tableView, index < sections.count else { return }
        sections.remove(at: index)
        tableView.deleteSections(IndexSet(integer: index), with: animation)
    }
    
    /// 根据标识符查找并删除 Row
    func removeRow(where predicate: (RowRepresentable) -> Bool, animation: UITableView.RowAnimation = .automatic) {
        for (sIndex, section) in sections.enumerated() {
            if let rIndex = section.firstIndex(where: predicate) {
                let indexPath = IndexPath(row: rIndex, section: sIndex)
                self.remove(at: indexPath, animation: animation)
                return // 找到并删除后退出
            }
        }
    }
    
    /// 检查是否存在某个 Row
    func containsRow(where predicate: (RowRepresentable) -> Bool) -> Bool {
        return sections.flatMap { $0 }.contains(where: predicate)
    }
}

extension ModelDrivenTableController: UITableViewDataSource, UITableViewDelegate
{
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        
        row.configure(cell: cell)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section][indexPath.row]
        row.didSelectAction?(row.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?(scrollView)
    }
}
