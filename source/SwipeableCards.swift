//
//  SwipeableCards.swift
//  SwipeableCards
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit

private let kRotationStrength: CGFloat = 320
private let kRotationMax: CGFloat      = 1.0
private let kRotationAngle: CGFloat    = CGFloat(M_PI / 8)
private let kScaleStrength: CGFloat    = 4.0
private let kScaleMax: CGFloat         = 0.93
private let kActionMargin: CGFloat     = 120

public protocol SwipeableCardsDataSource {
    func numberOfTotalCards(cards: SwipeableCards) -> Int
    func viewFor(cards:SwipeableCards, index:Int, reusingView: UIView?) -> UIView
}
@objc public protocol SwipeableCardsDelegate {
    optional func cards(cards: SwipeableCards, beforeSwipingItemAtIndex index: Int)
    optional func cards(cards: SwipeableCards, didRemovedItemAtIndex index: Int)
    optional func cards(cards: SwipeableCards, didLeftRemovedItemAtIndex index: Int)
    optional func cards(cards: SwipeableCards, didRightRemovedItemAtIndex index: Int)
}

public class SwipeableCards: UIView {
    public var dataSource: SwipeableCardsDataSource? {
        didSet {
            reloadData()
        }
    }
    public var delegate: SwipeableCardsDelegate?
    /// Default is true
    public var showedCyclically = true {
        didSet {
            reloadData()
        }
    }
    /// We will creat this number of views, so not too many; default is 3
    public var numberOfVisibleItems = 3 {
        didSet {
            reloadData()
        }
    }
    /// Offset for the next card to the current card, (it will decide the cards appearance, the top card is on top-left, top, or bottom-right and so on; default is (5, 5)
    public var offset: (horizon: CGFloat, vertical: CGFloat) = (5, 5) {
        didSet {
            reloadData()
        }
    }
    /// If there is only one card, maybe you don't want to swipe it
    public var swipEnabled = true {
        didSet {
            panGestureRecognizer.enabled = swipEnabled
        }
    }
    /// The first visible card on top
    public var topCard: UIView? {
        get {
            return visibleCards.first
        }
    }
    
    // Mark - init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    /**
     Refresh to show data source
     */
    public func reloadData() {
        currentIndex = 0
        reusingView = nil
        visibleCards.removeAll()
        if let totalNumber = dataSource?.numberOfTotalCards(self) {
            let visibleNumber = numberOfVisibleItems > totalNumber ? totalNumber : numberOfVisibleItems
            for i in 0..<visibleNumber {
                if let card = dataSource?.viewFor(self, index: i, reusingView: reusingView) {
                    visibleCards.append(card)
                }
            }
        }
        layoutCards()
    }
    
    // Mark - Private
    private var currentIndex = 0
    private var reusingView: UIView? = nil
    private var visibleCards = [UIView]()
    private var swipeEnded = true
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAction))
    private var xFromCenter: CGFloat = 0
    private var yFromCenter: CGFloat = 0
    private var originalPoint = CGPointZero

}

// MARK: - Private
private extension SwipeableCards {
    
