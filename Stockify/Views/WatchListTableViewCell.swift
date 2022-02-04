//
//  WatchListTableViewCell.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 01.02.2022.
//

import UIKit
import SnapKit

struct WatchlistViewModel {
    let symbol: String
    let companyName: String
    let price: String // formatted
    let changeColor: UIColor // red or green
    let changePercentage: String // formatted
    let chartViewModel: StockChartViewModel
}

class WatchListTableViewCell: UITableViewCell {
    static let identifier = String(describing: WatchListTableViewCell.self)
    
    static let prefferedHeight: CGFloat = 60
    
    public var didUpdateMaxWidth: (() -> Void)?
    
    //MARK: - Properties
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white 
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        label.textAlignment = .right
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView(frame: .zero)
        chart.clipsToBounds = true
        return chart
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        
        addSubviews(symbolLabel,nameLabel,miniChartView,priceLabel,changeLabel,miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        let currentWidth = max(max(priceLabel.width, changeLabel.width), WatchListViewController.maxChangeWidth)
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            didUpdateMaxWidth?()
        }
        
        priceLabel.setWidth(width: currentWidth)
        changeLabel.setWidth(width: currentWidth)
        
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let leftStack = UIStackView.simpleStack(axis: .vertical, spacing: 4, alignment: .leading, distribution: .fill)
        leftStack.addArrangedSubview(views: symbolLabel,nameLabel)
        contentView.addSubviews(leftStack)
        
        let rightVStack = UIStackView.simpleStack(axis: .vertical, spacing: 4, alignment: .trailing, distribution: .fill)
        rightVStack.addArrangedSubview(views: priceLabel,changeLabel)
        contentView.addSubviews(rightVStack)
        
        miniChartView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(80)
        }
        
        let rightHStack = UIStackView.simpleStack(axis: .horizontal, spacing: 12, alignment: .center, distribution: .fill)
        rightHStack.addArrangedSubview(views: miniChartView,rightVStack)
        contentView.addSubviews(rightHStack)
        
        leftStack.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }
            
        rightHStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        
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
