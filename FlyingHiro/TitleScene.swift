//
//  File.swift
//  FlyingHiro
//
//  Created by Yoo SeungHwan on 2016/09/29.
//  Copyright © 2016年 Yoo SeungHwan. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let titleLabelNode = SKLabelNode(fontNamed:"Chalkduster")
        titleLabelNode.text = "Flying HIRO";
        titleLabelNode.fontSize = 48;
        titleLabelNode.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        self.addChild(titleLabelNode)
        
        let startLabelNode = SKLabelNode(fontNamed: "Copperplate")
        startLabelNode.text = "Start"
        startLabelNode.fontSize = 36
        startLabelNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 100)
        startLabelNode.name = "Start"
        self.addChild(startLabelNode)
    }
    
    // 「Start」ラベルをタップしたら、GameSceneへ遷移させる。
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch:UITouch = touches.first!        
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        if (touchedNode.name != nil) {
            if touchedNode.name == "Start" {
                let newScene = GameScene(size: (self.scene?.size)!)
                newScene.scaleMode = SKSceneScaleMode.aspectFill
                self.view?.presentScene(newScene)
            }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
