//
//  ViewController.swift
//  YBAttributeTextTapForSwfit-Demo
//
//  Created by LYB on 16/9/7.
//  Copyright © 2016年 LYB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var label : UILabel
        label = UILabel.init(frame: CGRect.init(x: 10, y: 100, width: 350, height: 40))
        let str = "这是一个swfit Label,用的swfit三方框架"
        label.layer.borderWidth = 1;
        label.layer.borderColor = UIColor.grayColor().CGColor
        let attStr = NSMutableAttributedString.init(string: str)
        
        attStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(20), range: NSMakeRange(0, str.characters.count))
        attStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSMakeRange(4, 5))
        attStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: NSMakeRange(10, 5))
        attStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.purpleColor(), range: NSMakeRange(18, 5))
        
        label.attributedText = attStr
        label.textAlignment = NSTextAlignment.Center
        label.yb_addAttributeTapAction(["swfit","Label","swfit"]) { (string, range, int) in
            print("点击了\(string)标签 - \(range) - \(int)")
            //            let alert = UIAlertView.init(title: "提示", message: "您点击了" + String, delegate: nil, cancelButtonTitle: "OK")
            //            alert.show()
        }
        
        // MARK: 关闭点击效果 默认是开启的
        //        label.enabledTapEffect = false
        
        
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

