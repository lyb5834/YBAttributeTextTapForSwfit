//
//  YBAttributeTextTapForSwfit.swift
//  YBAttributeTextTapForSwfit
//
//  Created by LYB on 16/7/7.
//  Copyright © 2016年 LYB. All rights reserved.
//

import UIKit

private var isTapAction : Bool?
private var attributeStrings : [YBAttributeModel]?
private var tapBlock : ((String , NSRange , Int) -> Void)?
private var isTapEffect : Bool = true
private var effectDic : Dictionary<String , NSAttributedString>?

extension UILabel {
    
    // MARK: - Objects
    /// 是否打开点击效果，默认是打开
    var enabledTapEffect : Bool {
        set {
            isTapEffect = newValue
        }
        get {
            return isTapEffect
        }
    }
    
    
    // MARK: - mainFunction
    /**
     给文本添加点击事件
     
     - parameter strings:   需要点击的字符串数组
     - parameter tapAction: 点击事件回调
     */
    func yb_addAttributeTapAction( strings : [String] , tapAction : ((String , NSRange , Int) -> Void)) -> Void {
        
        yb_getRange(strings)
        
        tapBlock = tapAction
        
    }
    
    // MARK: - touchActions
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTapAction == false {
            return
        }
        
        let touch = touches.first
        
        let point = touch?.locationInView(self)
        
