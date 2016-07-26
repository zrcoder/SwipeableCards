//
//  ViewController.swift
//  SwipeableCards
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 Ding. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SwipeableCardsDataSource, SwipeableCardsDelegate, UITableViewDelegate {

    
    @IBOutlet weak var cards: SwipeableCards!
    var cardsData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCardsData()
        cards.dataSource = self
        cards.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func makeCardsData() {
        for i in 0..<5 {
            cardsData.append(i)
        }
    }
    
    @IBAction func changeOffset(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            cards.offset = (5, 5)
        case 1:
            cards.offset = (0, 5)
        case 2:
            cards.offset = (-5, 5)
        case 3:
            cards.offset = (-5, -5)
        default:
            break
        }
        
    }
    @IBAction func changeNumber(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            cards.numberOfVisibleItems = 3
        case 1:
            cards.numberOfVisibleItems = 2
        case 2:
            cards.numberOfVisibleItems = 5
        default:
            break
        }
    }
    @IBAction func changeSycllyState(sender: UISwitch) {
        cards.showedCyclically = sender.on
    }
    // SwipeableCardsDataSource methods
    func numberOfTotalCards(cards: SwipeableCards) -> Int {
        return cardsData.count
    }
    func viewFor(cards: SwipeableCards, index: Int, reusingView: UIView?) -> UIView {
        var label: UILabel? = view as? UILabel
        if label == nil {
            let size = cards.frame.size
            let labelFrame = CGRect(x: 0, y: 0, width: size.width - 30, height: size.height - 20)
            label = UILabel(frame: labelFrame)
            label!.textAlignment = .Center
            label!.layer.cornerRadius = 5
        }
        label!.text = String(cardsData[index])
        label!.layer.backgroundColor = Color.randomColor().CGColor
        return label!
    }
    
    // SwipeableCardsDelegate
    func cards(cards: SwipeableCards, beforeSwipingItemAtIndex index: Int) {
        print("Begin swiping card \(index)!")
    }
    func cards(cards: SwipeableCards, didLeftRemovedItemAtIndex index: Int) {
        print("<--\(index)")
    }
    func cards(cards: SwipeableCards, didRightRemovedItemAtIndex index: Int) {
        print("\(index)-->")
    }
    func cards(cards: SwipeableCards, didRemovedItemAtIndex index: Int) {
        print("index of removed card:\(index)")
    }

}

