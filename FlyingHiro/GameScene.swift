//
//  GameScene.swift
//  FlyingHiro
//
//  Created by Yoo SeungHwan on 2016/09/28.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let hiroMask : UInt32 = 0x1 << 0
    let enemyMask : UInt32 = 0x1 << 1
    let missileMask : UInt32 = 0x1 << 2
    let groundMask : UInt32 = 0x1 << 3
    
    enum objectsZPosition: CGFloat {
        case background = 0
        case ground = 1
        case score = 2
        case hiro = 3
        case missile = 4
        case enemy = 5
        case gameOver = 6
    }
    
    var gameOver:Bool = false
    var movingGameObjects = SKNode()
    var background = SKSpriteNode()
    
    var hiroNode = SKSpriteNode()
    
    var ground = SKSpriteNode()
    
    var scoreLabelNode = SKLabelNode()
    var score :Int = 0
    
    var gameOverLabelNode = SKLabelNode()
    var restartLabelNode = SKLabelNode()
    
    var missileNode = SKSpriteNode()
    
    var enemyNode = SKSpriteNode()
    var enemySpawnSpeed:TimeInterval = 1.0
    
    var backgroundAudio = AVPlayer(url:NSURL(fileURLWithPath:Bundle.main.path(forResource: "Conquest",ofType:"mp3")!) as URL)
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -15)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(movingGameObjects)
        
        backgroundAudio.play()
        
        createBackground()
        createHiro()
        createGround()
        createScore()
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(GameScene.loadMissile), userInfo:nil, repeats:true)
        _ = Timer.scheduledTimer(timeInterval: enemySpawnSpeed, target: self, selector:#selector(GameScene.loadEnemy), userInfo:nil, repeats:true)
        
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector:#selector(GameScene.successAction), userInfo:nil, repeats:false)
    }
    
    func successAction() {
        
        backgroundAudio.pause()
        
        let action : SKAction = SKAction.playSoundFileNamed("victory.mp3", waitForCompletion: false)
        self.run(action)
        
        self.physicsWorld.contactDelegate = nil
        movingGameObjects.speed = 0
        gameOver = true
        
        gameOverLabelNode = SKLabelNode(fontNamed:"Copperplate-bold")
        gameOverLabelNode.fontColor = SKColor.white
        gameOverLabelNode.fontSize = 50
        gameOverLabelNode.name = "result"
        gameOverLabelNode.zPosition = objectsZPosition.gameOver.rawValue
        gameOverLabelNode.text = "Success Mission!"
        gameOverLabelNode.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        self.addChild(gameOverLabelNode)
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 1)
        let scale = SKAction.scale(to:1, duration:0.25)
        let scaleSequence = SKAction.sequence([scaleUp,scale])
        let repeate = SKAction.repeatForever(scaleSequence)
        gameOverLabelNode.run(repeate)
        
