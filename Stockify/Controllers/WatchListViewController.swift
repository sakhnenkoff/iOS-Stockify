//
//  ViewController.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var titleView: TitleView?
    private var panel: FloatingPanelController?

    private var searchTimer: Timer?
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    /// model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// viewmodel
    private var viewModels: [WatchlistViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    //MARK: - Configuration
    
    private func configure() {
        view.backgroundColor = .systemBackground

        configureSearchController()
        configureTableView()
        
        PersistenceManager.shared.setUpDefaults()
        fetchWatchListData()
        
        configureTitleView()
        configureFloatingPanel()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchList
        
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            
            APICaller.shared.marketData(symbol: symbol) { [weak self] results in
                defer {
                    group.leave()
                }
            
                switch results {
                case .success(let marketdata):
                    let candleSticks = marketdata.candleStick
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let e):
                    print(e)
                }
            }
            
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchlistViewModel]()
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(for: candleSticks)
            
            viewModels.append(.init(symbol: symbol, companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company", price: getLatestClosingPriceFromData(symbol: symbol, data: candleSticks), changeColor: changePercentage < 0 ? .red : .green, changePercentage: "\(changePercentage)"))
        }
        
        self.viewModels = viewModels
    }
    
    private func getLatestClosingPriceFromData(symbol: String, data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return "\(closingPrice)"
    }
    
    private func getChangePercentage(for data: [CandleStick]) -> Double {
        let priorDate = Date().addingTimeInterval(-(3600*24)*2)
        guard let latestClose = data.first?.close, let priorClose = data.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: priorDate)
        } )?.close else { return 0.0 }
        
        print("Current: \(latestClose) | Prior: \(priorClose)")
        
        return 0.0
    }
    
    private func configureFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        
        
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.appearance.cornerRadius = 14
        
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
    
        panel.contentViewController = vc
        panel.surfaceView.appearance.shadows = [shadow]
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.addPanel(toParent: self)
        
    }
    
    private func configureTitleView() {
        self.titleView = TitleView(with: "Stocks")
        guard let titleView = titleView else { return }
    
        navigationItem.titleView = titleView
    }

    private func configureSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        
        navigationItem.searchController = searchVC
        
    }
}

//MARK: - Extensions

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, let resultsVC = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        resultsVC.update(with: data.result)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func controllerDidSelect(searchResult: SearchResults) {
        
        navigationItem.searchController?.resignFirstResponder()
    
        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

//MARK: - Table

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

