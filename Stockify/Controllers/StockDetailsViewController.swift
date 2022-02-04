//
//  StockDetailsViewController.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit
import SafariServices

struct StockDetailViewModel {
    let symbol: String
    let companyName: String
    let candleStickData: [CandleStick]
}

class StockDetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    private var stickData: [CandleStick]
    
    private var shouldShowButton: Bool {
        !PersistenceManager.shared.watchlistContains(symbol: symbol)
    }
    
    private var stories: [NewsStory] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return table
    }()

    init(with model: StockDetailViewModel) {
        self.symbol = model.symbol
        self.companyName = model.companyName
        self.stickData = model.candleStickData
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    //MARK: - Configuration
    
    private func configure() {
        title = companyName
            
        configureTable()
        fetchFinData { [weak self] _ in
            self?.renderChart()
        }
        fetchNews()
        configureCloseButton()
        
    }
    
    private func configureTable() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }
    
    private func configureCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapCloseButton))
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchFinData(completion: ((Void) -> ())?){
        // fetch data if needed
        
        // fetch financial data
        
        
        
        completion
    }
    
    private func renderChart() {
        
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let data):
                self?.stories = data
            case .failure(let e):
                print(e)
            }
        }
    }
    
}

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { fatalError() }
        header.configure(model: .init(title: symbol.uppercased(), shouldShowAddButton: shouldShowButton ? true : false))
        header.didTapAddButton = { [weak self] in
            PersistenceManager.shared.addToWatchList(symbol: self?.symbol ?? "", companyName: self?.companyName ?? "")
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let vc = SFSafariViewController.init(url: url)
        
        present(vc,animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else { fatalError() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
}
