//
//  NewsTableViewCell.swift
//  StockApp
//
//  Created by L on 2021/11/5.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = String.string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }
    
    // MARK: - Properties
    
    static let preferredHeight: CGFloat = 150
    
    
    // 新聞社
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // 標題
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.numberOfLines = 2
        return label
    }()
    
    // 日期
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    // 圖片
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()

    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        newsImageView.image = nil
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        
        let infoStack = UIStackView(arrangedSubviews: [sourceLabel, headlineLabel, dateLabel])
        infoStack.axis = .vertical
        infoStack.distribution = .fillProportionally
        infoStack.spacing = 10
        infoStack.alignment = .fill
        
        let imageAndInfoStack = UIStackView(arrangedSubviews: [infoStack,newsImageView])
        imageAndInfoStack.axis = .horizontal
        imageAndInfoStack.setCustomSpacing(10, after: infoStack)
        imageAndInfoStack.distribution = .fill
        imageAndInfoStack.alignment = .center
        
        addSubview(imageAndInfoStack)
        imageAndInfoStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }
        
        infoStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        newsImageView.snp.makeConstraints { make in
            make.size.equalTo(contentView.snp.height).multipliedBy(0.9)
        }
    }
    
    public func configure(with viewModel: ViewModel) {
        sourceLabel.text = viewModel.source
        headlineLabel.text = viewModel.headline
        dateLabel.text = viewModel.dateString
        newsImageView.kf.setImage(with: viewModel.imageUrl)
    }
    
}

