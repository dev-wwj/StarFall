//
//  BeginView.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/10.
//

import Foundation
import UIKit
import SnapKit
import GameKit

enum GameState {
    case ready
    case playing
    case pause
    case gameOver
}

protocol ControlPlayDelegate: NSObjectProtocol {
    
    func start()
    
    func pause()
    
}

protocol ControlResultDelegate: NSObjectProtocol {
    func restart()
    
    func gameCenter()
    
    func share(_ text: String)
}

class ControlView: UIView {
    
    weak var delegate: ControlPlayDelegate?
    weak var resultDelegate: ControlResultDelegate?
    
    var state: GameState = .ready
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var startBtn: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = UIColor(patternImage: "plywood".image)
        button.layer.cornerRadius = 10
        addSubview(button)
        button.setImage("outline_play_circle_black_36pt_".image, for: .normal)
        button.setTitle("Start".local, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageView?.contentMode = .scaleToFill
        button.titleLabel?.font = 22.fontHeavy
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 123))
        }
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        return button
    }()
    
    
    lazy var rightBarStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [soundOnOff])
        stack.spacing = 10
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaInsets.top + 10)
            make.right.equalTo(-safeAreaInsets.right - 20)
        }
        stack.transform = CGAffineTransformMakeTranslation(150, 0)
        return stack
    }()
    
    lazy var soundOnOff: UIButton = {
        let button = UIButton(type: .system)
        if UserDefaults.standard.bool(forKey: "SoundOnOff") == true {
            button.setImage("round_notifications_off_black_36pt_".image, for: .normal)
        } else {
            button.setImage("round_notifications_active_black_36pt_".image, for: .normal)
        }
        button.addTarget(self, action: #selector(soundSwitch), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    
    lazy var pauseBtn: UIButton = {
        let button = UIButton(type: .custom)
        addSubview(button)
        button.setImage("outline_pause_circle_black_36pt_".image, for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(pause), for: .touchUpInside)
        return button
    }()
    
    lazy var scoreL: UILabel =  {
        let label = UILabel()
        label.font = 20.fontBold
        label.textColor = .white
        label.text = "0"
        addSubview(label)
        label.transform = CGAffineTransformMakeTranslation(-100, 0)
        label.snp.makeConstraints { make in
            make.top.equalTo(safeAreaInsets.top + 20)
            make.left.equalTo(safeAreaInsets.left + 20)
        }
        return label
    }()
    
    lazy var resultVL: (ResultView, BubbleLabel) = {
        let view = ResultView()
        view.backgroundColor = UIColor(patternImage: "plywood".image)
        view.layer.cornerRadius = 10
        addSubview(view)
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 200 * (1.0 / 0.618)))
        }
        view.restart.addTarget(self, action: #selector(restart), for: .touchUpInside)
        view.gameCenter.addTarget(self, action: #selector(gameCenter), for: .touchUpInside)
        view.share.addTarget(self, action: #selector(share), for: .touchUpInside)
        view.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
        
        let label = BubbleLabel()
        label.text = "Shake to restart".local
        label.textColor = .white
        label.backgroundColor = UIColor(patternImage: "plywood".image)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.top)
        }
        label.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
        return (view, label)
    }()
    

    
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        _ = startBtn
        _ = rightBarStack
        _ = scoreL
    }
    
    @objc func play() {
        state = .playing
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.8) {
            self.backgroundColor = .black.withAlphaComponent(0.0)
            self.rightBarStack.transform = .identity
            self.startBtn.transform = CGAffineTransformMakeTranslation(-self.bounds.width, 0)
            self.scoreL.transform = .identity
        }
        delegate?.start()
    }
    
    @objc func pause() {
        state = .pause
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.backgroundColor = .black.withAlphaComponent(0.6)
            self.rightBarStack.transform = CGAffineTransformMakeTranslation(150, 0)
            self.startBtn.transform = .identity
        }
        delegate?.pause()
    }
    
    @objc func restart() {
        state = .playing
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.backgroundColor = .black.withAlphaComponent(0.0)
            self.resultVL.0.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
            self.resultVL.1.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
            self.rightBarStack.transform = .identity
            self.scoreL.transform = .identity
        }
        resultDelegate?.restart()
    }
    
    
    @objc func gameCenter(){
        resultDelegate?.gameCenter()
    }
    
    @objc func share(){
        let string = String(format: "ShareScoreFormat".local, self.resultVL.0.score)
        resultDelegate?.share(string)
    }
    
    @objc func soundSwitch() {
        let onOff = UserDefaults.standard.bool(forKey: "SoundOnOff") ?? false
        UserDefaults.standard.set(!onOff, forKey: "SoundOnOff")
        if !onOff == true {
            soundOnOff.setImage("round_notifications_off_black_36pt_".image, for: .normal)
        } else {
            soundOnOff.setImage("round_notifications_active_black_36pt_".image, for: .normal)
        }
    }
    
    func shakeToReStart(){
        if state == .gameOver {
            restart()
        }
    }
    
}

