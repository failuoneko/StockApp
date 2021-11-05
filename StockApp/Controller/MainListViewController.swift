//
//  MainListViewController.swift
//  StockApp
//
//  Created by L on 2021/11/1.
//

import UIKit
import SnapKit
import FloatingPanel
import Kingfisher

class MainListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var searchTextTimer: Timer?
    private var floatingPanel: FloatingPanelController?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //                debug()
        
        view.backgroundColor = .systemBackground
        configureSearchController()
        configureFloatingPanel()
        configureTitleView()
        
    }
    
    // MARK: - API
    
    func debug() {
        APICaller.shared.fetchNews(for: .company(symbol: "MSFT")) { result in
            switch result {
            case .success(let news):
                //                print("DEBUG: response: [\(response.result)]")
                print("DEBUG: response count: [\(news.count)]")
            case .failure(let error):
                print("DEBUG: error: [\(error)]")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configureFloatingPanel() {
        let vc = NewsViewController(type: .news)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    private func configureTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: navigationController?.navigationBar.frame.size.height ?? 100))
        navigationItem.titleView = titleView
        //        titleView.backgroundColor = .red
        
        let label = UILabel()
        titleView.addSubview(label)
        label.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(10)
            make.height.equalTo(titleView.snp.height)
        }
        //        label.backgroundColor = .blue
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
    }
    
    private func configureSearchController() {
        let resultsVC = SearchResultsViewController()
        resultsVC.delegate = self
        let searchController = UISearchController(searchResultsController: resultsVC)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        //        searchController.obscuresBackgroundDuringPresentation = false // 是否模糊
        //        searchController.hidesNavigationBarDuringPresentation = false // 是否隱藏導航欄
        //        searchController.searchBar.placeholder = "Search for something"
        definesPresentationContext = false // 是否跟隨view一起滑動
    }
    
}

// MARK: - UISearchResultsUpdating

// 更新搜尋結果
extension MainListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              !searchText.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        // 重置timer。（將timer的執行緒停止，0.3秒內輸入就會停止上次執行到的Timer。）
        searchTextTimer?.invalidate()
        
        // 優化以減少用戶輸入的搜尋次數。
        // 開始新的timer。
        searchTextTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.searchStocks(query: searchText) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsController.update(with: response.result)
                    }
                //                print("DEBUG: response: [\(response.result)]")
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsController.update(with: [])
                    }
                    print("DEBUG: error: [\(error)]")
                }
            }
        })
    }
}

// MARK: - SearchResultsViewControllerDelegate

extension MainListViewController: SearchResultsViewControllerDelegate {
    func SearchResultsViewControllerSelected(searchResult: SearchResult) {
        // 當使用者點選搜尋匡時，開啟鍵盤
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // 選擇搜尋框後顯示股票詳細資料。
        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true, completion: nil)
        
        print("DEBUG: select: [\(searchResult.displaySymbol)]")
    }
}

// MARK: - SearchResultsViewControllerDelegate

extension MainListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        // 拉動至最上方時隱藏標題。
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}
