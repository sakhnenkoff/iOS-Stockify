//
//  SearchResultsViewController.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func controllerDidSelect(searchResult: SearchResults)
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var results = [SearchResults]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    //MARK: - Configuration
    
    private func configure() {
        view.backgroundColor = .systemBackground

        // table
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResults]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
    
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        let result = results[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            // Configure content.
            content.text = result.displaySymbol
            content.secondaryText  = result.description
            
            cell.contentConfiguration = content
            
        } else {
           return UITableViewCell()
            //todo
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.controllerDidSelect(searchResult: results[indexPath.row])
    }
    
}
