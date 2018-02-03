# CZXRefresh

[github项目地址](https://github.com/average17/CZXRefresh)

### 可以cocoapod导入
![cocoapod搜索](https://github.com/average17/CZXRefresh/blob/master/screenshots/cocoapod.png)


### 也可以下载之后手动导入
先把CZXRefresh.xcodeproj文件拖到项目下

![手动第一步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_1.png)

然后配置项目文件

![手动第二步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_2.png)

添加framework

![手动第三步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_3.png)

---------------------------------------------------

# 使用方法
在需要使用的文件中import框架即可使用
```
import CZXRefresh
```

下拉刷新和上拉加载都可以在UITableView和UICollectionView中使用，以下以UITableView为例，UICollection用法相同。

## 添加默认的下拉刷新
```
tableView.czx_headerView = RefreshHeaderView(action: () -> ())
// or
tableView.czx_headerView = RefreshHeaderView(type: .default, action: () -> ())
```

## 添加默认的上拉加载
```
tableView.czx_footerView = RefreshFooterView(action: () -> ())
// or
tableView.czx_footerView = RefreshFooterView(type: .default, action: () -> ())
```

其中action参数可以直接使用闭包传值，也可以先定义函数再将函数传入
例如:
```
tableView.czx_headerView = RefreshHeaderView(type: .default, action: headerRefresh)
...
func headerRefresh() {
    DispatchQueue.global().async {
        print("-------------------------正在刷新 header")
        sleep(2)
        DispatchQueue.main.async {
            [weak self] in
            print("-------------------------刷新完成 header")
            self?.cellCount = 20
            self?.cellName = "刷新"
            self?.tableView.reloadData()
            self?.tableView.czx_headerView?.stopRefresh()
        }
    }
}
```

## 刷新完成、加载完成和加载完所有数据
当我们刷新的数据请求到之后，或者加载的数据加载完之后，我们需要调用相应的方法来收起刷新或暂停加载
```
self?.tableView.czx_headerView?.stopRefresh()  //刷新完成

self?.tableView.czx_footerView?.stopRefresh()  //加载完成
self?.tableView.czx_footerView?.endRefresh()  //加载完所有数据
```
使用示例如下：
```
func headerRefresh() {
    DispatchQueue.global().async {
        print("-------------------------正在刷新 header")
        sleep(2)
        DispatchQueue.main.async {
            [weak self] in
            print("-------------------------刷新完成 header")
            self?.cellCount = 20
            self?.cellName = "刷新"
            self?.tableView.reloadData()
            self?.tableView.czx_headerView?.stopRefresh()
        }
    }
}

...

func footerRefresh() {
    DispatchQueue.global().async {
        print("-------------------------正在加载 footer")
        sleep(2)
        DispatchQueue.main.async {
            [weak self] in
            print("-------------------------加载完成 footer")
            self?.cellCount += 20
            self?.tableView.reloadData()
            if self!.cellCount <= 40 {
                self?.tableView.czx_footerView?.stopRefresh()
            } else {
                print("-------------------------加载完所有数据 footer")
                self?.tableView.czx_footerView?.endRefresh()
            }
        }
    }
}
```

## 下拉刷新视图的几种类型
default类型(包含图片和文字，还有刷新时间)

![header_default](https://github.com/average17/CZXRefresh/blob/master/screenshots/header_default.png)

imageAndText类型(包含图片和文字)

![header_imageAndText](https://github.com/average17/CZXRefresh/blob/master/screenshots/header_imageAndText.png)

image类型(只有图片)

![header_image](https://github.com/average17/CZXRefresh/blob/master/screenshots/header_image.png)

text类型(只有文字)

![header_text](https://github.com/average17/CZXRefresh/blob/master/screenshots/header_text.png)

custom类型(用户自定义)

## 上拉加载视图的几种类型
default类型(包含图片和文字)

![footer_default](https://github.com/average17/CZXRefresh/blob/master/screenshots/footer_default.png)

image类型(只包含图片)

![footer_image](https://github.com/average17/CZXRefresh/blob/master/screenshots/footer_image.png)

text类型(只包含文字)

![footer_text](https://github.com/average17/CZXRefresh/blob/master/screenshots/footer_text.png)

custom类型(用户自定义)


## 设置刷新视图高度和拖拽高度
默认的刷新视图和拖拽的距离是50，如果觉得不够的话，可以自己设置(需要在刷新视图或加载视图初始化之前设置)
```
//设置刷新视图高度
defaultHeaderHeight = 200
//设置刷新视图拖拽高度
defaultHeaderPullHeight = 70
//设置加载视图高度
defaultFooterHeight = 200
//设置加载视图拖拽高度
defaultFooterPullHeight = 70
```

## 设置刷新视图或加载视图的背景视图
可以自己定义喜欢的背景视图，例如UIImageView甚至是自定义的UIView，只要是UIView的子类都可以作为刷新和加载视图的背景视图
```
let imageView1 = UIImageView(image: UIImage(named: "22"))
let imageView2 = UIImageView(image: UIImage(named: "22"))

let header = RefreshHeaderView(type: .default, action: headerRefresh)
header.backgroundView = imageView1 //自定义背景视图
tableView.czx_headerView = header

let footer = RefreshFooterView(type: .default, action: footerRefresh)
footer.backgroundView = imageView2 //自定义背景视图
tableView.czx_footerView = footer
```

## 设置拖拽过程中是否自动改变透明度
默认都为true，也就是拖拽过程中随着拖拽距离的增加，透明度降低；如果为false，当开始拖拽时就是不透明的。
```
header.isAutoOpacity = true
footer.isAutoOpacity = false
```

## 设置是否自动刷新
header的该属性默认为false，也就是拖拽过程中有一个状态是提示松手开始刷新，如果设置为true，当拖拽到一定距离之后就直接开始刷新了

footer的该属性默认为true，也就是拖拽到一定距离直接开始刷新，如果设置为false，则加载视图会停留在底部，你可以点击加载或者上拉加载
```
header.isAutoRefresh = true
footer.isAutoRefresh = false
```

## 自定义下拉时图片位置的视图
为方便自定义，这里没有规定有图片的类型图片处必须使用UIImageView，只要是UIView都可以
```
let imageView = UIImageView(image: UIImage(named: "11"))
header.normalView = imageView
```
此处normalView为UIView类型

同时也可以自己定义下拉时的动画
```
header.setpullingAnimation { (view, percent) in
    view.alpha = percent
}
```
此处设置动画时需要传入一个参数为UIView和CGFloat的闭包，此处的view为刚刚设置的视图，percent为下拉的距离与拖拽高度的百分比。

## 自定义松手开始刷新时图片位置的视图
定义方法类似以上定义下拉时的视图和动画，就直接贴代码了
```
header.releaseToRefreshView = imageView
header.setReleaseToRefreshAnimation { (view) in
    UIView.animate(withDuration: 0.5, animations: {
        view.alpha = 0.2
    })
}
```

## 自定义刷新时图片位置的视图
定义方式也同样类似
```
header.refreshingView = imageView
header.setRefreshingAnimation { (view) in
    UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse], animations: {
        view.alpha = 0.2
    }, completion: nil)
}
```

## 自定义刷新完成时的图片位置的视图
```
header.refreshedView = imageView
```
刷新完成时不提供自定义动画

## 自定义上拉时图片位置的视图
上拉加载自定义图片位置的视图也可以像下拉刷新那样自定哦
```
let imageView = UIImageView(image: UIImage(named: "11"))
footer.staticView = imageView
footer.setPullingAnimation { (view, percent) in
    view.alpha = percent
}
```
view为添加的自定义上拉时的视图，percent为上拉的距离与上拉加载高度的百分比

## 自定义加载时图片位置的视图
```
footer.dynamicView = imageView
footer.setDynamicAnimation { (view) in
    UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse], animations: {
        view.alpha = 0.2
    }, completion: nil)
}
```

## 自定义数据加载完时图片位置的视图
```
footer.endView = imageView
```
加载结束的自定义动画不提供

## 纯用户自定义下拉刷新
如果你觉得，以上下拉刷新的四种布局你都不喜欢的话，好，咱们来自己定义

首先，你需要遵循CustomHeaderRefreshDelegate协议，并实现其中的七个方法(四个分别用于设置下拉时的视图、松手开始刷新时的视图、刷新时的视图、刷新完成的视图，三个分别用于设置下拉时的动画、松手开始刷新时的动画、刷新时的动画)

然后你需要设置刷新时的代理，示例代码如下：

![headerdelegate](https://github.com/average17/CZXRefresh/blob/master/screenshots/header.png)

```
let header = RefreshHeaderView(type: .custom, action: headerRefresh)
tableView.czx_headerView = header
tableView.czx_headerView?.delegate = self  //也可以使用header.delegate = self

......

func setNormalView() -> UIView {
    let image = UIImage(named: "1")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setReleaseToRefreshView() -> UIView {
    let image = UIImage(named: "2")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setRefreshingView() -> UIView {
    let image = UIImage(named: "3")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setRefreshedView() -> UIView {
    let image = UIImage(named: "22")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setPullingAnimation(view: UIView, percent: CGFloat) {
    view.alpha = percent
}

func setReleaseToRefreshAnimation(view: UIView) {
    UIView.animate(withDuration: 0.3) {
        view.transform = view.transform.rotated(by: CGFloat.pi)
    }
}

func setRefreshingAnimation(view: UIView) {
    UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat, .autoreverse], animations: {
        view.alpha = 0.2
    }, completion: nil)
}
```

## 纯用户自定义上拉加载
如果你觉得，以上上拉加载的三种布局你也都不喜欢的话，好，咱们也可以来自己定义

首先，你需要遵循CustomFooterRefreshDelegate协议，并实现其中的五个方法(三个分别用于设置上拉时的视图、加载时的视图、加载完成的视图，两个分别用于设置上拉时的动画、加载时的动画)

然后你需要设置加载时的代理，示例代码如下：

![footerdelegate](https://github.com/average17/CZXRefresh/blob/master/screenshots/footer.png)

```
let footer = RefreshFooterView(type: .custom, action: footerRefresh)
tableView.czx_footerView = footer
tableView.czx_footerView?.delegate = self  //也可以使用footer.delegate = self

......

func setNormalView() -> UIView {
    let image = UIImage(named: "1")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setRefreshingView() -> UIView {
    let image = UIImage(named: "2")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setEndRefreshView() -> UIView {
    let image = UIImage(named: "3")
    let imageView = UIImageView(image: image!)
    return imageView
}

func setPullingAnimation(view: UIView, percent: CGFloat) {
    view.alpha = percent
}

func setRefreshingAnimation(view: UIView) {
    UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat, .autoreverse], animations: {
        view.alpha = 0.2
    }, completion: nil)
}
```
