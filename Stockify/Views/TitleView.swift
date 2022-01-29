//
//  TitleView.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 25.01.2022.
//

import UIKit
import SnapKit

class TitleView: UIView {
    
    let title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .medium)
        return label
    }()

    init(with title: String) {
        super.init(frame: .zero)
        
        self.title.text = title
     
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.addSubview(title)

        title.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
    }
    
}
