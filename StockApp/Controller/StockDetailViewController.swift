//
//  StockDetailsViewController.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import UIKit
import SafariServices

class StockDetailViewController: UIViewController {
    // 顯示股票代號、公司名、走勢圖等等。
    
    // MARK: - Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private var newsStories: [NewsStory] = []
    
    /// 公司財務指標。
    private var metrics: Metrics?
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.id)
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.id)
        return tableView
    }()
    
    
    // MARK: - Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = [] ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        fetchFinancialData() // 顯示財務指標 / 走勢圖
        fetchNews()
        configureTableView()
        configureUI()
        configureCloseButton()
        
    }
    
    // MARK: - API
    
    /// 獲取財務數據。
    private func fetchFinancialData() {
        let group = DispatchGroup()

        // 獲取走勢（蠟燭線）資料。
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.fetchMarketData(for: symbol) { [weak self] result in
                defer { group.leave() }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print("DEBUG: fetchMarketData error:[\(error.localizedDescription)]")
                }
            }
        }

        // 獲取財務指標
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print("DEBUG: financialMetrics error:[\(error.localizedDescription)]")
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    /// 呈現走勢圖。
    private func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
        
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
        }

        // Configure
//        let change = candleStickData.getPercentage()
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: change < 0 ? .systemRed : .systemGreen
            ),
            metricViewModels: viewModels
        )
        tableView.tableHeaderView = headerView
    }
    
    /// 比較上次的收盤價。
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        // 獲取最新一天的收盤價。
        let latestDate = data[0].date
        guard let lastClose = data.first?.close else { return 0 }
        // 獲取前一次收盤價（不要獲得最新的收盤價）。
        guard let priorClose = data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate)})?.close else { return 0 }
        // 與前一次的股票價差。
        let different = 1 - (priorClose/lastClose)
        return different
        
    }
    
    private func fetchNews() {
        APICaller.shared.fetchNews(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let newsStories):
                DispatchQueue.main.async {
                    self?.newsStories = newsStories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("DEBUG: news error:[\(error.localizedDescription)]")
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - configureUI
    
    private func configureUI() {
        title = companyName
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100)
        )
    }
    
    
    
    // MARK: - Helpers
    
    private func configureCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose)
        )
    }
    
    private func openNews(uri: URL) {
        let vc = SFSafariViewController(url: uri)
        present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - NewsHeaderViewDelegate
extension StockDetailViewController: NewsHeaderViewDelegate {
    func didTapAddButton(_ headerView: NewsHeaderView) {
        // 不希望它被可以被多次點擊，所以設定點擊後隱藏
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        showAddToWatchlistAlert(companyName: companyName)
    }
}

// MARK: - UITableViewDataSource

extension StockDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.id, for: indexPath) as! NewsTableViewCell
        cell.configure(with: .init(model: newsStories[indexPath.row]))
        return cell
    }
}

// MARK: - UITableViewDataSource

extension StockDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.id) as! NewsHeaderView
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 點開新聞(news)
        let news = newsStories[indexPath.row]
        guard let url = URL(string: news.url) else {
            showError(errorMessage: "Unable to open the article.")
            return
        }
        openNews(uri: url)
    }
    
}
