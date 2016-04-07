//
//  AppDelegate.swift
//  MrPig
//
//  Created by Wesley Matlock on 4/5/16.
//  Copyright (c) 2016 insoc.net. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {
    
    let game = GameHelper.sharedInstance
    
    var scnView: SCNView!
    var gameScene: SCNScene!
    var splashScene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScenes()
        setupNodes()
        setupActions()
        setupTraffic()
        setupGestures()
        setupSounds()
        
        game.state = .TapToPlay
    }
    
    func setupScenes() {
        
        scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        
        gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn")
        
        scnView.scene = splashScene
    }
    
    func setupNodes() {
    }
    
    func setupActions() {
        
    }
    
    func setupTraffic() {
    }
    
    func setupGestures() {
    }
    
    func setupSounds() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if game.state == .TapToPlay {
            startGame()
        }
    }
    
    //MARK: - Gmae Methods
    func startGame() {
        
        splashScene.paused = true
        
        let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)
        
        scnView.presentScene(gameScene, withTransition: transition, incomingPointOfView: nil) { 
            
            self.game.state = .Playing
            self.setupSounds()
            self.gameScene.paused = false
        }
    }
    
    func stopGame() {
    
        game.state = .GameOver
        game.reset()
    }
    
    func startSplash() {
    
        gameScene.paused = true

        let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)
        
        scnView.presentScene(splashScene, withTransition: transition, incomingPointOfView: nil) { 
            
            self.game.state = .TapToPlay
            self.setupSounds()
            self.splashScene.paused = false
        }
    }
    
}