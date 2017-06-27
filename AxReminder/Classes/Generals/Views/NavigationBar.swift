//
//  NavigationBar.swift
//  AxReminder
//
//  Created by devedbox on 2017/6/26.
//  Copyright © 2017年 devedbox. All rights reserved.
//

import UIKit

private let DefaultTitleFontSize: CGFloat = 36.0
private let DefaultTitleUnselectedFontSize: CGFloat = 16.0
private let DefaultNavigationItemFontSize: CGFloat = 14.0

private class _NavigationItemButton: UIButton { /* Custom view hooks. */ }

private class _NavigationItemView: UIView {
    var title: String? {
        didSet {
            _button.setTitle(title, for: .normal)
        }
    }
    var image: UIImage? {
        didSet {
            _button.setImage(image, for: .normal)
        }
    }
    
    
    // Button item.
    lazy var _button: _NavigationItemButton = { () -> _NavigationItemButton in
        let button = _NavigationItemButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: DefaultNavigationItemFontSize)
        // button.tintColor =
        return button
    }()
    
    // Initialzier:
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _initializer()
    }
    
    private func _initializer() {
        backgroundColor = .clear
        // Set up button.
        _setupButton()
    }
    
    // Private:
    private func _setupButton() {
        addSubview(_button)
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: _button, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: _button, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(==6)-[_button]-(==6)-|", options: [], metrics: nil, views: ["_button":_button]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[_button]-(>=0)-|", options: [], metrics: nil, views: ["_button":_button]))
    }
}

public class NavigationItem: NSObject {
    // MARK: - Properties.
    public var image: UIImage? {
        return _view.image
    }
    
    public var title: String? {
        return _view.title
    }
    
    public var target: Any? {
        return _view._button.allTargets.first
    }
    
    public var selector: Selector? {
        guard let _selector = _view._button.actions(forTarget: target, forControlEvent: .touchUpInside)?.first else {
            return nil
        }
        return Selector(_selector)
    }
    
    fileprivate var _view: _NavigationItemView = _NavigationItemView()
    
    public init(image: UIImage? = nil, target: Any?, selector: Selector) {
        super.init()
        _view.image = image
        _view._button.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    public init(title: String? = nil, target: Any?, selector: Selector) {
        super.init()
        _view.title = title
        _view._button.addTarget(target, action: selector, for: .touchUpInside)
    }
}

public class NavigationTitleItem: NSObject {
    
    public var selected: Bool {
        didSet {
            if selected {
                self._button.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: DefaultTitleFontSize)
                self._button.tintColor = UIColor(hex: "4A4A4A")
                self._button.setTitleColor(UIColor(hex: "4A4A4A"), for: .normal)
            } else {
                self._button.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: DefaultTitleUnselectedFontSize)
                self._button.tintColor = UIColor(hex: "CCCCCC")
                self._button.setTitleColor(UIColor(hex: "CCCCCC"), for: .normal)
            }
        }
    }
    
    fileprivate lazy var _button: UIButton = { () -> UIButton in
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: DefaultTitleFontSize)
        button.tintColor = UIColor(hex: "4A4A4A")
        button.setTitleColor(UIColor(hex: "4A4A4A"), for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    public init(title: String) {
        selected = false
        super.init()
        _button.setTitle(title, for: .normal)
    }
}

// UINavigationBar
public class NavigationBar: UIView, UIBarPositioning {
    // MARK: - Public Properties.
    // MARK: - Private Properties.
    private lazy var _scrollViewContainerView: UIView = { () -> UIView in
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private lazy var _contentScrollView: UIScrollView = { () -> UIScrollView in
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()
    private lazy var _navigationItemView: UIView = { () -> UIView in
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    
    fileprivate var _navigationItems: [NavigationItem] = []
    fileprivate var _navigationTitleItems: [NavigationTitleItem] = []
    
    fileprivate var _selectedTitleItemIndex: Int = 0
    
    private weak var _leadingConstraintOflastItemView: NSLayoutConstraint?
    private weak var _trailingConstraintOflastTitleItemLabel: NSLayoutConstraint?
    
    // MARK: - `NSCoding` supporting.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _initializer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _initializer()
    }
    
    // Initializer:
    private func _initializer() {
        // Set up container views:
        _setupContainerViews()
        // Set up title label.
        // _setupTitleLabel()
        
        _setupContentScrollView()
    }
    
    // MARK: - Private.
    private func _setupContainerViews() {
        addSubview(_scrollViewContainerView)
        addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: _scrollViewContainerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_scrollViewContainerView]|", options: [], metrics: nil, views: ["_scrollViewContainerView":_scrollViewContainerView]))
        
        addSubview(_navigationItemView)
        // _navigationItemView.setContentHuggingPriority(.required, for: .horizontal)
        addConstraint(NSLayoutConstraint(item: _scrollViewContainerView, attribute: .trailing, relatedBy: .equal, toItem: _navigationItemView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: _navigationItemView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_navigationItemView]|", options: [], metrics: nil, views: ["_navigationItemView":_navigationItemView]))
    }
    
    private func _setupContentScrollView() {
        _scrollViewContainerView.addSubview(_contentScrollView)
        _scrollViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_contentScrollView]|", options: [], metrics: nil, views: ["_contentScrollView":_contentScrollView]))
        _scrollViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_contentScrollView]|", options: [], metrics: nil, views: ["_contentScrollView":_contentScrollView]))
        _scrollViewContainerView.addConstraint(NSLayoutConstraint(item: _scrollViewContainerView, attribute: .height, relatedBy: .equal, toItem: _contentScrollView, attribute: .height, multiplier: 1.0, constant: 0.0))
        _scrollViewContainerView.addConstraint(NSLayoutConstraint(item: _scrollViewContainerView, attribute: .width, relatedBy: .equal, toItem: _contentScrollView, attribute: .width, multiplier: 1.0, constant: 0.0))
    }
    
