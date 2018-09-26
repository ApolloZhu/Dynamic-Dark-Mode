//
//  SlideSegue.swift
//  Dynamic
//
//  Created by Apollo Zhu on 9/25/18.
//  Copyright © 2018 Dynamic Dark Mode. All rights reserved.
//

import Cocoa

class SlideSegue: NSStoryboardSegue, NSViewControllerPresentationAnimator {
    override func perform() {
        let source = sourceController as! NSViewController
        let destination = destinationController as! NSViewController
        source.present(destination, animator: self)
    }

    private let animationDuration: TimeInterval = 0.75
    private let frameWidth: CGFloat = 480
    private lazy var origin = CGPoint(x: frameWidth, y: 0)

    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let presented = viewController.view
        presented.wantsLayer = true
        let presentor = fromViewController.view
        presentor.addSubview(presented)
        presented.frame.origin = origin
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animationDuration
            presentor.subviews.forEach {
                if $0 == presented { return }
                $0.animator().alphaValue = 0
            }
            presented.animator().frame.origin = .zero
        }
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let presented = viewController.view
        let presentor = fromViewController.view
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            presented.animator().frame.origin = origin
            presentor.subviews.forEach {
                if $0 == presented { return }
                $0.animator().alphaValue = 1
            }
        }, completionHandler: {
            presented.removeFromSuperview()
        })
    }
}
