//
//  RefreshHeaderView.swift
//  CZXRefresh
//
//  Created by 陈主昕 on 2018/1/27.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit

public final class RefreshHeaderView: UIView {

    // MARK: private property
    /// 能否刷新
    fileprivate var canBegin = true
    /// isFirst和isSecond用于获取初始偏移量
    fileprivate var isFirst: Bool = true
    fileprivate var isSecond: Bool = true
    /// 初始偏移量
    fileprivate var initOffsetY: CGFloat = CGFloat()
    /// 父滚动视图
    fileprivate var superScrollView: UIScrollView?
    /// 文本提示
    fileprivate var textLabel: UILabel = UILabel()
    fileprivate var normalText: String = "下拉刷新"
    fileprivate var releaseToRefreshText: String = "松手开始刷新"
    fileprivate var refreshingText: String = "正在刷新..."
    fileprivate var refreshedText: String = "刷新完成"
    fileprivate var timeLabel: UILabel = UILabel()
    fileprivate var timeString: String = ""
    /// 动态提示
    fileprivate var hintView: UIView = UIView()
    fileprivate var normalImageView: UIImageView = UIImageView()
    fileprivate var releaseToRefreshImageView: UIImageView = UIImageView()
    fileprivate var refreshingImageView: UIImageView = UIImageView()
    fileprivate var refreshedImageView: UIImageView = UIImageView()
    /// 视图类型
    fileprivate var viewType: RefreshHeaderViewType = .default
    /// 上拉的百分比
    fileprivate var alphaPercent: CGFloat = 0
    
