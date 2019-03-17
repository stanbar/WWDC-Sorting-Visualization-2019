//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode!
    private var areaNode : SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector.zero
        
        
        // Create shape node to use during mouse interaction
        let w = (size.width + size.height) * CGFloat.random(in: 0.0...0.1)
        
        spinnyNode = SKShapeNode(rectOf: CGSize(width: w, height: w), cornerRadius: w * 0.3)
        
//        areaNode = SKLabelNode(text: String(Float(w) * Float(w)))
//        spinnyNode.addChild(areaNode)
        spinnyNode.lineWidth = 2.5
        
        let maxRadius = max(spinnyNode.frame.size.width/2, spinnyNode.frame.size.height/2)
        let interPersonSeparationConstant: CGFloat = 1.25
        let physicBody = SKPhysicsBody(circleOfRadius: maxRadius*interPersonSeparationConstant)
        physicBody.friction = 1.0
        spinnyNode.physicsBody = physicBody
        

        spinnyNode.run(.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 1)))

    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        guard let n = spinnyNode.copy() as? SKShapeNode else { return }
        n.position = pos
        n.setScale(CGFloat.random(in: 0.0...2.0))
        n.strokeColor = SKColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: CGFloat.random(in: 0.0...1.0))
        
        addChild(n)
        sort()
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        guard let n = self.spinnyNode.copy() as? SKShapeNode else { return }
//
//        n.position = pos
//        n.strokeColor = SKColor.blue
//        addChild(n)
//        sort()
    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    func sort(){
        if children.count < 2 { return }
        for _ in 0...children.count {
            for value in 1...children.count - 1 {
                if area(children[value-1]) > area(children[value]) {
                    replace(children[value-1], children[value])
                }
            }
        }
    }
    func area(_ node : SKNode) -> CGFloat{
        return node.frame.width * node.frame.height
    }
    
    func replace(_ first : SKNode, _ second : SKNode){
        let firstReplace = SKAction.move(to: second.position, duration: 0.5)
        
        let secondReplace = SKAction.move(to: first.position, duration: 0.5)
        second.run(secondReplace)
        first.run(firstReplace)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}


// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
sceneView.showsDrawCount = true
sceneView.showsNodeCount = true
sceneView.showsFPS = true
let scene = GameScene(size: CGSize(width: 640, height: 480))
// Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill

// Present the scene
sceneView.presentScene(scene)


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
