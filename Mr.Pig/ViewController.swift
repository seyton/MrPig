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
    
    var pigNode: SCNNode!
    var cameraNode: SCNNode!
    var cameraFollowNode: SCNNode!
    var lightFollowNode: SCNNode!
    var trafficNode: SCNNode!
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    
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
        
        pigNode = gameScene.rootNode.childNodeWithName("MrPig", recursively: true)
        
        cameraNode = gameScene.rootNode.childNodeWithName("camera", recursively: true)
        cameraNode.addChildNode(game.hudNode)
        
        cameraFollowNode = gameScene.rootNode.childNodeWithName("FollowCamera", recursively: true)
        lightFollowNode = gameScene.rootNode.childNodeWithName("FollowLight", recursively: true)
        trafficNode = gameScene.rootNode.childNodeWithName("Traffic", recursively: true)
    }
    
    func setupActions() {
     
        driveLeftAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        driveRightAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(2.0, 0, 0), duration: 1.0))
    }
    
    func setupTraffic() {
        
        for node in trafficNode.childNodes {
            
            if node.name?.containsString("Bus") == true {
                
                driveLeftAction.speed = 1.0
                driveRightAction.speed = 1.0
            }
            else {

                driveLeftAction.speed = 2.0
                driveRightAction.speed = 2.0
            }
            
            if node.eulerAngles.y < 0 {
                
                node.runAction(driveLeftAction)
            }
            else {
                
                node.runAction(driveRightAction)
            }
        }
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