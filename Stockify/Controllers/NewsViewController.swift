//
//  NewsViewController.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    enum ExModuleNews: Error, LocalizedError {
        case failedToOpenStory
        
        var errorDescription: String? {
            switch self {
            case .failedToOpenStory:
                return "Failed to open story"
            }
        }
        
        var errorBody: String? {
            switch self {
            case .failedToOpenStory:
                return "Please try again later"
            }
        }
    }
    
    enum TypeOfVC {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return tableView
    }()
    
    private var stories = [NewsStory]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private let type: TypeOfVC
        
    init(type: TypeOfVC) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Configuration
    
    private func configure() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .secondarySystemBackground
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: type) { [weak self] result in
            switch result {
            case .success(let stories):
                self?.stories = stories
            case .failure(let e):
                print(e)
            }
        }
    }
    
    private func openUrl(url: URL) {
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true, completion: nil)
    }

}

//MARK: - Extensions

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else { fatalError() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 166
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView
        
        header?.configure(model: .init(title: self.type.title, shouldShowAddButton: false))
        
        header?.didTapAddButton = {
            print("Button was tapped")
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let story = stories[indexPath.row]
        
        guard let url = URL(string: story.url) else {
            abort(message: .failedToOpenStory)
            return
        }
        
        openUrl(url: url)
        
    }
    
}

//MARK: - Alerts

extension NewsViewController {
    func abort(message: ExModuleNews) {
        let alert = UIAlertController(title: message.localizedDescription, message: message.errorBody, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
}
