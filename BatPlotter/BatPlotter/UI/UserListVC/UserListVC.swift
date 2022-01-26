//
//  UserListVC.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 17/01/2022.
//

import UIKit

//MARK: Properties
final class UserListVC: UIViewController {
    private let refreshControl = UIRefreshControl()
    private let tableView = UITableView()
    var viewModel: PUserListVM?
}

//MARK: Life Cycle
extension UserListVC {
    override func viewDidLoad() {
        setupTableView()
        setupRefresh()
        viewModel?.reloadCells = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel?.stopRefreshing = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

//MARK: UI Setup
extension UserListVC {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.constrainToSuperview().activate()
        tableView.register(UserListCell.nib, forCellReuseIdentifier: UserListCell.identifier)
    }

    private func setupRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
}

//MARK: UITableView
extension UserListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.users.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserListCell.self), for: indexPath) as? UserListCell else { return UITableViewCell() }
        cell.configureCell(user: viewModel?.users[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: User Interaction
extension UserListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel?.navigateToMap(for: indexPath.row)
    }

    @objc private func refreshPulled() {
        viewModel?.getUserList()
    }
}
