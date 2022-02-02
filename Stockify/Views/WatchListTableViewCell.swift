//
//  WatchListTableViewCell.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 01.02.2022.
//

import UIKit

struct WatchlistViewModel {
    let symbol: String
    let companyName: String
    let price: String // formatted
    let changeColor: UIColor // red or green
    let changePercentage: String // formatted
}

class WatchListTableViewCell: UITableViewCell {
    static let identifier = String(describing: WatchListTableViewCell.self)
    
    static let prefferedHeight: CGFloat = 60
    
    //MARK: - Properties
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white 
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let miniChartView = StockChartView()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews(symbolLabel,nameLabel,miniChartView,priceLabel,changeLabel,miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
        
    }
    
    //MARK: - Configuration
    
    public func configure(with viewModel: WatchlistViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // Configure chart

    }
}
