import Foundation
import SpriteKit

public class ResetButtonNode: SKSpriteNode {
    
    // MARK: Properties
    
    public weak var delegate: ResetButtonNodeDelegate?
    
    // MARK: Lifecycle
    
    public init() {
        let texture = SKTexture(imageNamed: "reset-button")
        let color = SKColor.red
        let size = CGSize(width: 135, height: 50)
        super.init(texture: texture, color: color, size: size)
        
        isUserInteractionEnabled = true
        zPosition = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touch Handling
    
    public override func mouseDown(with event: NSEvent) {
        alpha = 0.5
    }
    
    public override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        if location.isInside(node: self) {
            let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }
        else {
            performButtonAppearanceResetAnimation()
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        performButtonAppearanceResetAnimation()
        let location = event.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapReset(sender: self)
        }
    }
    
    public override func mouseExited(with event: NSEvent) {
        performButtonAppearanceResetAnimation()
    }
    
    // MARK: Helper Functions
    
    func performButtonAppearanceResetAnimation() {
        let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
        alphaAction.timingMode = .easeInEaseOut
        run(alphaAction)
    }
    
}

// MARK: ResetButtonNodeDelegate

public protocol ResetButtonNodeDelegate: class {
    func didTapReset(sender: ResetButtonNode)
}
