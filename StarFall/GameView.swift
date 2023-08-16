//
//  GameView.swift
//  ballFall
//
//  Created by wangwenjian on 2023/8/4.
//

import Foundation
import UIKit
import CoreMotion

protocol GameDelegate: NSObjectProtocol {
    func running(_ view: GameView)
    
    func fail(_ view: GameView)
}


let rowHight = 120.0

class GameView: UIView {
    
    
    var level: Int = 1
    
    private(set) var deathScore: Int = 0
    
    private(set) var liveScore: Int = 0
    
    weak var delegate: GameDelegate?
    
    var animator : UIDynamicAnimator!
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = motionManager
        _ = scrollView
        
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isUserInteractionEnabled = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        animator = UIDynamicAnimator(referenceView: scrollView)
        scrollView.contentSize = CGSize(width: self.bounds.width, height: 100000)
        return scrollView
    }()
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
        displayLink.add(to: RunLoop.main, forMode: .common)
        return displayLink
    }()
    
    var offsetY = 0.0
    @objc func displayLinkAction(){
        offsetY += (Double(level) * 0.2 + 1)
        scrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        var total = 0
        ballBehaviors.forEach { bb in
            total += bb.ball.score
        }
        liveScore = total
        let score = total + deathScore
        if score < 5000 {
            level = 1
        } else if score > 26000{
            level = 8
        } else {
            level = 1 + (total + deathScore - 5000) / 3000
        }
        delegate?.running(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 监测重力方向
    lazy var motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.03
            manager.startDeviceMotionUpdates(to: .main) {[unowned self] motion, error in
                guard let motion = motion else {
                    return
                }
                self.updateGravity(motion.gravity)
            }
        }
        return manager
    }()
    
    func updateGravity(_ gravity: CMAcceleration) {
        ballGravity.gravityDirection = CGVector(dx: gravity.x, dy: -gravity.y)
    }
    
    // 重力
    lazy var ballGravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        return gravity
    }()
    
    var ballBehaviors: [BallBehavior] = []
    func createBall(_ position: CGPoint, isAnchored: Bool = true) {
        if !animator.behaviors.contains(ballGravity){
            animator.addBehavior(ballGravity)
        }
        let bb = BallBehavior()
        bb.ball.start = position
        bb.ball.activity = !isAnchored
        bb.ball.frame = CGRect(x: position.x - 24, y: position.y - 24, width: 48, height: 48)
        scrollView.addSubview(bb.ball)
        bb.behavior.addItem(bb.ball)
        bb.behavior.isAnchored = isAnchored
        collision.addItem(bb.ball)
        ballBehaviors.append(bb)
        if isAnchored == false {
            ballGravity.addItem(bb.ball)
            bb.ball.activity = true
        }
    }
    
    func addAnchors(_ views: [UIView]) {
        views.forEach { view in
            dynamic.addItem(view)
            collision.addItem(view)
        }
    }
    
    func removeAnchors(_ views:[UIView]){
        views.forEach { view in
            dynamic.removeItem(view)
            collision.removeItem(view)
        }
    }
    
    // 锚点方块
    lazy var dynamic: UIDynamicItemBehavior = {
        let dynamic = UIDynamicItemBehavior()
        dynamic.isAnchored = true
        animator.addBehavior(dynamic)
        return dynamic
    }()
    
    // 碰撞
    lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        collision.collisionMode = .everything
        collision.translatesReferenceBoundsIntoBoundary = true
        collision.collisionDelegate = self
        animator.addBehavior(collision)
        return collision
    }()
    
    var rows: Array <UIStackView> = []
    
    func addRow(){
        let row = buildAnchorRow()
        rows.append(row)
        scrollView.layoutIfNeeded()
        let temp = row.arrangedSubviews.filter { view in
            if let view = view as? Rectangle {
                return view.isAnchored == true
            } else {
                return false
            }
        }
        addAnchors(temp)
    }
    
    func addBall(){
        if arc4random_uniform(4) == 1, let origin = rows.last {
            let centerX = CGFloat(arc4random_uniform(UInt32(self.bounds.width) - 60) + 30)
            createBall(CGPoint(x:centerX, y: (origin.frame.minY - 140.0)))
        }
    }
    
    var colors: [UIColor] = [.brown, .brown, .brown, .brown, .brown]
    
    func buildAnchorRow() -> UIStackView {
        let items = (0 ... 5).map { _ in
            let view = Rectangle()
            view.layer.cornerRadius = 4
            if [0, 1, 2].contains(arc4random_uniform(6)){
                view.backgroundColor = colors[Int(arc4random_uniform(5))]
            } else{
                view.isAnchored = false
            }
            return view
        }
        
        let anchored = items.filter { rg in
            rg.isAnchored == true
        }
        if anchored.count == 6 {
            // 添加一个出口
            let idx = Int(arc4random_uniform(6))
            let view = items[idx]
            view.backgroundColor = .clear
            view.isAnchored = false
        }
        
        let stack = UIStackView(arrangedSubviews:items)
        stack.frame = CGRect(x: 0, y: Int((rows.last?.frame.minY ?? 50) + rowHight), width: Int(bounds.width), height: 10)
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        scrollView.addSubview(stack)
        return stack
    }
}

