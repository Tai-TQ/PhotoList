//
//  FPSLabel.swift
//  ListPhoto
//
//  Created by TaiTruong on 28/8/25.
//

import UIKit

class FPSLabel: UILabel {
    private var link: CADisplayLink?
    private var count = 0
    private var lastTime: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textColor = .white
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        self.textAlignment = .center
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        
        // Dùng CADisplayLink để update mỗi frame
        link = CADisplayLink(target: self, selector: #selector(tick(link:)))
        link?.add(to: .main, forMode: .common)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tick(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        
        count += 1
        let delta = link.timestamp - lastTime
        if delta >= 1 {
            let fps = Double(count) / delta
            self.text = String(format: "FPS: %.0f", fps.rounded())
            count = 0
            lastTime = link.timestamp
        }
    }
    
    deinit {
        link?.invalidate()
    }
}
