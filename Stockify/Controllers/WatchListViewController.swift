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
    
    private var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    static var maxChangeWidth: CGFloat = 0
    
    /// model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// viewmodel
    private var viewModels: [WatchlistViewModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Configuration
    
    private func addObservers() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchlist, object: nil, queue: .main, using: { [weak self] _  in
            self?.viewModels.removeAll()
            self?.fetchWatchListData()
        })
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground

        configureSearchController()
        configureTableView()
    
        fetchWatchListData()
        configureTitleView()
        configureFloatingPanel()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true
    }
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchList
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
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
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            
            viewModels.append(.init(symbol: symbol, companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company", price: getLatestClosingPriceFromData(data: candleSticks), changeColor: changePercentage < 0 ? .red : .green, changePercentage: "\(String.percentage(from: changePercentage))", chartViewModel: .init(date: candleSticks.reversed().map {$0.close}, showLegend: false, showAxis: false)))
        }
        
        print(viewModels)
        
        self.viewModels = viewModels
    }
    
    private func getLatestClosingPriceFromData(data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return String.formatter(number: closingPrice)
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        
        let latestDate = data[0].date
        
        guard let latestClose = data.first?.close, let priorClose = data.first(where: {
            !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
        } )?.close else { return 0.0 }
        
        let diff = 1 - (priorClose / latestClose)
        
        return diff
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
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as! WatchListTableViewCell
        cell.configure(with: viewModels[indexPath.row])
        cell.didUpdateMaxWidth = {
            // optimise
            tableView.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.prefferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // update persistence
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            
            // update viewModels
            viewModels.remove(at: indexPath.row)
            
            // update row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
}

