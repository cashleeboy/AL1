//
//  FeedbackPageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/27.
//

import UIKit

class FeedbackPageView: BaseTableViewController
{
    private lazy var viewModel = PersonalViewModel()
    
    private var formItems: [any TableItemProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        self.isShowBottomButtonContainer = true
        bottomContainer.setPrimaryState(isEnable: false)
        setupBindings()
        
        tableController?.onScroll = { [weak self] _ in
            guard let self else { return }
            view.endEditing(true)
        }
    }
    
    private func setupBindings() {
        // 订阅提交状态，动态控制底部按钮是否可用
        viewModel.$isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnabled in
                // 假设你有底部按钮容器
                self?.bottomContainer.setPrimaryState(isEnable: isEnabled)
            }
            .store(in: &viewModel.cancellables)
        
        // 如果你想在用户输入时做点别的（比如实时更新字数统计 Label）
        viewModel.$feedbackContent
            .sink { text in
            }
            .store(in: &viewModel.cancellables)
    }
    
    override func initTableController() {
        tableController = ModelDrivenTableController(tableView: tableView)
    }
        
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigation.item.title = "Feedback"
        navigation.bar.alpha = 1
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal), for: .top, barMetrics: .default)
    }
    
    override func setupData() {
        let textDidChangeClosure: ((String) -> Void) = { [weak self] text in
            guard let self else { return }
            viewModel.feedbackContent = text
        }
        let feedbackModel = FeedbackSelectionModel(onTextviewDidChange: textDidChangeClosure)
        formItems.append(feedbackModel)

        let rows: [RowRepresentable] = formItems.compactMap { item in
            if let convertible = item as? any PrestamoRowConvertible {
                return convertible.toRow(action: { [weak self] selectedItem in

                })
            }
            return nil
        }
        reloadData(with: rows)
    }
    
    override func configureBottomButton() {
        let style = BottomButtonStyle.primaryOnly(title: "Entregar") { [weak self] in
            guard let self else { return }
            
            viewModel.feedbackInfo {
                self.showToast("Gracias por sus comentarios.")
                self.navigationController?.popViewController(animated: true)
            } onFail: { message in
                self.showToast(message)
            }
        }
        bottomContainer.configure(with: style)
    }
    

}

