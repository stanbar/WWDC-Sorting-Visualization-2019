import Foundation
import SpriteKit

public class BubbleSortButtonNode: SKSpriteNode {
    
    // MARK: Properties
    
    public weak var delegate: BubbleSortButtonNodeDelegate?
    
    // MARK: Lifecycle
    
    public init() {
        let texture = SKTexture(imageNamed: "bubble-sort")
        let color = SKColor.red
        let size = CGSize(width: 40, height: 40)
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
            delegate?.didTapSortType(sender: self)
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

public protocol BubbleSortButtonNodeDelegate: class {
    func didTapSortType(sender: BubbleSortButtonNode)
}
