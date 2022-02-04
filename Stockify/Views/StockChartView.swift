//
//  StockChartView.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 01.02.2022.
//

import UIKit

struct StockChartViewModel {
    let date: [Double]
    let showLegend: Bool
    let showAxis: Bool
}

class StockChartView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - Public
    
    public func reset() {
            
    }
    
    public func configure(with model: StockChartViewModel) {
        
    }
    
}
