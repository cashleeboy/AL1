//
//  GIFHUDImageView.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit

class GIFHUDImageView: UIImageView {
    
    // MARK: Computed Properties
    var animatableImage: GIFHUDImage? { image as? GIFHUDImage }
    
    var isAnimatingGif: Bool { animatableImage?.isAnimating ?? false }
    
    var animatable: Bool { animatableImage != nil }
    
    // MARK: Overrides
    override func display(_ layer: CALayer) {
        if let frame = animatableImage?.currentFrame?.cgImage {
            layer.contents = frame
        }
    }
    
    // MARK: Setter Methods
    func setAnimatableImage(named name: String) {
        image = GIFHUDImage(image: name, delegate: self)
        layer.setNeedsDisplay()
    }
    
    func setAnimatableImage(data: Data) {
        image = GIFHUDImage(data: data, delegate: self)
        layer.setNeedsDisplay()
    }
    
    // MARK: Animation
    
    func startAnimatingGif() {
        if animatable {
            animatableImage?.resumeAnimation()
        }
    }
    
    func stopAnimatingGif() {
        if animatable {
            animatableImage?.pauseAnimation()
        }
    }
}
