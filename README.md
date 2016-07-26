# SwipeableCards
A container of views (like cards) can be dragged!<br>
---
视图容器，视图以卡片形式层叠放置，可滑动。<br>
---
There are only visible cards in memory, after you drag and removed the top one, it will be reused as the last one.<br>
内存中只会生成可见的卡片，顶部的卡片被划走之后，会作为最后一张卡片循环利用。<br>

pod surpported: pod 'SwipeableCards'<br>
支持pod : pod 'SwipeableCards'<br>

![SwipeableCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/0.png)
![SwipeableCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/1.png)
![SwipeableCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/3.png)

Usage:<br>
---
Here is an example:<br>
用法示例：<br>
```
@IBOutlet weak var cards: SwipeableCards!
    var cardsData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCardsData()
        cards.dataSource = self
        cards.delegate = self
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

```
