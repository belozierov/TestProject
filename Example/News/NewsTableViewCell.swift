//
//  NewsTableViewCell.swift
//  Example
//
//  Created by Alex Belozierov on 8/25/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var keywordsLabel: UILabel!
    
    func config(with article: Article) {
        titleLabel.text = article.headline
        descriptionLabel.text = article.snippet
        keywordsLabel.text = article.date?.description
//        keywordsLabel.text = ((article.keywords?.array as? [Keyword])?
//            .compactMap { $0.value }.joined(separator: ", ")).flatMap { $0.isEmpty ? nil : "Keywords: \($0)" }
//        keywordsLabel.isHidden = keywordsLabel.text?.isEmpty != false
    }
    
}
