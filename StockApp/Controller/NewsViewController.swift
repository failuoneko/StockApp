//
//  TopNewsViewController.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    enum `Type` {
        case news
        case company(symbol: String)
        
        var title: String{
            switch self {
            case .news:
                return "News"
            case .company(symbol: let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    private var newsArray: [NewsStory] = []
    
    private let type: Type
    
    let tableView: UITableView = {
        let tableView = UITableView()
        // 註冊cell, header
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.id)
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.id)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchNews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - API
    
    private func fetchNews() {
        APICaller.shared.fetchNews(for: .news) { [weak self] result in
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    self?.newsArray = news
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("DEBUG: news error:[\(error.localizedDescription)]")
            }
        }
    }
    
    
    // MARK: - Helpers
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func openNews(uri: URL) {
        let vc = SFSafariViewController(url: uri)
        present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.id, for: indexPath) as! NewsTableViewCell
        cell.configure(with: .init(model: newsArray[indexPath.row]))
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.id) as! NewsHeaderView
        // NewsHeaderView.ViewModel .init
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: false))
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 點開新聞(news)
        let news = newsArray[indexPath.row]
        guard let url = URL(string: news.url) else {
            showError(errorMessage: "Unable to open the article.")
            return
        }
        openNews(uri: url)
    }
}
