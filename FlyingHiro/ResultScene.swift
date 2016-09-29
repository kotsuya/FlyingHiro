//
//  ResultScene.swift
//  FlyingHiro
//
//  Created by Yoo SeungHwan on 2016/09/29.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

import SpriteKit

class ResultScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let ud = UserDefaults.standard
        let score = ud.integer(forKey: "score")
        var bestScore = ud.integer(forKey: "bestScore")
        
        let scoreLabel = SKLabelNode(fontNamed:"Copperplate")
        scoreLabel.text = "SCORE:\(score)";
        scoreLabel.fontSize = 72;
        scoreLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY);
        self.addChild(scoreLabel)
        
        
        if score > bestScore {
            ud.set(score, forKey: "bestScore")
            bestScore = score
        }
        
        let hiLabel = SKLabelNode(fontNamed:"Copperplate")
        hiLabel.text = "Highest Score:\(bestScore)";
        hiLabel.fontSize = 36;
        hiLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY-100);
        self.addChild(hiLabel)
        
        let backLabel = SKLabelNode(fontNamed: "Copperplate")
        backLabel.text = "Back"
        backLabel.fontSize = 36
        backLabel.position = CGPoint(x: self.frame.midX, y: 200)
        backLabel.name = "Back"
        self.addChild(backLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch:UITouch = touches.first!
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        if (touchedNode.name != nil) {
            if touchedNode.name == "Back" {
                
                let newScene = TitleScene(size: (self.scene?.size)!)
                newScene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(newScene)
            }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