extension ControlView: GameDelegate {
    func running(_ view: GameView) {
        scoreL.text = "\(view.deathScore + view.liveScore)"
    }
    
    func gameOver(_ view: GameView) {
        state = .gameOver
        let score = view.deathScore
        self.resultVL.0.score = score
        self.resultVL.0.best = score
        self.resultVL.0.Animate_Shake()
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.backgroundColor = .black.withAlphaComponent(0.6)
            self.resultVL.0.transform = .identity
            self.resultVL.1.transform = .identity
            self.rightBarStack.transform = CGAffineTransformMakeTranslation(150, 0)
            self.scoreL.transform = CGAffineTransformMakeTranslation(-100, 0)
        }
        if !GKLocalPlayer.local.isAuthenticated {
            return
        }
        // 更新个人最高分
        let leaderboard = GKLeaderboard(players: [GKLocalPlayer.local])
        leaderboard.identifier = "max_running_classic" // 设置排行榜 ID
        leaderboard.timeScope = .allTime // 设置时间范围，这里使用“全部时间”
        leaderboard.playerScope = .global // 设置玩家范围，这里使用“全球”
        leaderboard.loadScores {[weak self] scores, error in
            if let _score = scores?.first?.value as? Int64 {
                if _score < score {
                    reportNew(Int64(score))
                }else {
                    self?.resultVL.0.best = Int(_score)
                }
            } else {
                reportNew(Int64(score))
            }
        }
        func reportNew(_ _score: Int64) {
            let score = GKScore(leaderboardIdentifier: "max_running_classic")
            score.value = _score
            score.shouldSetDefaultLeaderboard = true
            GKScore.report([score]) { error in
                if let error = error {
                    print("Error updating score: \(error.localizedDescription)")
                } else {
                    print("Score updated successfully!")
                }
            }
        }
    }
}

class ResultView: UIView  {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = stack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [scoreL, bestL , space(10), restart, space(10), socialStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return stack
    }()
    
    var score: Int = 0 {
        didSet {
            let attStr = NSMutableAttributedString(string: "\("Score".local):  ")
            let scoreStr = NSAttributedString(string: "\(score)",
                                              attributes: [.font: 32.fontBold,
                                                           .foregroundColor: UIColor.systemRed,
                                                           .baselineOffset: -4])
            attStr.append(scoreStr)
            scoreL.attributedText = attStr
        }
    }
    
    var best: Int = 0 {
        didSet {
            let attStr = NSMutableAttributedString(string: "\("Best".local):  ")
            let scoreStr = NSAttributedString(string: "\(best)", attributes: [.font: 32.fontBold, .foregroundColor: UIColor.systemYellow, .baselineOffset: -4])
            attStr.append(scoreStr)
            bestL.attributedText = attStr
        }
    }
    
    lazy var scoreL: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = "0"
        label.styleLargeNum()
        return label
    }()
    
    lazy var bestL: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.text = "0"
        label.styleLargeNum()
        return label
    }()
    
    lazy var restart: UIButton = {
        let button = UIButton(type: .system)
        button.setImage("baseline_replay_black_48pt_".image, for: .normal)
        button.tintColor = .magenta
        return button
    }()
    
    lazy var gameCenter: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage("gamecenter".image, for: .normal)
        button.isHidden = !GKLocalPlayer.local.isAuthenticated
        return button
    }()
    
    lazy var share: UIButton = {
        let button = UIButton(type: .system)
        button.setImage("outline_share_black_36pt_".image, for: .normal)
        return button
    }()
    
    func space(_ hight: CGFloat) -> UIView {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(hight)
        }
        return view
    }
    
    lazy var socialStack:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [gameCenter, share])
        stack.spacing = 40
        return stack
    }()
    
}