    // MARK: public property
    /// 刷新功能
    public var action: (() -> ()) = { }
    /// 是否自动改变透明度
    public var isAutoOpacity: Bool = true {
        didSet {
            isAutoOpacity ? setOpacity(0) : setOpacity(1)
        }
    }
    /// 是否自动加载(是不用松手也开始加载)
    public var isAutoRefresh: Bool = false
    /// 背景视图
    public var backgroundView: UIView? {
        didSet {
            if let view = backgroundView {
                self.addSubview(view)
                self.sendSubview(toBack: view)
            }
        }
    }
    /// 刷新视图状态
    var state = RefreshHeaderViewState.pulling {
        didSet {
            switch state {
            case .pulling:
                setPulling()
            case .releaseToRefresh:
                setReleaseToRefresh()
            case .refreshing:
                setRefreshing()
            case .refreshed:
                setRefreshed()
            }
        }
    }
    /// 可自定义正常状态时的视图
    public var normalView: UIView? {
        didSet{
            if let view = normalView {
                normalImageView.removeFromSuperview()
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义松手开始刷新时的视图
    public var releaseToRefreshView: UIView? {
        didSet{
            if let view = releaseToRefreshView {
                releaseToRefreshImageView.removeFromSuperview()
                view.isHidden = true
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义刷新时的视图
    public var refreshingView: UIView? {
        didSet{
            if let view = refreshingView {
                refreshingImageView.removeFromSuperview()
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义刷新完成的视图
    public var refreshedView: UIView? {
        didSet{
            if let view = refreshedView {
                refreshedImageView.removeFromSuperview()
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义下拉时的动画
    fileprivate var pullingAnimation: ((UIView, CGFloat) -> ())?
    /// 可自定义松手开始刷新时的动画
    fileprivate var releaseToRefreshAnimation: ((UIView) -> ())?
    /// 可自定义刷新时的动画
    fileprivate var refreshingAnimation: ((UIView) -> ())?
    
    // MARK: 完全自定义的上拉加载
    fileprivate var customNormalView: UIView?
    fileprivate var customReleaseToRefreshView: UIView?
    fileprivate var customRefreshingView: UIView?
    fileprivate var customRefreshedView: UIView?
    /// 自定义的加载视图代理
    public var delegate: CustomHeaderRefreshDelegate? {
        didSet {
            if delegate != nil && self.viewType == .custom {
                setCustomDisplay()
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public init(type: RefreshHeaderViewType, action: @escaping () -> ()) {
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: defaultHeaderHeight))
        self.action = action
        viewType = type
        
        setup()
    }
    
    public init(action: @escaping () -> ()) {
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: defaultHeaderHeight))
        self.action = action
        
        setup()
    }
    
    /// 初始化设置
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.frame = CGRect(x: 0, y: -self.frame.height, width: windowWidth, height: defaultHeaderHeight)
        
        switch viewType {
        case .default:
            setDefaultDisplay()
        case .imageAndText:
            setImageAndTextDisplay()
        case .image:
            setImageDisplay()
        case .text:
            setTextDisplay()
        case .custom:
            break
        }
    }
    
    /// 将要添加到父视图
    ///
    /// - Parameter newSuperview: 新的父视图
    override public func willMove(toSuperview newSuperview: UIView?) {
        if let superView = newSuperview as? UIScrollView {
            self.superScrollView = superView
            superView.addObserver(superView, forKeyPath: "contentOffset", options: .new, context: &headerTag)
        }
    }
    
    deinit {
        self.removeFromSuperview()
        removeObserver()
    }
    
    /// 移除观察者
    func removeObserver() {
        if let superView = self.superScrollView {
            superView.removeObserver(superView, forKeyPath: "contentOffset", context: &headerTag)
        }
    }
    
    /// 设置下拉时的动画
    ///
    /// - Parameter animation: 下拉动画
    public func setpullingAnimation(animation: @escaping (UIView, CGFloat) -> ()) {
        self.pullingAnimation = animation
    }
    
    /// 设置松开手时的动画
    ///
    /// - Parameter animation: 动画
    public func setReleaseToRefreshAnimation(animation: @escaping (UIView) -> ()) {
        self.releaseToRefreshAnimation = animation
    }
    
    /// 设置刷新时的动画
    ///
    /// - Parameter animation: 刷新时的动画
    public func setRefreshingAnimation(animation: @escaping (UIView) -> ()) {
        self.refreshingAnimation = animation
    }
}

// MARK: - 扩展刷新相关
extension RefreshHeaderView {
    /// 下拉刷新
    ///
    /// - Parameter y: 偏移距离
    func pullToRefresh(y: CGFloat) {
        if self.isFirst {
            self.isFirst = false
        } else if self.isSecond {
            self.isSecond = false
            self.initOffsetY = y
        }
        
        let height = defaultHeaderPullHeight
        let refreshOffsetY = self.initOffsetY - height
        
        if self.canBegin {
            self.alphaPercent = (self.initOffsetY - y) / defaultHeaderPullHeight
            if y < refreshOffsetY {
                if self.state != .releaseToRefresh {
                    self.state = .releaseToRefresh
                }
            } else if self.state == .pulling {
                setPulling()
                
                if !self.isAutoOpacity {
                    if y >= self.initOffsetY {
                        self.setOpacity(0)
                    } else {
                        self.setOpacity(1)
                    }
                }
            }
        }
    }
    
    /// 停止刷新
    public func stopRefresh() {
        self.canBegin = true
        self.superScrollView?.czx_footerView?.canBegin = true
        UIView.animate(withDuration: 0.5, animations: {
            self.state = .refreshed
        }) { (result) in
            if result {
                self.state = .pulling
            }
        }
    }
    
    /// 下拉状态时的设置
    private func setPulling() {
        if isAutoOpacity {
            self.setOpacity(self.alphaPercent)
        }
        if self.alphaPercent <= 0 && !self.isAutoOpacity {
            self.setOpacity(0)
        }
        if self.viewType == .custom {
            self.customNormalView?.isHidden = false
            self.customReleaseToRefreshView?.isHidden = true
            self.customRefreshingView?.isHidden = true
            self.customRefreshedView?.isHidden = true
            if let view = self.customNormalView {
                self.delegate?.setPullingAnimation(view: view, percent: self.alphaPercent)
            }
        } else {
            self.setDisplay(state: .pulling)
            if let animation = pullingAnimation {
                if let view = normalView {
                    animation(view, self.alphaPercent)
                } else {
                    animation(self.normalImageView, self.alphaPercent)
                }
            }
        }
    }
    
    /// 松手开始刷新状态时的设置
    private func setReleaseToRefresh() {
        if self.viewType == .custom {
            self.customNormalView?.isHidden = true
            self.customReleaseToRefreshView?.isHidden = false
            self.customRefreshingView?.isHidden = true
            self.customRefreshedView?.isHidden = true
            if let view = self.customReleaseToRefreshView {
                self.delegate?.setReleaseToRefreshAnimation(view: view)
            }
        } else {
            self.setDisplay(state: .releaseToRefresh)
        }
    }
    
    /// 刷新状态时的设置
    private func setRefreshing() {
        guard let superView = superScrollView else {
            return
        }
        
        if self.canBegin {
            if self.viewType == .custom {
                self.customNormalView?.isHidden = true
                self.customReleaseToRefreshView?.isHidden = true
                self.customRefreshingView?.isHidden = false
                self.customRefreshedView?.isHidden = true
                if let view = self.customRefreshingView {
                    self.delegate?.setRefreshingAnimation(view: view)
                }
            } else {
                self.setDisplay(state: .refreshing)
            }
            let height = defaultHeaderPullHeight
            superView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
            self.canBegin = false
            self.setOpacity(1.0)
            self.action()
        }
    }
    
    // 刷新完成状态时的设置
    private func setRefreshed() {
        guard let superView = superScrollView else {
            return
        }
        
        superView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        superView.czx_footerView?.state = .normal
        
        if self.viewType == .custom {
            self.customNormalView?.isHidden = true
            self.customReleaseToRefreshView?.isHidden = true
            self.customRefreshingView?.isHidden = true
            self.customRefreshedView?.isHidden = false
        } else {
            self.setDisplay(state: .refreshed)
        }
    }
}

// MARK: - 扩展布局相关
extension RefreshHeaderView {
    /// 设置默认样式的布局(有图片、提示文本和刷新时间)
    private func setDefaultDisplay() {
        let viewHeight = defaultFooterPullHeight - 20
        let width = windowWidth / 2
        var y: CGFloat = 0
        if defaultHeaderHeight > defaultHeaderPullHeight {
            y = defaultHeaderHeight - defaultHeaderPullHeight
        }
        let imageRect = CGRect(x: width-viewHeight-50, y: y + 10, width: viewHeight, height: viewHeight)
        self.addImage(rect: imageRect)
        
        let labelRect = CGRect(x: width-40, y: y + 0, width: width, height: viewHeight)
        self.addText(rect: labelRect)
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.timeString = formatter.string(from: now)
        self.timeLabel = UILabel(frame: CGRect(x: width-40, y: y + viewHeight, width: width, height: 20))
        self.timeLabel.textColor = UIColor.gray
        self.timeLabel.text = "上次刷新时间: " + self.timeString
        self.addSubview(timeLabel)
    }
    
    /// 设置有图片和提示文本的布局
    private func setImageAndTextDisplay() {
        let viewHeight = defaultFooterPullHeight - 20
        let width = windowWidth / 2
        var y: CGFloat = 0
        if defaultHeaderHeight > defaultHeaderPullHeight {
            y = defaultHeaderHeight - defaultHeaderPullHeight
        }
        let imageRect = CGRect(x: width-viewHeight-10, y: y + 10, width: viewHeight, height: viewHeight)
        self.addImage(rect: imageRect)
        
        let labelRect = CGRect(x: width, y: y, width: width, height: defaultFooterPullHeight)
        self.addText(rect: labelRect)
    }
    
    /// 设置只有图片的布局
    private func setImageDisplay() {
        let viewHeight = defaultFooterPullHeight - 20
        let x = (windowWidth - viewHeight) / 2
        var y: CGFloat = 0
        if defaultHeaderHeight > defaultHeaderPullHeight {
            y = defaultHeaderHeight - defaultHeaderPullHeight
        }
        let rect = CGRect(x: x, y: y + 10, width: viewHeight, height: viewHeight)
        self.addImage(rect: rect)
    }
    
    /// 设置只有文本的布局
    private func setTextDisplay() {
        var y: CGFloat = 0
        if defaultHeaderHeight > defaultHeaderPullHeight {
            y = defaultHeaderHeight - defaultHeaderPullHeight
        }
        let rect = CGRect(x: 0, y: y, width: windowWidth, height: defaultHeaderPullHeight)
        self.addText(rect: rect)
        textLabel.textAlignment = .center
    }
    
    /// 设置用户自定义布局
    private func setCustomDisplay() {
        self.customNormalView = delegate?.setNormalView()
        self.customReleaseToRefreshView = delegate?.setReleaseToRefreshView()
        self.customRefreshingView = delegate?.setRefreshingView()
        self.customRefreshedView = delegate?.setRefreshedView()
        
        if let view = self.customNormalView {
            self.addSubview(view)
        }
        if let view = self.customReleaseToRefreshView {
            view.isHidden = true
            self.addSubview(view)
        }
        if let view = self.customRefreshingView {
            view.isHidden = true
            self.addSubview(view)
        }
        if let view = self.customRefreshedView {
            view.isHidden = true
            self.addSubview(view)
        }
    }
    
    /// 根据位置和大小来添加文本
    ///
    /// - Parameter rect: 文本的位置和大小
    private func addText(rect: CGRect) {
        textLabel = UILabel(frame: rect)
        textLabel.textColor = UIColor.black
        textLabel.text = self.normalText
        self.addSubview(textLabel)
    }
    
    /// 根据位置和大小来添加图片视图
    ///
    /// - Parameter rect: 视图的位置和大小
    private func addImage(rect: CGRect) {
        let bundle = Bundle(for: type(of: self))
        
        hintView = UIView(frame: rect)
        hintView.clipsToBounds = true
        normalImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        normalImageView.contentMode = .scaleAspectFit
        normalImageView.image = UIImage(named: "CZXRefresh.bundle/arrow_1", in: bundle, compatibleWith: nil)
        hintView.addSubview(normalImageView)
        releaseToRefreshImageView = UIImageView(frame: normalImageView.frame)
        releaseToRefreshImageView.contentMode = .scaleAspectFit
        releaseToRefreshImageView.image = UIImage(named: "CZXRefresh.bundle/arrow_1", in: bundle, compatibleWith: nil)
        releaseToRefreshImageView.isHidden = true
        hintView.addSubview(releaseToRefreshImageView)
        refreshingImageView = UIImageView(frame: normalImageView.frame)
        refreshingImageView.contentMode = .scaleAspectFit
        refreshingImageView.image = UIImage(named: "CZXRefresh.bundle/refresh", in: bundle, compatibleWith: nil)
        refreshingImageView.isHidden = true
        hintView.addSubview(refreshingImageView)
        refreshedImageView = UIImageView(frame: normalImageView.frame)
        refreshedImageView.contentMode = .scaleAspectFit
        refreshedImageView.image = UIImage(named: "CZXRefresh.bundle/end", in: bundle, compatibleWith: nil)
        refreshedImageView.isHidden = true
        hintView.addSubview(refreshedImageView)
        self.addSubview(hintView)
    }
    
    /// 设置透明度
    ///
    /// - Parameter alpha: 透明度
    private func setOpacity(_ alpha: CGFloat) {
        self.alpha = alpha
    }
    
    /// 设置刷新视图的文本提示
    ///
    /// - Parameters:
    ///   - text: 提示的文本
    ///   - type: 刷新状态
    public func setText(text: String, type: RefreshHeaderViewState) {
        switch type {
        case .pulling:
            self.normalText = text
            self.textLabel.text = self.normalText
        case .releaseToRefresh:
            self.releaseToRefreshText = text
        case .refreshing:
            self.refreshingText = text
        case .refreshed:
            self.refreshedText = text
        }
    }
}

// MARK: - 扩展刷新时的布局
extension RefreshHeaderView {
    /// 根据状态设置相应的布局
    ///
    /// - Parameter state: 刷新视图的状态
    private func setDisplay(state: RefreshHeaderViewState) {
        switch viewType {
        case .default:
            setText(state: state)
            setHint(state: state)
        case .imageAndText:
            setText(state: state)
            setHint(state: state)
        case .image:
            setHint(state: state)
        case .text:
            setText(state: state)
        default:
            break
        }
    }
    
    /// 设置相应状态的文字
    ///
    /// - Parameter state: 当前的状态
    private func setText(state: RefreshHeaderViewState) {
        switch state {
        case .pulling:
            self.textLabel.text = self.normalText
        case .releaseToRefresh:
            self.textLabel.text = self.releaseToRefreshText
        case .refreshing:
            self.textLabel.text = self.refreshingText
        case .refreshed:
            self.textLabel.text = self.refreshedText
            if viewType == .default {
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                self.timeString = formatter.string(from: now)
                self.timeLabel.text = "上次刷新时间: " + self.timeString
            }
        }
    }
    
    /// 设置相应状态的提示视图
    ///
    /// - Parameter state: 设置相应状态
    private func setHint(state: RefreshHeaderViewState) {
        switch state {
        case .pulling:
            if normalView == nil {
                normalImageView.isHidden = false
            } else {
                normalView?.isHidden = false
            }
            if releaseToRefreshView == nil {
                releaseToRefreshImageView.isHidden = true
            } else {
                releaseToRefreshView?.isHidden = true
            }
            if refreshingView == nil {
                refreshingImageView.isHidden = true
            } else {
                refreshingView?.isHidden = true
            }
            if refreshedView == nil {
                refreshedImageView.isHidden = true
            } else {
                refreshedView?.isHidden = true
            }
        case .releaseToRefresh:
            if normalView == nil {
                normalImageView.isHidden = true
            } else {
                normalView?.isHidden = true
            }
            if releaseToRefreshView == nil {
                releaseToRefreshImageView.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    self?.releaseToRefreshImageView.transform = self!.releaseToRefreshImageView.transform.rotated(by: CGFloat.pi)
                })
            } else {
                releaseToRefreshView?.isHidden = false
                if let animation = self.releaseToRefreshAnimation, let view = self.releaseToRefreshView {
                    animation(view)
                }
            }
            if refreshingView == nil {
                refreshingImageView.isHidden = true
            } else {
                refreshingView?.isHidden = true
            }
            if refreshedView == nil {
                refreshedImageView.isHidden = true
            } else {
                refreshedView?.isHidden = true
            }
        case .refreshing:
            if normalView == nil {
                normalImageView.isHidden = true
            } else {
                normalView?.isHidden = true
            }
            if releaseToRefreshView == nil {
                releaseToRefreshImageView.isHidden = true
            } else {
                releaseToRefreshView?.isHidden = true
            }
            if refreshingView == nil {
                refreshingImageView.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat], animations: {
                    [weak self] in
                    self?.refreshingImageView.transform = self!.refreshingImageView.transform.rotated(by: CGFloat.pi)
                }, completion: nil)
            } else {
                refreshingView?.isHidden = false
                if let animation = self.refreshingAnimation, let view = self.refreshingView {
                    animation(view)
                }
            }
            if refreshedView == nil {
                refreshedImageView.isHidden = true
            } else {
                refreshedView?.isHidden = true
            }
        case .refreshed:
            if normalView == nil {
                normalImageView.isHidden = true
            } else {
                normalView?.isHidden = true
            }
            if releaseToRefreshView == nil {
                releaseToRefreshImageView.isHidden = true
            } else {
                releaseToRefreshView?.isHidden = true
            }
            if refreshingView == nil {
                refreshingImageView.isHidden = true
            } else {
                refreshingView?.isHidden = true
            }
            if refreshedView == nil {
                refreshedImageView.isHidden = false
                self.releaseToRefreshImageView.transform = self.releaseToRefreshImageView.transform.rotated(by: CGFloat.pi)
            } else {
                refreshedView?.isHidden = false
            }
        }
    }
}
