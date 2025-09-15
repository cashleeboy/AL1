//
//  ViewController.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white

        // 添加按钮
        let button = UIButton(type: .system)
        button.setTitle("Go to Bookings", for: .normal)
        button.addTarget(self, action: #selector(goToBookings), for: .touchUpInside)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func goToBookings() {
        // Push BookingListViewController
        let bookingVC = BookingListViewController()
        navigationController?.pushViewController(bookingVC, animated: true)
    }

}

