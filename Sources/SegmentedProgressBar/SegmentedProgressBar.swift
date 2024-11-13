//
//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Sun on 2024/11/13.
//

import UIKit

/// 分段进度条
public class SegmentedProgressBar: UIView {
    
    /// 分段点
    public struct Dot: Hashable {
        
        /// 分段点表示的值
        public var value: CGFloat // [0...1]
        
        /// 分段点宽度比例
        ///
        /// 例如: 第一个点的间距是其它点间距的一半 [--•----•----•----], 可以分配为 [0.5, 1, 1, 1]
        /// 默认: 1.0
        public var widthProportion: CGFloat
        /// 分段点展示的文本
        public var label: NSAttributedString?
        
        /// Initializer
        public init(value: CGFloat, widthProportion: CGFloat = 1.0, label: NSAttributedString?) {
            self.value = value
            self.widthProportion = widthProportion
            self.label = label
        }
    }
    
    // 所有的分割点
    private let dots: [Dot]
    // 缓存点的索引和 dot.center.x
    private var indexToDotCenterX: [Int: CGFloat] = [:]
    // 最大轨道
    private let maxTrackBar = UIView()
    // 分割点视图
    private var dotViews: [UIView] = []
    // 分割点展示文本
    private var labels: [UILabel] = []
    // 进度轨道
    private let trackBar = UIView()
    // 进度指示器
    private let indicator = UIView()
    
    /// 最大轨道颜色
    public var maxTrackBarColor: UIColor = .systemGray6 {
        didSet {
            maxTrackBar.backgroundColor = maxTrackBarColor
        }
    }
    
    /// 进度轨道颜色
    public var trackBarColor: UIColor = .systemRed {
        didSet {
            trackBar.backgroundColor = trackBarColor
        }
    }
    
    /// 进度指示器颜色
    public var indicatorColor: UIColor = .white {
        didSet {
            indicator.backgroundColor = indicatorColor
        }
    }
    
    /// 进度指示器边框颜色
    public var indicatorBorderColor: UIColor = .systemOrange {
        didSet {
            indicator.layer.borderColor = indicatorBorderColor.cgColor
        }
    }
    
    /// 分割点颜色
    public var dotColor: UIColor = .systemGray4 {
        didSet {
            updateProgress()
        }
    }
    
    /// 进度超过的分割点的颜色
    public var dotProgressExceedsColor: UIColor = .systemOrange {
        didSet {
            updateProgress()
        }
    }
    
