//
//  RefreshFooterView.swift
//  CZXRefresh
//
//  Created by 陈主昕 on 2018/1/27.
//  Copyright © 2018年 average. All rights reserved.
//

import UIKit

public final class RefreshFooterView: UIView {

    // MARK: private property
    /// 父滚动视图
    fileprivate var superScrollView: UIScrollView?
    /// 视图类型
    fileprivate var viewType: RefreshFooterViewType = .default
    /// 文本提示
    fileprivate var textLabel: UILabel = UILabel()
    fileprivate var normalText: String = "上拉加载"
    fileprivate var refreshingText: String = "正在加载..."
    fileprivate var endText: String = "所有数据已经加载完成"
    /// 动态提示
    fileprivate var hintView: UIView = UIView()
    fileprivate var staticImageView: UIImageView = UIImageView()
    fileprivate var dynamicImageView: UIImageView = UIImageView()
    fileprivate var endImageView: UIImageView = UIImageView()
    /// 上拉的百分比
    fileprivate var alphaPercent: CGFloat = 0
    
    // MARK: public property
    /// 能否加载
    var canBegin = true
    /// 加载功能
    public var action: (() -> ()) = { }
    /// 是否自动改变透明度
    public var isAutoOpacity: Bool = true
    /// 背景视图
    public var backgroundView: UIView? {
        didSet {
            if let view = backgroundView {
                self.addSubview(view)
                self.sendSubview(toBack: view)
            }
        }
    }
    /// 是否自动加载(是否不停留在视图底部并可以点击加载)
    public var isAutoRefresh: Bool = true {
        didSet {
            if isAutoRefresh {
                self.setOpacity(0)
                self.normalText = "上拉加载"
            } else {
                self.setOpacity(1)
                self.normalText = "点击或上拉加载"
            }
        }
    }
    /// 加载视图状态
    var state = RefreshFooterViewState.normal  {
        didSet {
            switch state {
            case .normal:
                setNormal()
            case .refreshing:
                setRefreshing()
            case .endRefresh:
                setEndRefresh()
            }
        }
    }
    /// 可自定义正常状态时的视图
    public var staticView: UIView? {
        didSet{
            if let view = staticView {
                staticImageView.removeFromSuperview()
                view.isHidden = false
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义加载状态时的视图
    public var dynamicView: UIView? {
        didSet{
            if let view = dynamicView {
                dynamicImageView.removeFromSuperview()
                view.isHidden = true
                self.hintView.addSubview(view)
            }
        }
    }
    /// 可自定义加载状态时的动画
    fileprivate var dynamicAnimation: ((UIView) -> ())?
    /// 可自定义上拉状态时的动画
    fileprivate var pullingAnimation: ((UIView, CGFloat) -> ())?
    /// 可自定义加载完成时的动画
    public var endView: UIView? {
        didSet{
            if let view = endView {
                endImageView.removeFromSuperview()
                self.hintView.addSubview(view)
            }
        }
    }
    
    // MARK: 完全自定义的上拉加载
    fileprivate var normalView: UIView?
    fileprivate var refreshingView: UIView?
    fileprivate var endRefreshView: UIView?
    /// 自定义的加载视图代理
    public var delegate: CustomFooterRefreshDelegate? {
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
    
    public init(type: RefreshFooterViewType, action: @escaping () -> ()) {
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: defaultFooterHeight))
        self.action = action
        viewType = type
        
        setup()
    }
    
    public init(action: @escaping () -> ()) {
        super.init(frame: CGRect(x: 0, y: 0, width: windowWidth, height: defaultFooterHeight))
        self.action = action
        
        setup()
    }
    
    /// 初始设置
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
        
        switch viewType {
        case .default:
            setDefaultDisplay()
        case .text:
            setTextDisplay()
        case .image:
            setImageDisplay()
        case .custom:
            break
        }
    }
    
    /// 点击手势
    ///
    /// - Parameter gesture: 点击手势
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        self.state = .refreshing
    }
    
    /// 将要添加到父视图
    ///
    /// - Parameter newSuperview: 新的父视图
    override public func willMove(toSuperview newSuperview: UIView?) {
        if let superView = newSuperview as? UIScrollView {
            self.superScrollView = superView
            superView.addObserver(superView, forKeyPath: "contentSize", options: .new, context: nil)
            superView.addObserver(superView, forKeyPath: "contentOffset", options: .new, context: &footerTag)
            setNormal()
        }
    }
    
    deinit {
        self.removeFromSuperview()
        removeObserver()
    }
    
    /// 移除观察者
    func removeObserver() {
        if let superView = self.superScrollView {
            superView.removeObserver(superView, forKeyPath: "contentSize", context: nil)
            superView.removeObserver(superView, forKeyPath: "contentOffset", context: &footerTag)
        }
    }
    
