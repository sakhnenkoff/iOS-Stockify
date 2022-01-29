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
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    //MARK: - Configuration
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        configureSearchController()
        configureTitleView()
        configureFloatingPanel()
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