        yb_getTapFrame(point!) { (String, NSRange, Int) -> Void in
            
            tapBlock! (String, NSRange , Int)
            
            if isTapEffect {
                self.yb_saveEffectDicWithRange(NSRange)
                self.yb_tapEffectWithStatus(true)
            }
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isTapEffect {
            self.performSelectorOnMainThread(#selector(self.yb_tapEffectWithStatus(_:)), withObject: nil, waitUntilDone: false)
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if isTapEffect {
            self.performSelectorOnMainThread(#selector(self.yb_tapEffectWithStatus(_:)), withObject: nil, waitUntilDone: false)
        }
    }
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if isTapAction == true {
            
            let result = yb_getTapFrame(point, result: { (
                String, NSRange, Int) -> Void in
                
            })
            
            if result == true {
                return self
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    
    // MARK: - getTapFrame
    private func yb_getTapFrame(point : CGPoint , result : ((String , NSRange , Int) -> Void)) -> Bool {
        
        let framesetter = CTFramesetterCreateWithAttributedString(self.attributedText!)
        
        var path = CGPathCreateMutable()
        
        
        CGPathAddRect(path, nil, self.bounds)
        
        var frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        
        let range = CTFrameGetVisibleStringRange(frame)
        
        if self.attributedText?.length > range.length {
            var m_font : UIFont
            let n_font = self.attributedText?.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil)
            if n_font != nil {
                m_font = n_font as! UIFont
            }else if (self.font != nil) {
                m_font = self.font
            }else {
                m_font = UIFont.systemFontOfSize(17)
            }
            
            path = CGPathCreateMutable()
            
            CGPathAddRect(path, nil, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + m_font.lineHeight))
            
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        }
        
        let lines = CTFrameGetLines(frame)
        
        if lines == [] {
            return false
        }
        
        let count = CFArrayGetCount(lines)
        
        var origins = [CGPoint](count: count, repeatedValue: CGPointZero)
        
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
        
        let transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.0, -1.0);
        
        let verticalOffset = 0.0
        
        for i : CFIndex in 0..<count {
            
            let linePoint = origins[i]
            
            let line = CFArrayGetValueAtIndex(lines, i)
            
            let lineRef = unsafeBitCast(line,CTLineRef.self)
            
            let flippedRect : CGRect = yb_getLineBounds(lineRef , point: linePoint)
            
            var rect = CGRectApplyAffineTransform(flippedRect, transform)
            
            rect = CGRectInset(rect, 0, 0)
            
            rect = CGRectOffset(rect, 0, CGFloat(verticalOffset))
            
            let style = self.attributedText?.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: nil)
            
            let lineSpace = style?.lineSpacing
            
            let lineOutSpace = (CGFloat(self.bounds.size.height) - CGFloat(lineSpace!) * CGFloat(count - 1) - CGFloat(rect.size.height) * CGFloat(count)) / 2
            
            rect.origin.y = lineOutSpace + rect.size.height * CGFloat(i) + lineSpace! * CGFloat(i)
            
            if CGRectContainsPoint(rect, point) {
                
                let relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect))
                
                var index = CTLineGetStringIndexForPosition(lineRef, relativePoint)
                
                var offset : CGFloat = 0.0
                
                CTLineGetOffsetForStringIndex(lineRef, index, &offset)
                
                if offset > relativePoint.x {
                    index = index - 1
                }
                
                let link_count = attributeStrings?.count
                
                for j in 0 ..< link_count! {
                    
                    let model = attributeStrings![j]
                    
                    let link_range = model.range

                    if NSLocationInRange(index, link_range!) {
                        
                        result(model.str!,model.range!,j)
                        
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func yb_getLineBounds(line : CTLineRef , point : CGPoint) -> CGRect {
        var ascent : CGFloat = 0.0;
        var descent : CGFloat = 0.0;
        var leading  : CGFloat = 0.0;
        
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        
        let height = ascent + fabs(descent) + leading
        
        return CGRect.init(x: point.x, y: point.y , width: CGFloat(width), height: height)
    }
    
    // MARK: - getRange
    private func yb_getRange(strings :  [String]) -> Void {
        
        if self.attributedText?.length == 0 {
            return;
        }
        
        isTapAction = true
        
        let style = self.attributedText?.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: nil)
        
        if style == nil {
            let sty = NSMutableParagraphStyle()
            sty.lineSpacing = 0
            let attStr = NSMutableAttributedString.init(attributedString: self.attributedText!)
            attStr.addAttribute(NSParagraphStyleAttributeName, value: sty, range: NSMakeRange(0, self.attributedText!.length))
            self.attributedText = attStr
        }
        
        var totalString = self.attributedText?.string
        
        attributeStrings = [];
        
        for str : String in strings {
            let range = totalString?.rangeOfString(str)
            
            if ((range?.startIndex.advancedBy(0)) != nil) {
                
                totalString = totalString?.stringByReplacingCharactersInRange(range!, withString: self.yb_getStringWithRange(range!))
                
                let model = YBAttributeModel()
                
                model.range = NSMakeRange(Int(String(range!.startIndex))!, Int(String(range!.endIndex))! - Int(String(range!.startIndex))!)
                model.str = str
                
                attributeStrings?.append(model)
            }
        }
    }
    
    private func yb_getStringWithRange(range : Range<String.Index>) -> String {
        var string : String = ""
        let count = Int(String(range.endIndex))! - Int(String(range.startIndex))!
        for _ in 0 ..< count {
            string = string + " "
        }
        return string
    }
    
    // MARK: - tapEffect
    private func yb_saveEffectDicWithRange(range : NSRange) -> Void {
        effectDic = [:]
        
        let subAttribute = self.attributedText?.attributedSubstringFromRange(range)
        
        effectDic?.updateValue(subAttribute!, forKey: NSStringFromRange(range))
    }
    
    @objc private func yb_tapEffectWithStatus(status : Bool) -> Void {
        if isTapEffect {
            let attStr = NSMutableAttributedString.init(attributedString: self.attributedText!)
            
            let subAtt = NSMutableAttributedString.init(attributedString: (effectDic?.values.first)!)
            
            let range = NSRangeFromString(effectDic!.keys.first!)
            
            if status {
                subAtt.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, subAtt.length))
                attStr.replaceCharactersInRange(range, withAttributedString: subAtt)
            }else {
                attStr.replaceCharactersInRange(range, withAttributedString: subAtt)
            }
            self.attributedText = attStr
        }
    }
}


private class YBAttributeModel: AnyObject {
    
    var range : NSRange?
    var str : String?
    
}