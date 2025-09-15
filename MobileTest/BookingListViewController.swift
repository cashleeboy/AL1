//
//  BookingListViewController.swift
//  MobileTest
//
//  Created by 李鸿章 on 2025/9/15.
//

import UIKit
import Combine

class BookingListViewController: UIViewController {
    private let tableView = UITableView()
    private let dataManager: BookingDataManager
    private var cancellables = Set<AnyCancellable>()
    private var segments: [Segment] = []

    init(dataManager: BookingDataManager = BookingDataManager()) {
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
        setupUI()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bind() {
        dataManager.segmentsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] new in
                self?.segments = new
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let result = await dataManager.fetch(forceRefresh: false)
            switch result {
            case .success(let items):
                print("[BookingListVC] Got \(items.count) segments:")
                for seg in items {
                    let o = seg.originAndDestinationPair.origin.displayName
                    let d = seg.originAndDestinationPair.destination.displayName
                    print(" - \(seg.id): \(o) → \(d)")
                }
            case .failure(let err):
                print("Error:", err.localizedDescription)
            }
        }
    }
}

extension BookingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { segments.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let seg = segments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(seg.originAndDestinationPair.origin.displayName) → \(seg.originAndDestinationPair.destination.displayName)"
        content.secondaryText = "ID: \(seg.id)"
        cell.contentConfiguration = content
        return cell
    }
}