//        self.run(action, withKey:"BGM")
    }
    
    func resultAction() {
        
        let ud = UserDefaults.standard
        ud.set(score, forKey: "score")
        
        let newScene = ResultScene(size: (self.scene?.size)!)
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        newScene.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(newScene, transition: transition)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //print("\(contact.bodyA.contactTestBitMask)...\(contact.bodyB.contactTestBitMask)")
        //print("\(contact.bodyA.collisionBitMask),,,\(contact.bodyB.collisionBitMask)")
        
        if contact.bodyA.categoryBitMask == missileMask || contact.bodyB.categoryBitMask == missileMask {

            let action : SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: true)
            self.run(action)
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            score += 1
            scoreLabelNode.text = "\(score)"
            
            let miTexture = SKTexture(imageNamed: "Explosion.png")
            let explosionNode = SKSpriteNode(texture:miTexture)
            
            explosionNode.size = CGSize(width: explosionNode.size.width, height: explosionNode.size.height)
            explosionNode.position = CGPoint(x:contact.contactPoint.x, y:contact.contactPoint.y )
            
            let scaleUp = SKAction.scale(to: 1.5, duration:0.25)
            let scale = SKAction.scale(to:1, duration:0.25)
            let removeTexture = SKAction.removeFromParent()
            let spaceshipSequence = SKAction.sequence([scaleUp,scale,removeTexture])
            explosionNode.run(spaceshipSequence)
            movingGameObjects.addChild(explosionNode)
            
        } else if contact.bodyA.categoryBitMask == enemyMask || contact.bodyB.categoryBitMask == enemyMask {
            
            backgroundAudio.pause()
            
            self.physicsWorld.contactDelegate = nil
            movingGameObjects.speed = 0
            gameOver = true
            
            gameOverLabelNode = SKLabelNode(fontNamed:"Copperplate-bold")
            gameOverLabelNode.fontColor = SKColor.white
            gameOverLabelNode.fontSize = 50
            gameOverLabelNode.zPosition = objectsZPosition.gameOver.rawValue
            gameOverLabelNode.text = "Game Over"
            gameOverLabelNode.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
            self.addChild(gameOverLabelNode)
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 1)
            let scale = SKAction.scale(to:1, duration:0.25)
            let scaleSequence = SKAction.sequence([scaleUp,scale])
            gameOverLabelNode.run(scaleSequence, completion: {
                
                self.restartLabelNode = SKLabelNode(fontNamed: "Copperplate")
                self.restartLabelNode.fontSize = 50
                self.restartLabelNode.fontColor = SKColor.white
                self.restartLabelNode.zPosition = objectsZPosition.gameOver.rawValue
                self.restartLabelNode.position = CGPoint(x:self.frame.midX, y:self.frame.midY - self.gameOverLabelNode.frame.height - 80)
                
                self.restartLabelNode.text = "Tap to restart"
                self.restartLabelNode.name = "restart"
                self.addChild(self.restartLabelNode)
                
                let scaleUp = SKAction.scale(to: 1.5, duration: 1)
                let scale = SKAction.scale(to:1, duration:0.25)
                let wait = SKAction.wait(forDuration: 1.0)
                let scaleSequence = SKAction.sequence([wait,scaleUp,scale,wait])
                let repeate = SKAction.repeatForever(scaleSequence)
                self.restartLabelNode.run(repeate)
            })
        }
    }
    
    func restartAction() {
        self.removeAllChildren()
        self.removeAllActions()
        
        let gameScene = GameScene(size: self.size)
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        gameScene.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(gameScene, transition: transition)
    }
    
    func createScore() {
        scoreLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        scoreLabelNode.fontSize = 50
        scoreLabelNode.fontColor = SKColor.white
        scoreLabelNode.position = CGPoint(x:self.frame.midX, y:self.frame.height - 50)
        
        scoreLabelNode.text = "\(score)"
        scoreLabelNode.zPosition = objectsZPosition.score.rawValue
        self.addChild(scoreLabelNode)
    }
    
    func loadEnemy() {
        let enemyTexture = SKTexture(imageNamed: "Enemy")
        
        enemyNode = SKSpriteNode(texture:enemyTexture)
        
        enemyNode.size = CGSize(width: enemyNode.size.width*0.5, height: enemyNode.size.height*0.5)
        
        let randomY: CGFloat = CGFloat(arc4random_uniform(UInt32(self.frame.height)))
        
        enemyNode.position = CGPoint(x:self.frame.width + enemyNode.size.width, y:randomY )
        enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: enemyNode.size.height / 2)//rectangleOf: enemyNode.size)
        enemyNode.physicsBody?.categoryBitMask = enemyMask
        enemyNode.physicsBody?.contactTestBitMask = missileMask | hiroMask
        enemyNode.physicsBody?.collisionBitMask = missileMask | hiroMask
        enemyNode.physicsBody?.isDynamic = false
        enemyNode.physicsBody?.allowsRotation = false
        
        enemyNode.zPosition = objectsZPosition.enemy.rawValue
        
        enemySpawnSpeed -= 0.1
        
        let movePipe = SKAction.moveTo(x: -enemyNode.size.width-self.frame.width/2, duration: 7)
        let removePipe = SKAction.removeFromParent()
        let spaceshipSequence = SKAction.sequence([movePipe, removePipe])
        enemyNode.run(spaceshipSequence)
        movingGameObjects.addChild(enemyNode)
        
    }
    
    func loadMissile() {//
        let missileTexture = SKTexture(imageNamed: "Missile")
        missileNode = SKSpriteNode(texture:missileTexture)
        
        missileNode.size = CGSize(width: missileNode.size.width/2, height: missileNode.size.height/2)
        missileNode.position = CGPoint(x:hiroNode.position.x+hiroNode.size.width, y:hiroNode.position.y)
        
        missileNode.physicsBody = SKPhysicsBody(rectangleOf: hiroNode.size)
        missileNode.physicsBody?.categoryBitMask = missileMask
        missileNode.physicsBody?.contactTestBitMask = enemyMask
        missileNode.physicsBody?.collisionBitMask = enemyMask
        missileNode.physicsBody?.allowsRotation = false
        missileNode.physicsBody?.affectedByGravity = false
        
        missileNode.zPosition = objectsZPosition.missile.rawValue
        
        let miY = hiroNode.position.y-hiroNode.size.height/2
        let movePipe = SKAction.move(to: CGPoint(x:self.frame.width+hiroNode.size.width/2, y:miY), duration: 3)
        let removePipe = SKAction.removeFromParent()
        let spaceshipSequence = SKAction.sequence([movePipe, removePipe])
        missileNode.run(spaceshipSequence)
        movingGameObjects.addChild(missileNode)
    }
    
    func createGround() {
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:self.frame.width,  height:1))
        ground.position = CGPoint(x: self.frame.midX, y: self.frame.midY - self.frame.height / 2 )
        ground.zPosition = objectsZPosition.ground.rawValue
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundMask
        ground.physicsBody?.contactTestBitMask = hiroMask
        ground.physicsBody?.collisionBitMask = hiroMask
        
        movingGameObjects.addChild(ground)
        
    }
    
    func createHiro() {
        
        let hiroTexture = SKTexture(imageNamed:"Hiro.png")
        hiroNode = SKSpriteNode(texture: hiroTexture)
        hiroNode.position = CGPoint(x: self.frame.midX - hiroTexture.size().width*2, y: self.frame.midY + hiroTexture.size().height*2)
        hiroNode.zPosition = objectsZPosition.hiro.rawValue
        hiroNode.size = CGSize(width:hiroTexture.size().width, height:hiroTexture.size().height)
        
        hiroNode.physicsBody = SKPhysicsBody(circleOfRadius: hiroNode.size.height / 2)
        hiroNode.physicsBody?.categoryBitMask = hiroMask
        hiroNode.physicsBody?.contactTestBitMask = groundMask | enemyMask
        hiroNode.physicsBody?.collisionBitMask = groundMask | enemyMask
        hiroNode.physicsBody?.allowsRotation = false
 
        movingGameObjects.addChild(hiroNode)
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        let moveBackground = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 12)
        let replaceBackgtound = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
        let backgroundSequence = SKAction.sequence([moveBackground,replaceBackgtound])
        let moveBackgroundForever = SKAction.repeatForever(backgroundSequence)
        
        for i in 0..<2 {
            background = SKSpriteNode(texture: backgroundTexture)
                    
            let xx:CGFloat = CGFloat(i)
            background.position = CGPoint(x:backgroundTexture.size().width * xx, y: self.frame.midY)
            background.size.height = self.frame.height
            background.zPosition = objectsZPosition.background.rawValue
            background.run(moveBackgroundForever)
            movingGameObjects.addChild(background)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            hiroNode.physicsBody?.velocity = CGVector(dx:0, dy:0)
            hiroNode.physicsBody?.applyImpulse(CGVector(dx:0, dy:hiroNode.size.height*1.5))
            
            let rotateUp = SKAction.rotate(toAngle: 0.2, duration: 0)
            hiroNode.run(rotateUp)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            let rotateDown = SKAction.rotate(toAngle: -0.1, duration: 0)
            hiroNode.run(rotateDown)
        } else {
            let touch:UITouch = touches.first!
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if (touchedNode.name != nil) {
                if touchedNode.name == "restart" {
                    restartAction()
                } else if touchedNode.name == "result" {
                    resultAction()
                }
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       // for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
