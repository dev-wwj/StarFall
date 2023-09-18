//
//  ViewController.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/4.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        game = GameView(frame: view.bounds.inset(by: view.safeAreaInsets))
//        view.addSubview(game)
//        game.delegate = control
        _ = bg
        addBottomFire()
        addTopFire()
        _ = control
        
        GKLocalPlayer.local.authenticateHandler = { vc, err in
        }
    }
    
    lazy var bg: UIImageView = {
        let imageView = UIImageView(image: "bg_texture".image)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return imageView
    }()
        
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        initGame()
    }
    
    weak var gameView: GameView?
    
    func initGame(){
        if gameView != nil {
            return
        }
        let gameView = GameView()
        view.insertSubview(gameView, belowSubview: control)
        gameView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaInsets)
        }
        gameView.delegate = control
        control.delegate = gameView
        view.layoutIfNeeded()
        self.gameView = gameView
    }
    
    lazy var control: ControlView = {
        let control = ControlView()
        control.resultDelegate = self
        view.addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return control
    }()
}

extension ViewController {
    
    func addBottomFire(){
        // 创建发射器层
        let fireLayer = CAEmitterLayer()
        fireLayer.frame = view.bounds
        view.layer.addSublayer(fireLayer)
        // 设置发射器属性
        fireLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        fireLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.maxY)
        fireLayer.emitterShape = .line
        fireLayer.emitterMode = .outline
        fireLayer.renderMode = .additive
        // 创建火焰粒子
        let fireCell = CAEmitterCell()
        fireCell.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.1).cgColor
        fireCell.contents = UIImage(named: "fire")?.cgImage
        fireCell.birthRate = 300
        fireCell.lifetime = 0.9
        fireCell.lifetimeRange = 0.315
        fireCell.velocity = -10
        fireCell.velocityRange = 30
        fireCell.emissionLongitude = .pi
        fireCell.emissionRange = .pi / 8
        fireCell.scale = 1.0
        fireCell.scaleSpeed = 0.2
        fireCell.scaleRange = 0.1
        // 将火焰粒子添加到发射器层中
        fireLayer.emitterCells = [fireCell]
    }
    
    func addTopFire(){
        // 创建发射器层
        let fireLayer = CAEmitterLayer()
        fireLayer.frame = view.bounds
        view.layer.addSublayer(fireLayer)
        // 设置发射器属性
        fireLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        fireLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: 0)
        fireLayer.emitterShape = .line
        fireLayer.emitterMode = .outline
        fireLayer.renderMode = .additive
        // 创建火焰粒子
        let fireCell = CAEmitterCell()
        fireCell.color = UIColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 0.1).cgColor
        let fire = UIImage(named: "fire")!
        fireCell.contents = UIImage(cgImage: fire.cgImage!, scale: fire.scale, orientation: .downMirrored).cgImage
        fireCell.birthRate = 300
        fireCell.lifetime = 0.9
        fireCell.lifetimeRange = 0.315
        fireCell.velocity = 10
        fireCell.velocityRange = 30
        fireCell.emissionLongitude = -.pi
        fireCell.emissionRange = .pi / 8
        fireCell.scale = 1.0
        fireCell.scaleSpeed = 0.2
        fireCell.scaleRange = 0.5
        // 将火焰粒子添加到发射器层中
        fireLayer.emitterCells = [fireCell]
    }
}

extension ViewController: ControlResultDelegate {
    func share(_ text: String) {
        let text = text // 要分享的文本内容
        let image = UIImage(named: "icon_share") // 要分享的图片
        let activityViewController = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // 设置 iPad 上的弹出位置
        self.present(activityViewController, animated: true, completion: nil) // 弹出分享页面
    }
    
    func gameCenter() {
       let gameCenter = GKGameCenterViewController()
        gameCenter.gameCenterDelegate = self
        gameCenter.viewState = .leaderboards
        gameCenter.leaderboardIdentifier = "max_running_classic"
        self.present(gameCenter, animated: true, completion: nil) // 在当前视图控制器中弹出排行榜页面
    }
    
    func restart() {
        gameView?.removeFromSuperview()
        gameView = nil
        initGame()
        self.gameView?.start()
    }
}

extension ViewController: GKGameCenterControllerDelegate{
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
}

extension ViewController {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            control.shakeToReStart()
        }
    }
}
