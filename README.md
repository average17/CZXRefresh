# CZXRefresh

[github项目地址](https://github.com/average17/CZXRefresh)

### 可以cocoapod导入
![cocoapod搜索](https://github.com/average17/CZXRefresh/blob/master/screenshots/cocoapod.png)


### 也可以下载之后手动导入
先把.xcodeproj文件拖到项目下

![手动第一步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_1.png)

然后配置项目文件

![手动第二步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_2.png)

添加framework

![手动第三步](https://github.com/average17/CZXRefresh/blob/master/screenshots/manual_3.png)

在需要使用的文件中import框架即可使用
```
import CZXRefresh
```

# 使用方法

下拉刷新和上拉加载都可以在UITableView和UICollectionView中使用，一下以UITableView为例，UICollection用法相同。

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

## 下拉刷新视图的几种类型

## 上拉加载视图的几种类型

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

## 设置拖抓过程中是否自动改变透明度
默认都为true，也就是拖拽过程中随着拖拽距离的增加，透明度降低；如果为false，当开始拖拽时就是不透明的。
```
header.isAutoOpacity = true
footer.isAutoOpacity = false
```

## 设置是否自动刷新
header的该属性默认为false，也就是拖拽过程中有一个状态是提示松手开始刷新，如果设置为true，当拖拽到一定距离之后就直接开始刷新了
footer的该属性默认为true，也就是拖拽到一定距离直接开始刷新，如果设置为false，则加载视图会停留在底部，你可以点击刷新或者上拉刷新
```
header.isAutoRefresh = true
footer.isAutoRefresh = false
```
