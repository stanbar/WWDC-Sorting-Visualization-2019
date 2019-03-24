import Foundation
import SpriteKit

public class QuickSortButtonNode: SKSpriteNode {
    
    // MARK: Properties
    
    public weak var delegate: QuickSortButtonNodeDelegate?
    
    // MARK: Lifecycle
    
    public init() {
        let texture = SKTexture(imageNamed: "quick-sort")
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
    
    public override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        if location.isInside(node: self) {
            // Touch Up Inside
            delegate?.didTapSortType(sender: self)
        }
    }
    
    // MARK: Helper Functions
    
    public func select(_ selected : Bool){
        if selected{
            let alphaAction = SKAction.fadeAlpha(to: 1.0, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }else{
            let alphaAction = SKAction.fadeAlpha(to: 0.5, duration: 0.10)
            alphaAction.timingMode = .easeInEaseOut
            run(alphaAction)
        }
    }
    
}

// MARK: ResetButtonNodeDelegate

public protocol QuickSortButtonNodeDelegate: class {
    func didTapSortType(sender: QuickSortButtonNode)
}
