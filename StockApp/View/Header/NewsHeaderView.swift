//
//  NewsHeaderView.swift
//  StockApp
//
//  Created by L on 2021/11/5.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func didTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    
    struct ViewModel {
        let title:String
        let shouldShowAddButton: Bool
    }

    // MARK: - Properties
    
    weak var delegate: NewsHeaderViewDelegate?
    
    static let preferredHeight: CGFloat = 80
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()

    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("+ Watchlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.height.equalToSuperview()
//        }
//        label.backgroundColor = .red
//
        contentView.addSubview(button)
////        button.sizeToFit()
//        button.snp.makeConstraints { make in
//            make.left.equalTo(label.snp.right)
//            make.width.equalTo(button.snp.width).multipliedBy(1)
//            make.height.equalTo(button.snp.height)
//        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: contentView.frame.size.width-30, height: contentView.frame.size.height)
        button.sizeToFit()
        button.frame = CGRect(x: contentView.frame.size.width - button.frame.size.width - 16,
                              y: (contentView.frame.size.height - button.frame.size.height)/2,
                              width: button.frame.size.width + 12,
                              height: button.frame.size.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    // MARK: - Selectors

    @objc func didTapButton() {
        // Call delegate
        delegate?.didTapAddButton(self)
    }

    // MARK: - Helpers

    func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }

}
