# SwipeableCards
A container of views (like cards) can be dragged!<br>
---
视图容器，视图以卡片形式层叠放置，可滑动。<br>
---
There are only visible cards in memory, after you drag and removed the top one, it will be reused as the last one.<br>
内存中只会生成可见的卡片，顶部的卡片被划走之后，会作为最后一张卡片循环利用。<br>

You can find an Objective-C version here:<br>
你可以在这里找到Objective-C版：[iCards](https://github.com/DingHub/iCards)<br>

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
        for i in 0..<100 {
            cardsData.append(i)
        }
    }
    
    // SwipeableCardsDataSource methods
    func numberOfTotalCards(in cards: SwipeableCards) -> Int {
        return cardsData.count
    }
    func view(for cards: SwipeableCards, index: Int, reusingView: UIView?) -> UIView {
        var label: UILabel? = reusingView as? UILabel
        if label == nil {
            let labelFrame = CGRect(x: 0, y: 0, width: cardsWidth.constant - 30, height: cardsHeight.constant - 20)
            label = UILabel(frame: labelFrame)
            label!.textAlignment = .center
            label!.layer.cornerRadius = 5
        }
        label!.text = String(cardsData[index])
        label!.layer.backgroundColor = Color.random.cgColor
        return label!
    }
    
    // SwipeableCardsDelegate methods
    func cards(_ cards: SwipeableCards, beforeSwipingItemAt index: Int) {
        print("Begin swiping card \(index)!")
    }
    func cards(_ cards: SwipeableCards, didLeftRemovedItemAt index: Int) {
        print("<--\(index)")
    }
    func cards(_ cards: SwipeableCards, didRightRemovedItemAt index: Int) {
        print("\(index)-->")
    }
    func cards(_ cards: SwipeableCards, didRemovedItemAt index: Int) {
        print("index of removed card:\(index)")
    }

```