    /// 设置刷新时的动画
    ///
    /// - Parameter animation: 动画
    public func setDynamicAnimation(_ animation: @escaping (UIView) -> () ) {
        self.dynamicAnimation = animation
    }
    
    /// 设置上拉时的动画
    ///
    /// - Parameter animation: 动画
    public func setPullingAnimation(_ animation: @escaping (UIView, CGFloat) -> ()) {
        self.pullingAnimation = animation
    }

    // MARK: - 扩展刷新相关
    /// 上拉加载
    ///
    /// - Parameter y: 偏移距离
    func pullToRefresh(y: CGFloat) {
        guard let superView = superScrollView else {
            return
        }
        
        let height = defaultFooterPullHeight
        let contentHeight = superView.contentSize.height
        var adjustBottom = superView.contentInset.bottom
        if #available(iOS 11.0, *) {
            adjustBottom = superView.adjustedContentInset.bottom
        }
        let frameHeight = superView.frame.height
        let refreshOffsetY = contentHeight + adjustBottom - frameHeight + height
        if self.canBegin {
            self.alphaPercent = (y - refreshOffsetY + height) / defaultFooterPullHeight
            if y > refreshOffsetY {
                self.state = .refreshing
            } else if self.state == .normal {
                pulling()
            }
        }
    }
    
    /// 停止刷新
    public func stopRefresh() {
        self.state = .normal
        self.canBegin = true
    }
    
    /// 完成所有刷新
    public func endRefresh() {
        guard let superView = superScrollView else {
            return
        }
        
        let height = defaultFooterPullHeight
        superView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        self.canBegin = false
        self.state = .endRefresh
    }
    
    /// 上拉状态时的设置
    private func pulling() {
        if isAutoOpacity && isAutoRefresh {
            self.setOpacity(self.alphaPercent)
        }
        if !self.isAutoOpacity {
            if self.alphaPercent <= 0 {
                self.setOpacity(0)
            } else {
                self.setOpacity(1)
            }
        }
        
        if self.viewType == .custom {
            if let view = self.normalView {
                delegate?.setPullingAnimation(view: view, percent: self.alphaPercent)
            }
        } else {
            self.pullingDisplay()
        }
    }
    
    /// 正常状态时的设置
    private func setNormal() {
        guard let superView = superScrollView else {
            return
        }
        var height: CGFloat = 0
        if !isAutoRefresh {
            height = defaultFooterPullHeight
        }
        superView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        
        if self.viewType == .custom {
            self.normalView?.isHidden = false
            self.refreshingView?.isHidden = true
            self.endRefreshView?.isHidden = true
        } else {
            self.setDisplay(state: .normal)
        }
    }
    
    /// 刷新状态时的设置
    private func setRefreshing() {
        guard let superView = superScrollView else {
            return
        }
        
        if self.canBegin {
            if self.viewType == .custom {
                self.normalView?.isHidden = true
                self.refreshingView?.isHidden = false
                self.endRefreshView?.isHidden = true
                if let view = self.refreshingView {
                    delegate?.setRefreshingAnimation(view: view)
                }
            } else {
                self.setDisplay(state: .refreshing)
            }
            let height = defaultFooterPullHeight
            superView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            self.canBegin = false
            self.setOpacity(1.0)
            self.action()
        }
    }
    
    /// 结束刷新状态时的设置
    private func setEndRefresh() {
        if self.viewType == .custom {
            self.normalView?.isHidden = true
            self.refreshingView?.isHidden = true
            self.endRefreshView?.isHidden = false
        } else {
            self.setDisplay(state: .endRefresh)
        }
    }

    // MARK: - 扩展布局相关
    /// 设置自定义样式的布局
    private func setCustomDisplay() {
        self.normalView = delegate?.setNormalView()
        self.refreshingView = delegate?.setRefreshingView()
        self.endRefreshView = delegate?.setEndRefreshView()
        
        if let view = self.normalView {
            self.addSubview(view)
        }
        if let view = self.refreshingView {
            view.isHidden = true
            self.addSubview(view)
        }
        if let view = self.endRefreshView {
            view.isHidden = true
            self.addSubview(view)
        }
    }
    
    /// 设置默认样式的布局
    private func setDefaultDisplay() {
        let viewHeight = defaultFooterPullHeight - 20
        let width = windowWidth / 2
        let imageRect = CGRect(x: width-viewHeight-10, y: 10, width: viewHeight, height: viewHeight)
        self.addImageView(rect: imageRect)
        
        let labelRect = CGRect(x: width, y: 0, width: width, height: defaultFooterPullHeight)
        self.addLabel(rect: labelRect)
    }
    
    /// 设置只有文本时的布局
    private func setTextDisplay() {
        let rect = CGRect(x: 0, y: 0, width: windowWidth, height: defaultFooterPullHeight)
        self.addLabel(rect: rect)
        self.textLabel.textAlignment = .center
    }
    
    /// 设置只有图片时的布局
    private func setImageDisplay() {
        let viewHeight = defaultFooterPullHeight - 20
        let x = (windowWidth - viewHeight) / 2
        let rect = CGRect(x: x, y: 10, width: viewHeight, height: viewHeight)
        self.addImageView(rect: rect)
    }
    
    /// 添加默认的文本视图
    ///
    /// - Parameter rect: 文本视图的位置和大小
    private func addLabel(rect: CGRect) {
        textLabel = UILabel(frame: rect)
        textLabel.textColor = UIColor.black
        textLabel.text = self.normalText
        self.addSubview(textLabel)
    }
    
    /// 添加默认的图片视图
    ///
    /// - Parameter rect: 图片视图的位置和大小
    private func addImageView(rect: CGRect) {
        let bundle = Bundle(for: type(of: self))
        
        hintView = UIView(frame: rect)
        hintView.clipsToBounds = true
        staticImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        staticImageView.contentMode = .scaleAspectFit
        staticImageView.image = UIImage(named: "CZXRefresh.bundle/arrow", in: bundle, compatibleWith: nil)
        hintView.addSubview(staticImageView)
        dynamicImageView = UIImageView(frame: staticImageView.frame)
        dynamicImageView.contentMode = .scaleAspectFit
        dynamicImageView.image = UIImage(named: "CZXRefresh.bundle/refresh", in: bundle, compatibleWith: nil)
        dynamicImageView.isHidden = true
        hintView.addSubview(dynamicImageView)
        endImageView = UIImageView(frame: staticImageView.frame)
        endImageView.contentMode = .scaleAspectFit
        endImageView.image = UIImage(named: "CZXRefresh.bundle/end", in: bundle, compatibleWith: nil)
        endImageView.isHidden = true
        hintView.addSubview(endImageView)
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
    public func setText(text: String, type: RefreshFooterViewState) {
        switch type {
        case .normal:
            self.normalText = text
            self.textLabel.text = self.normalText
        case .refreshing:
            self.refreshingText = text
        case .endRefresh:
            self.endText = text
        }
    }

    // MARK: - 扩展加载时的布局
    /// 根据状态设置相应的布局
    ///
    /// - Parameter state: 加载视图的状态
    private func setDisplay(state: RefreshFooterViewState) {
        switch self.viewType {
        case .default:
            self.setText(state: state)
            self.setHint(state: state)
        case .text:
            self.setText(state: state)
        case.image:
            self.setHint(state: state)
        case .custom:
            break
        }
    }
    
    /// 设置上拉时的布局
    private func pullingDisplay() {
        if let animation = pullingAnimation {
            if let view = staticView {
                animation(view, self.alphaPercent)
            } else {
                animation(self.staticImageView, self.alphaPercent)
            }
        }
        self.staticView?.isHidden = false
    }
    
    /// 设置相应状态的文字
    ///
    /// - Parameter state: 当前的状态
    private func setText(state: RefreshFooterViewState) {
        switch state {
        case .normal:
            self.textLabel.text = self.normalText
        case .refreshing:
            self.textLabel.text = self.refreshingText
        case .endRefresh:
            self.textLabel.text = self.endText
        }
    }
    
    /// 设置相应状态的提示视图
    ///
    /// - Parameter state: 当前的状态
    private func setHint(state: RefreshFooterViewState) {
        switch state {
        case .normal:
            if dynamicView == nil {
                dynamicImageView.isHidden = true
            } else {
                dynamicView?.isHidden = true
            }
            if staticView == nil {
                staticImageView.isHidden = false
            } else {
                staticView?.isHidden = false
            }
            if endView == nil {
                endImageView.isHidden = true
            } else {
                endView?.isHidden = true
            }
        case .refreshing:
            if dynamicView == nil {
                dynamicImageView.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0, options: [.repeat], animations: {
                    [weak self] in
                    self?.dynamicImageView.transform = self!.dynamicImageView.transform.rotated(by: CGFloat.pi)
                    }, completion: nil)
            } else {
                dynamicView?.isHidden = false
                if let animation = dynamicAnimation, let view = dynamicView {
                    animation(view)
                }
            }
            if staticView == nil {
                staticImageView.isHidden = true
            } else {
                staticView?.isHidden = true
            }
            if endView == nil {
                endImageView.isHidden = true
            } else {
                endView?.isHidden = true
            }
        case .endRefresh:
            if dynamicView == nil {
                dynamicImageView.isHidden = true
            } else {
                dynamicView?.isHidden = true
            }
            if staticView == nil {
                staticImageView.isHidden = true
            } else {
                staticView?.isHidden = true
            }
            if endView == nil {
                endImageView.isHidden = false
            } else {
                endView?.isHidden = false
            }
        }
    }
}
