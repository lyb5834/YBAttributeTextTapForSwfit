# YBAttributeTextTapForSwfit
一行代码添加文本点击事件(swfit版本)/a fast way to implement click event text(for swfit)

# 效果图
![(演示效果)](http://7xt3dd.com1.z0.glb.clouddn.com/attributeAction.gif)

# Object-C版本
 https://github.com/lyb5834/YBAttributeTextTapAction.git


#使用方法
* 设置 `label.attributedText = ？？？？？` 
* `label.yb_addAttributeTapAction(["xx","xx"...]) { (string, range, int) in coding more... }`
* PS:数组里输入的要点击的字符可以重复

#重要提醒
  * 使用本框架时，最好设置一下`NSParagraphStyle中`的`lineSpacing`属性，也就是行间距，如果不设置，则默认为0！
  * 使用本框架时，一定要设置`label.attributedText = ？？？？？` ，不设置则无效果！！
  * 默认添加点击效果，关闭只需设置`label.enabledTapEffect = NO`即可
  
#版本支持
  * `xcode7.0+`

  * 如果您在使用本库的过程中发现任何bug或者有更好建议，欢迎联系本人email  lyb5834@126.com
