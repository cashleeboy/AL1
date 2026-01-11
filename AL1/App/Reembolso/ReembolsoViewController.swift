//
//  ReembolsoViewController.swift
//  AL1
//
//  Created by cashlee on 2025/12/12.
//

import UIKit
import Combine

class ReembolsoViewController: JYPageController {
    
    // 用于管理订阅
    private var cancellables = Set<AnyCancellable>()
    // 修改为可变属性，以便更新
    private var statusCounts = [0, 0]
    
    private lazy var viewModel = BaseTableViewModel()
    
    var menuViewOriginY = 0.0
    private lazy var menuHeight: CGFloat = 50
    // （99） （5）
    private var childControllerTitles = [
        "Para ser pagado",
        "En Revisión"
    ]
    private var viewcontrollers: [JYPageChildContollerProtocol] = [
        ParaSerPagadoPage(),
        EnRevisionPage(),
    ]
    override func viewDidLoad() {
        let pageConfig = JYPageConfig()
        pageConfig.alignment = .center
        pageConfig.normalTitleColor = UIColor(hex: "#B5B5B5")
        pageConfig.normalTitleFont = 12
        
        pageConfig.selectedTitleColor = AppColorStyle.shared.brandPrimary
        pageConfig.selectedTitleFont = 12
        pageConfig.indicatorStyle = .customSizeLine
        pageConfig.indicatorWidth = 30
        pageConfig.indicatorColor = AppColorStyle.shared.brandPrimary
        pageConfig.menuItemTop = 8
        self.config = pageConfig
        
        super.viewDidLoad()
        menuViewOriginY = NavigationUtility.totalTopSafeAreaHeight()
        view.backgroundColor = AppColorStyle.shared.backgroundWhiteF2
        
        setupNavigationBar()
        setupChildControllersBindings()
        
    }
    
    func setupNavigationBar() {
        navigation.bar.titleTextAttributes = [
            .foregroundColor : AppColorStyle.shared.backgroundWhite
        ]
        navigation.bar.tintColor = .white
        navigation.item.title = "Reembolso"
        
        navigation.bar.setBackgroundImage(
            UIImage(named: "nav_background_icon")?.withRenderingMode(.alwaysOriginal),
            for: .top,
            barMetrics: .default)
        
        setupServiceNavigationItem()
    }
    
    override func serviceAction() {
        viewModel.fetchServiceInfo { [weak self] items, error in
            guard let self else { return }
            guard let items else {
                showToast(error)
                return
            }
            showServiceDialog(with: items)
        }
    }
}

extension ReembolsoViewController
{
    private func setupChildControllersBindings() {
        viewcontrollers.enumerated().forEach { index, viewController in
            if let vc = viewController as? ReembolsoBasePage {
                vc.itemCountPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] count in
                        guard let self = self else { return }
                        self.statusCounts[index] = count
                        self.updateMenuCustomView(at: index, count: count)
                    }
                    .store(in: &cancellables)
            }
        }
    }

    private func updateMenuCustomView(at index: Int, count: Int) {
        if let customView = menuView.viewWithTag(1000 + index) as? ReembolsoSegmentItem {
            customView.updateCount(count)
        }
    }
}

extension ReembolsoViewController
{
    override func pageController(_ pageView: JYPageController, titleAt index: Int) -> String {
        childControllerTitles[index]
    }
    
    override func pageController(_ pageView: JYPageController, frameForMenuView menuView: JYPageMenuView) -> CGRect {
        return CGRect(x: 0, y: 0, width: view.frame.width, height: menuHeight)
    }
    
    override func pageController(_ pageController: JYPageController, customViewAt index: Int) -> UIView? {
        let title = childControllerTitles[index]
        let count = statusCounts[safe: index] ?? 0
        
        let itemView = ReembolsoSegmentItem(title: title, count: count)
        itemView.tag = 1000 + index
        let menuWidth = pageController.menuView.frame.width / CGFloat(childControllerTitles.count)
        itemView.frame = CGRect(x: 0, y: 0, width: menuWidth, height: 44)
        return itemView
    }
    
    override func pageController(_ pageView: JYPageController, frameForContainerView container: UIScrollView) -> CGRect {
        let originY: CGFloat = menuViewOriginY + menuHeight
        let height = view.frame.height - NavigationUtility.totalTopSafeAreaHeight() - originY - NavigationUtility.totalBottomHeight()
        return CGRect(x: 0, y: originY, width: view.frame.size.width, height: height)
    }
    
    override func numberOfChildControllers() -> Int {
        viewcontrollers.count
    }
    
    override func childController(atIndex index: Int) -> JYPageChildContollerProtocol {
        let vc = viewcontrollers[index]
        return vc
    }
    
    override func pageController(_ pageController: JYPageController, didEnterControllerAt index: Int) {
        for i in 0..<childControllerTitles.count {
            if let customView = pageController.menuView.viewWithTag(1000 + i) as? ReembolsoSegmentItem {
                customView.isSelected = (i == index)
            }
        }
    }
}