    /// 最大轨道高度
    public var maxTrackBarHeight: CGFloat = 16 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 进度轨道高度
    public var trackBarHeight: CGFloat = 8 {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// 分割点尺寸
    public var dotSize: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 分割点文本距离最大轨道的间距
    public var labelToMaxTrackBarSpacing: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 最大轨道水平间距
    public var maxTrackBarHorizontalPadding: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 进度指示器尺寸
    public var indicatorSize: CGFloat = 12 {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// 进度指示器边框宽度
    public var indicatorBorderWidth: CGFloat = 3 {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// 是否隐藏进度指示器
    public var isHiddenIndicator: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 当 0 进度时是否隐藏进度指示器
    public var isHiddenIndicatorWhenZeroProgress: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 当进度超过分割点时是否隐藏被超过的分割点
    public var isHiddenDotWhenProgressExceeds: Bool = false {
        didSet {
            updateProgress()
        }
    }
    
    /// 最小进度阈值
    ///
    /// 当颗粒度很细, 当前进度很小但又不是 0 时, 进度条可能几乎不可见
    /// 为此属性设置一个合理的值, 可以在实际进度低于此属性的值时以此值而不是实际进度值进行展示
    public var minimumProgressThreshold: CGFloat? {
        didSet {
            updateProgress()
        }
    }
    
    /// 当前进度
    public var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }
    
    private var clampedTrackBarHeight: CGFloat {
        trackBarHeight > maxTrackBarHeight ? maxTrackBarHeight : trackBarHeight
    }
    
    private var clampedIndicatorSize: CGFloat {
        indicatorSize > trackBarHeight ? indicatorSize : trackBarHeight
    }
    
    /// Initializer
    public init(frame: CGRect = .zero, dots: [Dot]) {
        self.dots = dots
        super.init(frame: frame)
        
        setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let trackBarPadding = maxTrackBarHorizontalPadding
        maxTrackBar.frame = CGRect(
            x: bounds.minX + trackBarPadding,
            y: bounds.minY,
            width: bounds.width - trackBarPadding * 2,
            height: maxTrackBarHeight
        )
        
        guard !dots.isEmpty, dots.count == dotViews.count else { return }
        
        let trackBarBottom = maxTrackBar.frame.maxY
        let labelSpacing = labelToMaxTrackBarSpacing
        
        let dotSize = dotSize
        let dotPadding = (maxTrackBarHeight - dotSize) / 2
        let availableWidth = maxTrackBar.bounds.width - dotPadding * 2
        guard availableWidth > 0 else {
            return
        }
        
        let indexToCenterX = calculateDotIndexToCenterX(availableWidth)
        self.indexToDotCenterX = indexToCenterX
        
        var previousDotX: CGFloat = maxTrackBar.bounds.minX + dotPadding
        for (index, dot) in dotViews.enumerated() {
            let dotCenterX: CGFloat = indexToCenterX[index] ?? 0
            let porposedX = previousDotX + dotCenterX - (index == 0 ? dotSize : 0)
            let clampedX = min(
                max(porposedX, maxTrackBar.bounds.minX + dotPadding),
                dotPadding + availableWidth - dotSize
            )
            dot.frame = CGRect(
                x: clampedX,
                y: maxTrackBar.bounds.midY - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            previousDotX = clampedX
            let labelSize = labels[index].bounds.size
            labels[index].center = CGPoint(
                x: dot.center.x + trackBarPadding,
                y: trackBarBottom + labelSize.height / 2 + labelSpacing
            )
        }
        
        updateCornerRadius()
    }
    
    private func setup() {
        maxTrackBar.backgroundColor = maxTrackBarColor
        addSubview(maxTrackBar)
        
        trackBar.backgroundColor = trackBarColor
        maxTrackBar.addSubview(trackBar)
        
        indicator.backgroundColor = indicatorColor
        indicator.layer.borderColor = indicatorBorderColor.cgColor
        maxTrackBar.addSubview(indicator)
        
        let dotCornerRadius = dotSize / 2
        let dotColor = dotColor
        for step in dots {
            let dot = UIView()
            dot.backgroundColor = dotColor
            dot.layer.cornerRadius = dotCornerRadius
            maxTrackBar.addSubview(dot)
            dotViews.append(dot)
            
            let label = UILabel()
            label.attributedText = step.label
            label.textAlignment = .center
            addSubview(label)
            label.sizeToFit()
            labels.append(label)
        }
        
        updateCornerRadius()
    }
    
    private func calculateDotIndexToCenterX(_ availableWidth: CGFloat) -> [Int: CGFloat] {
        guard !dots.isEmpty else {
            return [:]
        }
        guard dots.count > 1 else {
            return [0: availableWidth / 2]
        }
        var proportionSum: CGFloat = 0
        var conspicuousProportions: [Int: CGFloat] = [:]
        var ordinaryIndices: [Int] = []
        for (index, step) in dots.enumerated() {
            proportionSum += step.widthProportion
            if abs(step.widthProportion - 1) > .ulpOfOne {
                conspicuousProportions[index] = step.widthProportion
            } else {
                ordinaryIndices.append(index)
            }
        }
        guard proportionSum > 0 else {
            return [:]
        }
        let stepSpacingEvenly: CGFloat = availableWidth / proportionSum
        var stepWidths: [Int: CGFloat] = [:]
        var conspicuousTotalWidth: CGFloat = 0
        for (index, proportion) in conspicuousProportions {
            stepWidths[index] = stepSpacingEvenly * proportion
            conspicuousTotalWidth += stepSpacingEvenly * proportion
        }
        guard !ordinaryIndices.isEmpty else {
            return stepWidths
        }
        for index in ordinaryIndices {
            stepWidths[index] = stepSpacingEvenly
        }
        return stepWidths
    }
    
    private func updateCornerRadius() {
        maxTrackBar.layer.cornerRadius = maxTrackBarHeight / 2
        trackBar.layer.cornerCurve = .continuous
        
        indicator.layer.cornerRadius = clampedIndicatorSize / 2
        indicator.layer.cornerCurve = .continuous
        indicator.layer.borderWidth = indicatorBorderWidth
        
        let dotCornerRadius = dotSize / 2
        for dot in dotViews {
            dot.layer.cornerRadius = dotCornerRadius
        }
        updateProgress()
    }
    
    private func updateProgress() {
        let clampedProgress: CGFloat = {
            if let threshold = minimumProgressThreshold, progress > 0, threshold > 0 {
                return min(max(progress, threshold), 1)
            }
            return min(max(progress, 0), 1)
        }()
        if isHiddenIndicatorWhenZeroProgress, clampedProgress <= .ulpOfOne {
            indicator.isHidden = true
            trackBar.isHidden = true
            return
        }
        indicator.isHidden = isHiddenIndicator
        trackBar.isHidden = false
        
        let clampedIndicatorSize = self.clampedIndicatorSize
        let indicatorPadding = (maxTrackBarHeight - clampedIndicatorSize) / 2
        let availableWidth = maxTrackBar.bounds.width - indicatorPadding * 2
        guard availableWidth > 0 else {
            return
        }
        var needHiddenDotIndices: [Int] = []
        var indicatorOffsetX: CGFloat = maxTrackBar.bounds.minX + indicatorPadding
        var lastPassedValue: CGFloat = 0
        for (index, step) in dots.enumerated() {
            let dotCenterX: CGFloat = self.indexToDotCenterX[index] ?? 0
            if index == 0 {
                indicatorOffsetX -= clampedIndicatorSize / 2
            }
            if clampedProgress >= step.value {
                indicatorOffsetX += dotCenterX
                lastPassedValue = step.value
                needHiddenDotIndices.append(index)
            } else {
                let inStepProgress = (clampedProgress - lastPassedValue) / (step.value - lastPassedValue)
                indicatorOffsetX += dotCenterX * inStepProgress
                break
            }
        }
        let clampedIndicatorX = min(
            max(indicatorOffsetX, maxTrackBar.bounds.minX + indicatorPadding),
            indicatorPadding + availableWidth - clampedIndicatorSize
        )
        if !isHiddenIndicator {
            indicator.frame = CGRect(
                x: clampedIndicatorX,
                y: maxTrackBar.bounds.midY - clampedIndicatorSize / 2,
                width: clampedIndicatorSize,
                height: clampedIndicatorSize
            )
        }
        
        let clampedTrackBarHeight = self.clampedTrackBarHeight
        let trackBarPadding = (maxTrackBarHeight - clampedTrackBarHeight) / 2
        trackBar.frame = CGRect(
            x: maxTrackBar.bounds.minX + trackBarPadding,
            y: maxTrackBar.bounds.midY - clampedTrackBarHeight / 2,
            width: clampedIndicatorX + clampedIndicatorSize / 2 - trackBarPadding + dotSize / 2,
            height: clampedTrackBarHeight
        )
        trackBar.layer.cornerCurve = .continuous
        trackBar.layer.cornerRadius = clampedTrackBarHeight / 2
        
        guard dotViews.count == dots.count, clampedProgress > 0 else {
            return
        }
        let isHiddenDot = isHiddenDotWhenProgressExceeds
        for (idx, dot) in dotViews.enumerated() {
            if needHiddenDotIndices.contains(idx) {
                if isHiddenDot {
                    dot.isHidden = true
                } else {
                    dot.isHidden = false
                    dot.backgroundColor = dotProgressExceedsColor
                }
            } else {
                dot.backgroundColor = dotColor
                dot.isHidden = false
            }
            
        }
    }
    
}
