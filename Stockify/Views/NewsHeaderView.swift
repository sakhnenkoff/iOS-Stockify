//
//  NewsHeaderView.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 26.01.2022.
//

import UIKit
import SnapKit

class NewsHeaderView: UITableViewHeaderFooterView {
    
    public var didTapAddButton: (()->Void)?
    
    static let identifier = String(describing: NewsHeaderView.self)
    static let preferredHeight: CGFloat = 70
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    //MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews(label,button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(8)
        }
        
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(120)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    //MARK: - Actions
    
    @objc private func didTapButton() {
        didTapAddButton?()
        
        button.isUserInteractionEnabled = false
        button.alpha = 0.5
    }
    
    //MARK: - Configuration
    
    public func configure(model: ViewModel) {
        label.text = model.title
        button.isHidden = !model.shouldShowAddButton
    }
    
}
