//
//  GameScene.swift
//  MazeRun
//
//  Created by Marcelo De Araújo on 23/03/23.
//

import CoreMotion
import SpriteKit

struct Collision {

    static let Ball: UInt32 = 0x1 << 0
    static let BlackHole: UInt32 = 0x1 << 1
    static let FinishHole: UInt32 = 0x1 << 2

    // representa os bits que serão usados para identificar as colisões.
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var manager: CMMotionManager?
    var ball: SKSpriteNode!
    var timer: Timer?
    var seconds: Double?


    override func didMove(to view: SKView) {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(increaseTimer), userInfo: nil, repeats: true)

        physicsWorld.contactDelegate = self

        ball = SKSpriteNode(imageNamed: "ball")
        ball.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        ball.physicsBody = SKPhysicsBody(circleOfRadius: CGRectGetHeight(ball.frame) / 2.0)
        ball.physicsBody?.mass = 4.5
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.isDynamic = true // necessary to detect collision
        ball.physicsBody?.categoryBitMask = Collision.Ball
        ball.physicsBody?.collisionBitMask = Collision.Ball
        ball.physicsBody?.contactTestBitMask = Collision.BlackHole | Collision.FinishHole
        ball.physicsBody?.affectedByGravity = false
        addChild(ball)

        manager = CMMotionManager()
        if let manager = manager, manager.isDeviceMotionAvailable {
            // esse intervalo é de quanto em quanto tempo o app vai pegar info do sensor do iphone. Ou seja, quanto maior, menos operações o App puxa do sensor, logo menos gasto de energia do iPhone.
            manager.deviceMotionUpdateInterval = 0.5
            manager.startDeviceMotionUpdates()
        }
    }

    override func update(_ currentTime: CFTimeInterval) {
        if let gravityX = manager?.deviceMotion?.gravity.x,
           let gravityY = manager?.deviceMotion?.gravity.y,
           ball != nil {
            // let newPosition = CGPoint(x: Double(ball.position.x) + gravityX * 35.0, y: Double(ball.position.y) + gravityY * 35.0)
            // let moveAction = SKAction.moveTo(newPosition, duration: 0.0)
            // ball.runAction(moveAction)

            // applyImpulse() is much better than applyForce()
            // ball.physicsBody?.applyForce(CGVector(dx: CGFloat(gravityX) * 5000.0, dy: CGFloat(gravityY) * 5000.0))

            ball.physicsBody?.applyImpulse(CGVector(dx: CGFloat(gravityX) * 200.0, dy: CGFloat(gravityY) * 200.0))

            /* O método update(_ currentTime:) é chamado em cada quadro do jogo para atualizar a posição da bola de acordo com o movimento do dispositivo. Ele usa o valor da gravidade medido pelo CMMotionManager para aplicar uma força na bola para movê-la na direção correta. */
        }
    }

    func centerBall() {
        ball.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        let moveAction = SKAction.move(to: CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame)), duration: 0.0)
        ball.run(moveAction)
    }

    func alertWon() {
        let alertController = UIAlertController(title: "Ganhou Boy", message: String(format: "Seu tempo foi de %.1f segundos", arguments: [seconds!]), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.resetTimer()
            self.centerBall()
        }
        alertController.addAction(okAction)
        if let rootViewController = view?.window?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: { () -> Void in
                self.centerBall()
            })
        }

        /* Os métodos centerBall() e alertWon() são chamados quando a bola deve ser reposicionada no centro da cena ou quando o jogador venceu o jogo, respectivamente. O método alertWon() exibe um alerta com a mensagem "Você ganhou" e o tempo que levou para vencer. */
    }

    @objc func increaseTimer() {
        seconds = (seconds ?? 0.0) + 0.01

        /* Os métodos increaseTimer() e resetTimer() são usados ​​para controlar o tempo de jogo. increaseTimer() incrementa o valor do contador de tempo em 0,01 segundo a cada quadro, enquanto resetTimer() redefine o valor do contador para 0. */
    }

    func resetTimer() {
        seconds = 0.0
    }
}

extension GameScene {
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == Collision.BlackHole || contact.bodyB.categoryBitMask == Collision.BlackHole {
            centerBall()
            resetTimer()
        } else if contact.bodyA.categoryBitMask == Collision.FinishHole || contact.bodyB.categoryBitMask == Collision.FinishHole {
            alertWon()
        }
    }

    /* A extension com o método didBeginContact(contact:) é chamado quando ocorre uma colisão entre os corpos físicos no mundo do jogo. Ele verifica se a colisão ocorreu com um buraco negro ou com um buraco de acabamento e chama centerBall() ou alertWon(). */
}
//import SpriteKit
//import GameplayKit
//
//class GameScene: SKScene {
//    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//    
//    override func didMove(to view: SKView) {
//        
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//        
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//    
//    
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//    
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//    
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//        
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//    
//    
//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//    }
//}
