//
//  SwipeableCards.swift
//  SwipeableCards
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit

private struct Const {
    static let rotationStrength: CGFloat = 320
    static let rotationMax: CGFloat      = 1.0
    static let rotationAngle: CGFloat    = .pi * 0.125
    static let scaleStrength: CGFloat    = 4.0
    static let scaleMax: CGFloat         = 0.93
    static let actionMargin: CGFloat     = 120
}

public protocol SwipeableCardsDataSource {
    func numberOfTotalCards(in cards: SwipeableCards) -> Int
    func view(for cards:SwipeableCards, index:Int, reusingView: UIView?) -> UIView
}
public protocol SwipeableCardsDelegate {
    func cards(_ cards: SwipeableCards, beforeSwipingItemAt index: Int)
    func cards(_ cards: SwipeableCards, didRemovedItemAt index: Int)
    func cards(_ cards: SwipeableCards, didLeftRemovedItemAt index: Int)
    func cards(_ cards: SwipeableCards, didRightRemovedItemAt index: Int)
}
extension SwipeableCardsDelegate {// This extesion makes the methods optionnal for use~
    func cards(_ cards: SwipeableCards, beforeSwipingItemAt index: Int) {}
    func cards(_ cards: SwipeableCards, didRemovedItemAt index: Int) {}
    func cards(_ cards: SwipeableCards, didLeftRemovedItemAt index: Int) {}
    func cards(_ cards: SwipeableCards, didRightRemovedItemAt index: Int) {}
}

public class SwipeableCards: UIView {
    /// DataSource
    public var dataSource: SwipeableCardsDataSource? {
        didSet {
            reloadData()
        }
    }
    /// Delegate
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
            panGestureRecognizer.isEnabled = swipEnabled
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
        if let totalNumber = dataSource?.numberOfTotalCards(in: self) {
            let visibleNumber = numberOfVisibleItems > totalNumber ? totalNumber : numberOfVisibleItems
            for i in 0..<visibleNumber {
                if let card = dataSource?.view(for: self, index: i, reusingView: reusingView) {
                    visibleCards.append(card)
                }
            }
        }
        layoutCards()
    }
    
    // Mark - Private
    fileprivate var currentIndex = 0
    fileprivate var reusingView: UIView? = nil
    fileprivate var visibleCards = [UIView]()
    fileprivate var swipeEnded = true
    fileprivate lazy var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragAction))
    fileprivate var xFromCenter: CGFloat = 0
    fileprivate var yFromCenter: CGFloat = 0
    fileprivate var originalPoint = CGPoint.zero
}

// MARK: - Private
private extension SwipeableCards {
    func setUp() {
        self.addGestureRecognizer(panGestureRecognizer)
    }
    func layoutCards() {
        let count = visibleCards.count
        guard count > 0 else {
            return
        }
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        layoutIfNeeded()
        let width = frame.size.width
        let height = frame.size.height
        if let lastCard = visibleCards.last {
            let cardWidth = lastCard.frame.size.width
            let cardHeight = lastCard.frame.size.height
            if let totalNumber = dataSource?.numberOfTotalCards(in: self) {
                let visibleNumber = numberOfVisibleItems > totalNumber ? totalNumber : numberOfVisibleItems
                var firstCardX = (width - cardWidth - CGFloat(visibleNumber - 1) * fabs(offset.horizon)) * 0.5
                if offset.horizon < 0 {
                    firstCardX += CGFloat(visibleNumber - 1) * fabs(offset.horizon)
                }
                var firstCardY = (height - cardHeight - CGFloat(visibleNumber - 1) * fabs(offset.vertical)) * 0.5
                if offset.vertical < 0 {
                    firstCardY += CGFloat(visibleNumber - 1) * fabs(offset.vertical)
                }
                
                UIView.animate(withDuration: 0.08) {
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
    @objc func dragAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard visibleCards.count > 0 else {
            return
        }
        if let totalNumber = dataSource?.numberOfTotalCards(in: self) {
            if currentIndex > totalNumber - 1 {
                currentIndex = 0
            }
        }
        if swipeEnded {
            swipeEnded = false
            delegate?.cards(self, beforeSwipingItemAt: currentIndex)
        }
        if let firstCard = visibleCards.first {
            xFromCenter = gestureRecognizer.translation(in: firstCard).x  // positive for right swipe, negative for left
            yFromCenter = gestureRecognizer.translation(in: firstCard).y  // positive for up, negative for down
            switch gestureRecognizer.state {
            case .began:
                originalPoint = firstCard.center
            case .changed:
                let rotationStrength: CGFloat = min(xFromCenter / Const.rotationStrength, Const.rotationMax)
                let rotationAngel = Const.rotationAngle * rotationStrength
                let scale = max(1.0 - fabs(rotationStrength) / Const.scaleStrength, Const.scaleMax)
                firstCard.center = CGPoint(x: originalPoint.x + xFromCenter, y: originalPoint.y + yFromCenter)
                let transform = CGAffineTransform(rotationAngle: rotationAngel)
                let scaleTransform = transform.scaledBy(x: scale, y: scale)
                firstCard.transform = scaleTransform
            case .ended:
                aflerSwipedAction(firstCard)
            default:
                break
            }
        }
    }
    func aflerSwipedAction(_ card: UIView) {
        if xFromCenter > Const.actionMargin {
            rightActionFor(card)
        } else if xFromCenter < -Const.actionMargin {
            leftActionFor(card)
        } else {
            self.swipeEnded = true
            UIView.animate(withDuration: 0.3) {
                card.center = self.originalPoint
                card.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
        
    }
    func rightActionFor(_ card: UIView) {
        let finishPoint = CGPoint(x: 500, y: 2.0 * yFromCenter + originalPoint.y)
        UIView.animate(withDuration: 0.3, animations: {
            card.center = finishPoint
        }) { (Bool) in
            self.delegate?.cards(self, didRightRemovedItemAt: self.currentIndex)
            self.cardSwipedAction(card)
        }
    }
    func leftActionFor(_ card: UIView) {
        let finishPoint = CGPoint(x: -500, y: 2.0 * yFromCenter + originalPoint.y)
        UIView.animate(withDuration: 0.3, animations: {
            card.center = finishPoint
        }) { (Bool) in
            self.delegate?.cards(self, didLeftRemovedItemAt: self.currentIndex)
            self.cardSwipedAction(card)
        }
    }
    func cardSwipedAction(_ card: UIView) {
        swipeEnded = true
        card.transform = CGAffineTransform(rotationAngle: 0)
        card.center = originalPoint
        let cardFrame = card.frame
        reusingView = card
        visibleCards.removeFirst()
        card.removeFromSuperview()
        var newCard: UIView?
        if let totalNumber = dataSource?.numberOfTotalCards(in: self) {
            var newIndex = currentIndex + numberOfVisibleItems
            if newIndex < totalNumber {
                newCard = dataSource?.view(for: self, index: newIndex, reusingView: reusingView)
            } else {
                if showedCyclically {
                    if totalNumber==1 {
                        newIndex = 0
                    } else {
                        newIndex %= totalNumber
                    }
                    newCard = dataSource?.view(for: self, index: newIndex, reusingView: reusingView)
                }
            }
            if let card = newCard {
                card.frame = cardFrame
                visibleCards.append(card)
            }
            delegate?.cards(self, didRemovedItemAt: currentIndex)
            currentIndex += 1
            layoutCards()
        }
    }
}
