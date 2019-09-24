//
//  ScrollViewActivityIndicator.swift
//  Example
//
//  Created by Alex Belozierov on 8/26/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import UIKit

class ScrollViewActivityIndicator: UIActivityIndicatorView {
    
    private weak var scrollView: UIScrollView?
    private var observer: NSKeyValueObservation!
    
    init(scrollView: UIScrollView) {
        let frame = CGRect(x: 0, y: -1000, width: scrollView.frame.width, height: 50)
        self.scrollView = scrollView
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth]
        style = .gray
        scrollView.addSubview(self)
        observer = scrollView.observe(\.contentSize, options: [.initial, .new]) {
            [unowned self] scroll, _ in self.frame.origin.y = scroll.contentSize.height }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func startAnimating() {
        super.startAnimating()
        showIndicator(true)
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        showIndicator(false)
    }
    
    private func showIndicator(_ show: Bool) {
        let duration = scrollView?.window == nil ? 0 : 0.25
        let inset = show ? frame.height : 0
        UIView.animate(withDuration: duration) {
            self.scrollView?.contentInset.bottom = inset
        }
    }
    
}
