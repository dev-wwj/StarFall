//
//  GameView+ControlDelegata.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/10.
//

import Foundation

extension GameView: ControlPlayDelegate {
    func start() {
        displayLink.isPaused = false
        createBall(CGPoint(x: bounds.midX, y: 50),isAnchored: false)
        ballBehaviors.forEach { bb in
            bb.behavior.isAnchored = false
        }
    }

    func pause() {
        displayLink.isPaused = true
        ballBehaviors.forEach { bb in
            bb.behavior.isAnchored = true
            ballGravity.removeItem(bb.ball)
        }
    }
    
    func fail() {
        displayLink.isPaused = true
        delegate?.fail(self)
    }
}