    private func setUp() {
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func layoutCards() {
        let count = visibleCards.count
        guard count > 0 else {
            return
        }
        
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        self.layoutIfNeeded()
        
        let width = frame.size.width
        let height = frame.size.height
        
        if let lastCard = visibleCards.last {
            let cardWidth = lastCard.frame.size.width
            let cardHeight = lastCard.frame.size.height
            if let totalNumber = dataSource?.numberOfTotalCards(self) {
                let visibleNumber = numberOfVisibleItems > totalNumber ? totalNumber : numberOfVisibleItems
                var firstCardX = (width - cardWidth - CGFloat(visibleNumber - 1) * fabs(offset.horizon)) * 0.5
                if offset.horizon < 0 {
                    firstCardX += CGFloat(visibleNumber - 1) * fabs(offset.horizon)
                }
                var firstCardY = (height - cardHeight - CGFloat(visibleNumber - 1) * fabs(offset.vertical)) * 0.5
                if offset.vertical < 0 {
                    firstCardY += CGFloat(visibleNumber - 1) * fabs(offset.vertical)
                }
                
                UIView.animateWithDuration(0.08) {
                    for i in 0..<count {
                        let index = count - 1 - i   //add cards form back to front
                        let card = self.visibleCards[index]
                        let size = card.frame.size
                        card.frame = CGRect(x: firstCardX + CGFloat(index) * self.offset.horizon, y: firstCardY + CGFloat(index) * self.offset.vertical, width: size.width, height: size.height)
                        self.addSubview(card)
                    }
                }
            }
        }
    }
    
    @objc private func dragAction(gestureRecognizer: UIPanGestureRecognizer) {
        guard visibleCards.count > 0 else {
            return
        }
        if let totalNumber = dataSource?.numberOfTotalCards(self) {
            if currentIndex > totalNumber - 1 {
                currentIndex = 0
            }
        }
        if swipeEnded {
            swipeEnded = false
            delegate?.cards?(self, beforeSwipingItemAtIndex: currentIndex)
        }
        if let firstCard = visibleCards.first {
            xFromCenter = gestureRecognizer.translationInView(firstCard).x  // positive for right swipe, negative for left
            yFromCenter = gestureRecognizer.translationInView(firstCard).y  // positive for up, negative for down
            switch gestureRecognizer.state {
            case .Began:
                originalPoint = firstCard.center
            case .Changed:
                let rotationStrength: CGFloat = min(xFromCenter / kRotationStrength, kRotationMax)
                let rotationAngel = kRotationAngle * rotationStrength
                let scale = max(1.0 - fabs(rotationStrength) / kScaleStrength, kScaleMax)
                firstCard.center = CGPoint(x: originalPoint.x + xFromCenter, y: originalPoint.y + yFromCenter)
                let transform = CGAffineTransformMakeRotation(rotationAngel)
                let scaleTransform = CGAffineTransformScale(transform, scale, scale)
                firstCard.transform = scaleTransform
            case .Ended:
                aflerSwipedAction(firstCard)
            default:
                break
            }
        }
    }
    private func aflerSwipedAction(card: UIView) {
        if xFromCenter > kActionMargin {
            rightActionFor(card)
        } else if xFromCenter < -kActionMargin {
            leftActionFor(card)
        } else {
            self.swipeEnded = true
            UIView.animateWithDuration(0.3) {
                card.center = self.originalPoint
                card.transform = CGAffineTransformMakeRotation(0)
            }
        }
        
    }
    private func rightActionFor(card: UIView) {
        let finishPoint = CGPoint(x: 500, y: 2.0 * yFromCenter + originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            card.center = finishPoint
        }) { (Bool) in
            self.delegate?.cards?(self, didRightRemovedItemAtIndex: self.currentIndex)
            self.cardSwipedAction(card)
        }
    }
    private func leftActionFor(card: UIView) {
        let finishPoint = CGPoint(x: -500, y: 2.0 * yFromCenter + originalPoint.y)
        UIView.animateWithDuration(0.3, animations: {
            card.center = finishPoint
        }) { (Bool) in
            self.delegate?.cards?(self, didLeftRemovedItemAtIndex: self.currentIndex)
            self.cardSwipedAction(card)
        }
    }
    
    private func cardSwipedAction(card: UIView) {
        swipeEnded = true
        card.transform = CGAffineTransformMakeRotation(0)
        card.center = originalPoint
        let cardFrame = card.frame
        reusingView = card
        visibleCards.removeFirst()
        card.removeFromSuperview()
        var newCard: UIView?
        if let totalNumber = dataSource?.numberOfTotalCards(self) {
            var newIndex = currentIndex + numberOfVisibleItems
            if newIndex < totalNumber {
                newCard = dataSource?.viewFor(self, index: newIndex, reusingView: reusingView)
            } else {
                if showedCyclically {
                    if totalNumber==1 {
                        newIndex = 0
                    } else {
                        newIndex %= totalNumber
                    }
                    newCard = dataSource?.viewFor(self, index: newIndex, reusingView: reusingView)
                }
            }
            if let card = newCard {
                card.frame = cardFrame
                visibleCards.append(card)
            }
            delegate?.cards?(self, didRemovedItemAtIndex: currentIndex)
            currentIndex += 1
            layoutCards()
        }
    }
}