    fileprivate func _addNavigationItemView(_ item: NavigationItem) {
        let _itemView = item._view
        _itemView.translatesAutoresizingMaskIntoConstraints = false
        // _itemView.setContentHuggingPriority(.required, for: .horizontal)
        _navigationItemView.addSubview(_itemView)
        // Height and with:
        _itemView.addConstraint(NSLayoutConstraint(item: _itemView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0))
        _itemView.addConstraint(NSLayoutConstraint(item: _itemView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
        // Base line:
        addConstraint(NSLayoutConstraint(item: _itemView._button, attribute: _navigationTitleItems.last != nil ? .lastBaseline : .centerY, relatedBy: .equal, toItem: _navigationTitleItems.last?._button ?? _navigationItemView, attribute: _navigationTitleItems.last != nil ? .lastBaseline : .centerY, multiplier: 1.0, constant: 0.0))
        // Horizontal:
        _navigationItemView.addConstraint(NSLayoutConstraint(item: _itemView, attribute: .trailing, relatedBy: .equal, toItem: _navigationItems.last?._view ?? _navigationItemView, attribute: _navigationItems.last?._view != nil ? .leading : .trailing, multiplier: 1.0, constant: _navigationItems.count>0 ? 0.0 : -8))
        if let _leading = _leadingConstraintOflastItemView {
            _navigationItemView.removeConstraint(_leading)
        }
        
        let _leading = NSLayoutConstraint(item: _navigationItemView, attribute: .leading, relatedBy: .equal, toItem: _itemView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        _navigationItemView.addConstraint(_leading)
        _leadingConstraintOflastItemView = _leading
    }
    
    fileprivate func _addNavigationTitleItemLabel(_ item: NavigationTitleItem) {
        let _itemLabel = item._button
        _itemLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _contentScrollView.addSubview(_itemLabel)
        
        _contentScrollView.addConstraint(NSLayoutConstraint(item: _itemLabel, attribute: .leading, relatedBy: .equal, toItem: _navigationTitleItems.last?._button ?? _contentScrollView, attribute: _navigationTitleItems.last?._button != nil ? .trailing : .leading, multiplier: 1.0, constant:15))
        if let _lastItemLabel = _navigationTitleItems.last?._button {
            _contentScrollView.addConstraint(NSLayoutConstraint(item: _lastItemLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: _itemLabel, attribute: .lastBaseline, multiplier: 1.0, constant: 0.0))
        } else {
            _contentScrollView.addConstraint(NSLayoutConstraint(item: _contentScrollView, attribute: .centerY, relatedBy: .equal, toItem: _itemLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        }
        
        if let _trailing = _trailingConstraintOflastTitleItemLabel {
            _contentScrollView.removeConstraint(_trailing)
        }
        let _trailing = NSLayoutConstraint(item: _contentScrollView, attribute: .trailing, relatedBy: .equal, toItem: _itemLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        _contentScrollView.addConstraint(_trailing)
        _trailingConstraintOflastTitleItemLabel = _trailing
    }
}

extension NavigationBar {
    // MARK: - Public.
    public var selectedTitleItem: NavigationTitleItem { return _navigationTitleItems[_selectedTitleItemIndex] }
    
    public var navigationItems: [NavigationItem] {
        set(items) {
            for item in items {
                addNavigationItem(item)
            }
        }
        
        get { return _navigationItems }
    }
    
    public var navigationTitleItems: [NavigationTitleItem] {
        set(items) {
            for item in items {
                addNavigationTitleItem(item)
            }
        }
        
        get { return _navigationTitleItems }
    }
    
    public func addNavigationItem(_ item: NavigationItem) {
        _addNavigationItemView(item)
        
        _navigationItems.append(item)
    }
    
    public func addNavigationTitleItem(_ item: NavigationTitleItem) {
        _addNavigationTitleItemLabel(item)
        
        _navigationTitleItems.append(item)
    }
    // MARK: - Selected title.
    public func setSelectedTitle(at index: Int, animated: Bool) {
        assert(index < _navigationTitleItems.endIndex, "Index of title item is out of bounds.")
        _selectedTitleItemIndex = index
        
        for (idx, item) in _navigationTitleItems.enumerated() {
            if idx == index {
                item.selected = true
            } else {
                item.selected = false
            }
        }
    }
}

// MARK: - Conforming `NSCoding`.
extension NavigationBar {
    public override func encode(with aCoder: NSCoder) {
        
    }
}
// MARK: - Conforming `UIBarPositioning`.
extension NavigationBar {
    public var barPosition: UIBarPosition { return .top }
}
