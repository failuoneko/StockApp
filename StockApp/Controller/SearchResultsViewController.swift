//
//  SearchResultsViewController.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func SearchResultsViewControllerSelected(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var results: [SearchResult] = []
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: SearchResultsTableViewCell.id)
        tableView.isHidden = true
        return tableView
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureTableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
    }
    
    // MARK: - Helpers

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.id, for: indexPath)
        
        let resultModel = results[indexPath.row]
        
//        cell.detailTextLabel?.isHidden = false
        cell.textLabel?.text = resultModel.displaySymbol
        cell.detailTextLabel?.text = resultModel.description
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resultModel = results[indexPath.row]
        
        delegate?.SearchResultsViewControllerSelected(searchResult: resultModel)
    }
}