extension GameView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if let top = rows.first {
            if top.frame.maxY < offsetY {
                rows.removeAll { stack in
                    top == stack
                }
                removeAnchors(top.arrangedSubviews)
                top.removeFromSuperview()
            }
        }
        
        if let bottom = rows.last {
            if bottom.frame.maxY < offsetY + CGRectGetHeight(scrollView.bounds) {
                addRow()
                addBall()
            }
        }else {
            addRow()
        }
    }
}

extension GameView: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        guard let ball1 = item1 as? Ball,
              let ball2 = item2 as? Ball else {
            return
        }
        var bb1, bb2 : BallBehavior?
        ballBehaviors.forEach { bb in
            if bb.ball == ball1 {
                bb1 = bb
            }else if bb.ball == ball2 {
                bb2 = bb
            }
        }
        guard let bb1 = bb1, let bb2 = bb2 else {
            return
        }
        // 发生碰撞,激活小球
        if bb1.ball.activity == false  {
            bb1.ball.activity = true
            ballGravity.addItem(bb1.ball)
        }
        if bb2.ball.activity == false  {
            bb2.ball.activity = true
            ballGravity.addItem(bb2.ball)
        }
        
        let newColor = UIColor.mixColors(color1: ball1.tintColor, color2: ball2.tintColor, ratio1: 0.5, ratio2: 0.5)
        ball1.tintColor = newColor
        ball2.tintColor = newColor
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint){
        guard let item = item as? Ball else {
            return
        }
        if abs(p.x) < 1 || abs(p.x) + 1 > self.bounds.width {
        } else {
            beginContact(item: item)
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        guard let ball = item as? Ball ,let bb = ballBehaviors.first(where: { bb in
            bb.ball == ball
        }) else {
            return
        }
        bb.behavior.isAnchored = false
    }
    
    func beginContact(item: UIDynamicItem) {
        guard let ball = item as? Ball ,let bb = ballBehaviors.first(where: { bb in
            bb.ball == ball
        }) else {
            return
        }
        removeBallBehavior(bb)
    }
    
    func removeBallBehavior(_ bb: BallBehavior){
        UIView.animate(withDuration: 0.5) {
            bb.ball.alpha = 0.0
        } completion: { _ in
            bb.ball.removeFromSuperview()
        }
        bb.behavior.removeItem(bb.ball)
        ballGravity.removeItem(bb.ball)
        collision.removeItem(bb.ball)
        ballBehaviors.removeAll { b in
            b == bb
        }
        deathScore += bb.ball.score
        // 判断是否有激活的小球
        if ballGravity.items.count <= 0 {
            fail()
        } else {
            if bb.ball.activity {
                AudioEffect.play(.broken)
            }
        }
    }
}

struct BallBehavior: Equatable {
    let behavior: UIDynamicItemBehavior
    let ball: Ball
    
    init(behavior: UIDynamicItemBehavior, ball: Ball) {
        self.behavior = behavior
        self.ball = ball
    }
    
    init(){
        let behavior = UIDynamicItemBehavior()
        behavior.resistance = 0
        behavior.elasticity = 0.5
        behavior.friction = 0
        let ball = Ball(type: .system)
        self.init(behavior: behavior, ball: ball)
    }
}

let ballTintColors: [UIColor] = [0xFF0000.rgbColor, 0x00FF00.rgbColor, 0x0000FF.rgbColor]

class Ball: UIButton {
    
    var start: CGPoint = .zero // 开始时偏移量
    var activity: Bool = false
    private var _score: Int = 0
    var score: Int {
        let cs = self.center.y - start.y
        _score = max(_score, Int(cs))
        return _score
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setImage("outline_sports_volleyball_black_48pt_".image, for: .normal)
        tintColor = ballTintColors[Int(arc4random_uniform(3))]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    lazy var ballImage : UIImageView = {
    //        let imageView = UIImageView(image: "outline_sports_volleyball_black_48pt_".image)
    //        addSubview(imageView)
    //        imageView.tintColor = .red
    //        imageView.snp.makeConstraints { make in
    //            make.edges.equalToSuperview()
    //        }
    //        return imageView
    //    }()
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class Rectangle: UIView {
    var isAnchored: Bool = true
}

