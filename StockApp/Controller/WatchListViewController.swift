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

class WatchListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var searchTextTimer: Timer?
    private var floatingPanel: FloatingPanelController?
    
    /// Width to track change label geometry
    static var maxChangeWidth: CGFloat = 0
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private var observer: NSObjectProtocol?
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.id)
        //        tableView.backgroundColor = .clear
        return tableView
    }()
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        debug()
        view.backgroundColor = .systemBackground
        configureSearchController()
        configureTableView()
        fetchWatchlistData()
        configureFloatingPanel()
        configureTitleView()
        configureObserver()
        
        configureUI()
    }
    
    
    
    // MARK: - API
    
    func debug() {
        APICaller.shared.fetchMarketData(for: "AAPL", numberOfDays: 1) { result in
            //            print("DEBUG: marketdata :[\(result)]")
            switch result {
            case .success(let data):
                let candleStricks = data.candleSticks
            //                print("DEBUG: response count: [\(candleStricks.count)]")
            case .failure(let error):
                print("DEBUG: error: [\(error)]")
            }
        }
    }
    
    
    // MARK: - configureUI
    
    private func configureUI() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    // MARK: - Helpers
    
    private func configureObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchlist, object: nil, queue: .main, using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
        })
    }
    
    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            // 獲取每個公司的資料。
            APICaller.shared.fetchMarketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print("DEBUG: watchlist error: [\(error.localizedDescription)]")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels: [WatchListTableViewCell.ViewModel] = []
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLastClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: String.percentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleSticks.reversed().map{ $0.close },
                        showLegend: false,
                        showAxis: false)
                )
            )
        }
//        print("DEBUG: viewModel: [\(viewModels)]")
        self.viewModels = viewModels
    }
    
    // 比較上次的收盤價。
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        // 獲取最新一天的收盤價。
        let latestDate = data[0].date
        guard let lastClose = data.first?.close else { return 0 }
        // 獲取前一次收盤價（不要獲得最新的收盤價）。
        guard let priorClose = data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate)})?.close else { return 0 }
        // 與前一次的股票價差。
        let different = 1 - (priorClose/lastClose)
        print("DEBUG: price diff : [\(symbol): \(different)%)]")
        return different
        
        //        print("DEBUG: [Symbol: \(symbol)| Date: \(latestDate)|Current（現在價格）: \(lastClose)| Prior（先前價格）: \(priorClose)]")
        //        return priorClose/lastClose
    }
    
    private func getLastClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return ""}
        
        return String.formatted(number: closingPrice)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
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
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        //        searchController.obscuresBackgroundDuringPresentation = false // 是否模糊
        //        searchController.hidesNavigationBarDuringPresentation = false // 是否隱藏導航欄
        //        searchController.searchBar.placeholder = "Search for something"
        definesPresentationContext = false // 是否跟隨view一起滑動
    }
    
}

// MARK: - UISearchResultsUpdating

// 更新搜尋結果
extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              !searchText.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        // 重置timer。（將timer的執行緒停止，0.5秒內輸入就會停止上次執行到的Timer。）
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

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func SearchResultsViewControllerSelected(searchResult: SearchResult) {
        // 當使用者點選搜尋匡時，開啟鍵盤
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // 選擇搜尋框後顯示股票詳細資料。
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol, companyName: searchResult.description)
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true, completion: nil)
        
        print("DEBUG: select: [\(searchResult.displaySymbol)]")
    }
}

// MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        // 拉動至最上方時隱藏標題。
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

// MARK: - UITableViewDataSource
extension WatchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.id, for: indexPath) as! WatchListTableViewCell
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WatchListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 點擊cell後觀看詳細數據。
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(symbol: viewModel.symbol, companyName: viewModel.companyName, candleStickData: watchlistMap[viewModel.symbol] ?? [])
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    // 左滑刪除cell。
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()

            // Update persistence
            PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            // Update viewModels
            viewModels.remove(at: indexPath.row)

            // Delete Row
            tableView.deleteRows(at: [indexPath], with: .automatic)

            tableView.endUpdates()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    /// 通知delegate標簽寬度的變化
    func didUpdateMaxWidth() {
        // 優化：僅刷新更改最大寬度的行。
        tableView.reloadData()
    }
}
