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

    var collisionNode: SCNNode!
    var frontCollisionNode: SCNNode!
    var backCollisionNode: SCNNode!
    var leftCollisionNode: SCNNode!
    var rightCollisionNode: SCNNode!
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    
    var triggerGameOver: SCNAction!
    
    let BitMaskPig = 1
    let BitMaskVehicle = 2
    let BitMaskObstacle = 4
    let BitMaskFront = 8
    let BitMaskBack = 16
    let BitMaskLeft = 32
    let BitMaskRight = 64
    let BitMaskCoin = 128
    let BitMaskHouse = 256
    
    var activeCollisionsBitMask: Int = 0

    //MARK: - Methods
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
        scnView.delegate = self
    }
    
    func setupNodes() {
        
        pigNode = gameScene.rootNode.childNodeWithName("MrPig", recursively: true)
        
        cameraNode = gameScene.rootNode.childNodeWithName("camera", recursively: true)
        cameraNode.addChildNode(game.hudNode)
        
        cameraFollowNode = gameScene.rootNode.childNodeWithName("FollowCamera", recursively: true)
        lightFollowNode = gameScene.rootNode.childNodeWithName("FollowLight", recursively: true)
        trafficNode = gameScene.rootNode.childNodeWithName("Traffic", recursively: true)
        
        collisionNode = gameScene.rootNode.childNodeWithName("Collisions", recursively: true)
        frontCollisionNode = gameScene.rootNode.childNodeWithName("Front", recursively: true)
        backCollisionNode = gameScene.rootNode.childNodeWithName("Back", recursively: true)
        leftCollisionNode = gameScene.rootNode.childNodeWithName("Left", recursively: true)
        rightCollisionNode = gameScene.rootNode.childNodeWithName("Right", recursively: true)
        
        pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse
        
        frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        
    }
    
    func setupActions() {
     
        driveLeftAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        driveRightAction = SCNAction.repeatActionForever(SCNAction.moveBy(SCNVector3Make(2.0, 0, 0), duration: 1.0))
        
        let duration = 0.2
        
        let bounceUpAction = SCNAction.moveByX(0, y: 1.0, z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveByX(0, y: -1.0, z: 0, duration: duration * 0.5)
        
        bounceUpAction.timingMode = .EaseOut
        bounceDownAction.timingMode = .EaseIn
        
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        
        let moveLeftAction = SCNAction.moveByX(-1, y: 0, z: 0, duration: duration)
        let moveRightAction = SCNAction.moveByX(1, y: 0, z: 0, duration: duration)
        let moveForwardAction = SCNAction.moveByX(0, y: 0, z: -1.0, duration: duration)
        let moveBackwardAction = SCNAction.moveByX(0, y: 0, z: 1.0, duration: duration)
        
        let turnLeftAction = SCNAction.rotateToX(0, y: convertToRadians(-90), z: 0, duration: duration, shortestUnitArc: true)
        let turnRightAction = SCNAction.rotateToX(0, y: convertToRadians(90), z: 0, duration: duration, shortestUnitArc: true)
        let turnForwardAction = SCNAction.rotateToX(0, y: convertToRadians(180), z: 0, duration: duration, shortestUnitArc: true)
        let turnBackwardAction = SCNAction.rotateToX(0, y: convertToRadians(0), z: 0, duration: duration, shortestUnitArc: true)
        
        jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
        jumpRightAction = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
        jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
        jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
        
        let spinAround = SCNAction.rotateByX(0, y: convertToRadians(720), z: 0, duration: 2.0)
        let riseUp = SCNAction.moveByX(0, y: 10, z: 0, duration: 2.0)
        let fadeOut = SCNAction.fadeOpacityTo(0, duration: 2.0)
        let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
        
        let gameOver = SCNAction.runBlock { (node) in
            
            self.pigNode.position = SCNVector3Zero
            self.pigNode.opacity = 1.0
            self.startSplash()
        }
        
        triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
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
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: .handleGesture)
        swipeRight.direction = .Right
        scnView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: .handleGesture)
        swipeLeft.direction = .Left
        scnView.addGestureRecognizer(swipeLeft)
        
        let swipeForward = UISwipeGestureRecognizer(target: self, action: .handleGesture)
        swipeForward.direction = .Up
        scnView.addGestureRecognizer(swipeForward)
        
        let swipeBackward = UISwipeGestureRecognizer(target: self, action: .handleGesture)
        swipeBackward.direction = .Down
        scnView.addGestureRecognizer(swipeBackward)
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
    
    //MARK: - Movement Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if game.state == .TapToPlay {
            startGame()
        }
    }
    
    func handleGesture(sender: UISwipeGestureRecognizer) {

        guard game.state == .Playing else {
            return
        }
        
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Up:
            pigNode.runAction(jumpForwardAction)
            
        case UISwipeGestureRecognizerDirection.Down:
            pigNode.runAction(jumpBackwardAction)
            
        case UISwipeGestureRecognizerDirection.Left:
            
            if pigNode.position.x > -15 {
                pigNode.runAction(jumpLeftAction)
            }
            
        case UISwipeGestureRecognizerDirection.Right:
            
            if pigNode.position.x < 15 {
                pigNode.runAction(jumpRightAction)
            }
        default:
            break
        }
    }
    
    func updatePositions() {
        
        collisionNode.position = pigNode.presentationNode.position
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
        pigNode.runAction(triggerGameOver)
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

//MARK: - SCNSceneRendererDelegate
extension ViewController: SCNSceneRendererDelegate {
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        guard game.state == .Playing else {
            return
        }
        
        game.updateHUD()
        updatePositions()
    }
}

//MARK: - Selector
private extension Selector {
    
    static let handleGesture = #selector(ViewController.handleGesture(_:))
}
