//
//  NewsTableViewController.swift
//  Example
//
//  Created by Alex Belozierov on 8/25/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import UIKit
import SafariServices

class NewsTableViewController: UITableViewController, NewsViewModelDelegate {
    
    var viewModel = NewsViewModel()
    private lazy var indicator = ScrollViewActivityIndicator(scrollView: tableView)
    private var heightCache = [String: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.reload()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        cell.config(with: viewModel[indexPath])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel[IndexPath(row: 0, section: section)].date.map(headerDateFormatter.string)
    }
    
    private let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel[indexPath].id.map { heightCache[$0] = cell.frame.height }
        viewModel.willShowItem(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel[indexPath].id.flatMap { heightCache[$0] } ?? UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel[indexPath].url else { return }
        let controller = SFSafariViewController(url: url)
        controller.configuration.entersReaderIfAvailable = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - NewsViewModelDelegate
    
    func loadBegins() {
        indicator.startAnimating()
    }
    
    func loadEnds() {
        indicator.stopAnimating()
    }
    
    func recieveError(_ error: Error) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    func dataDidUpdated(updates: [IndexPathUpdate]) {
        tableView.update(with: updates)
    }
    
}
