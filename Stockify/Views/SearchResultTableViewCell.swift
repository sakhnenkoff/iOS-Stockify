//
//  SearchResultTableViewCell.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 24.01.2022.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchResultTableViewCell.self)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
