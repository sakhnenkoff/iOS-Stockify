//
//  NewsStoryTableViewCell.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 29.01.2022.
//

import UIKit
import Nuke

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = String(describing: NewsStoryTableViewCell.self)
    static let preferredHeight: CGFloat = 140 
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        var headlineForUse: String {
            
            var components = headline.components(separatedBy: .whitespacesAndNewlines)
            
            if components.count >= 14 {
                while components.count != 12 {
                    components.removeLast()
                }
                return components.joined(separator: " ") + "..."
            }
            
            return headline
        }
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // image
        
        storyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        // labels
        
        sourceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(storyImageView.snp_leftMargin).offset(-22)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(headlineLabel.snp_bottomMargin).offset(12)
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    //MARK: - Configuration
    
    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headlineForUse
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        if let url = viewModel.imageUrl {
            Nuke.loadImage(with: url, into: storyImageView)
        } else {
            // display placeholder
        }
    }

}
