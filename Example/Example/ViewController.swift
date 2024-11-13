//
//  ViewController.swift
//  Example
//
//  Created by Sun on 2024/11/13.
//

import UIKit

import SegmentedProgressBar

class ViewController: UIViewController {
    
    private var bar1: SegmentedProgressBar?
    private var bar2: SegmentedProgressBar?
    private var bar3: SegmentedProgressBar?
    private var bar4: SegmentedProgressBar?
    private var bar5: SegmentedProgressBar?
    private var bar6: SegmentedProgressBar?
    
    private let values: [CGFloat] = [5, 10, 15, 20, 25, 30]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 每个点均分
        let dots1: [SegmentedProgressBar.Dot] = values.map {
            self.valueToDot($0, labelColor: .systemOrange)
        }
        let bar1 = SegmentedProgressBar(dots: dots1)
        bar1.trackBarColor = .systemRed
        bar1.indicatorBorderColor = .systemOrange
        bar1.dotProgressExceedsColor = .systemOrange
        self.bar1 = bar1
        
        // 2. 第1个点占不同
        let dots2: [SegmentedProgressBar.Dot] = values.map {
            self.valueToDot($0, widthProportion: $0 == 5 ? 0.5 : 1, labelColor: .darkText)
        }
        let bar2 = SegmentedProgressBar(dots: dots2)
        bar2.trackBarColor = .systemGreen
        bar2.indicatorBorderColor = .systemTeal
        bar2.dotProgressExceedsColor = .cyan
        self.bar2 = bar2
        
        // 3. 多个点占比不同
        let dots3: [SegmentedProgressBar.Dot] = values.map {
            self.valueToDot($0, widthProportion: Int($0).isMultiple(of: 2) ? 1.5 : 1, labelColor: .systemPink.withAlphaComponent(0.5))
        }
        let bar3 = SegmentedProgressBar(dots: dots3)
        bar3.trackBarColor = .systemBlue
        bar3.indicatorBorderColor = .systemIndigo
        bar3.dotProgressExceedsColor = .systemBrown
        self.bar3 = bar3
        
        // 4. 均分, 个别点不展示文本
        let dots4: [SegmentedProgressBar.Dot] = values.map {
            self.valueToDot($0, needLabel: Int($0).isMultiple(of: 2), labelColor: .link)
        }
        let bar4 = SegmentedProgressBar(dots: dots4)
        bar4.trackBarColor = .systemOrange
        bar4.indicatorBorderColor = .systemPink
        bar4.dotProgressExceedsColor = .white
        self.bar4 = bar4
        
        // 5. 不展示指示器
        let dots5: [SegmentedProgressBar.Dot] = values.map {
            self.valueToDot($0, widthProportion: $0 == 5 ? 0.5 : 1, labelColor: .lightGray)
        }
        let bar5 = SegmentedProgressBar(dots: dots5)
        bar5.trackBarColor = .systemPurple
        bar5.indicatorBorderColor = .systemBlue
        bar5.isHiddenIndicator = true
        bar5.isHiddenDotWhenProgressExceeds = true
        self.bar5 = bar5
        
        // 6. 均分, 不展示指示器, 进度为 0 时不展示进度条
        let dots6: [SegmentedProgressBar.Dot] = values.map { self.valueToDot($0, needLabel: false) }
        let bar6 = SegmentedProgressBar(dots: dots6)
        bar6.trackBarColor = .systemPurple
        bar6.indicatorBorderColor = .systemBlue
        bar6.dotProgressExceedsColor = .black
        bar6.isHiddenIndicator = true
        bar6.isHiddenDotWhenProgressExceeds = false
        bar6.isHiddenIndicatorWhenZeroProgress = true
        self.bar6 = bar6
        
        let slider = UISlider()
        slider.addTarget(self, action: #selector(silderValueChanged), for: .valueChanged)
        if let maxValue = values.max(), maxValue > 0 {
            let progress = 13.0 / maxValue
            slider.value = Float(progress)
            slider.sendActions(for: .valueChanged)
        }
        
        view.addSubview(bar1)
        bar1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar2)
        bar2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar3)
        bar3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar4)
        bar4.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar5)
        bar5.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar6)
        bar6.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bar1.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            bar1.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            bar1.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 40
            ),
            bar1.heightAnchor.constraint(equalToConstant: 60),
            
            bar2.leadingAnchor.constraint(equalTo: bar1.leadingAnchor),
            bar2.trailingAnchor.constraint(equalTo: bar1.trailingAnchor),
            bar2.topAnchor.constraint(equalTo: bar1.bottomAnchor, constant: 30),
            bar2.heightAnchor.constraint(equalTo: bar1.heightAnchor),
            
            bar3.leadingAnchor.constraint(equalTo: bar2.leadingAnchor),
            bar3.trailingAnchor.constraint(equalTo: bar2.trailingAnchor),
            bar3.topAnchor.constraint(equalTo: bar2.bottomAnchor, constant: 30),
            bar3.heightAnchor.constraint(equalTo: bar2.heightAnchor),
            
            bar4.leadingAnchor.constraint(equalTo: bar3.leadingAnchor),
            bar4.trailingAnchor.constraint(equalTo: bar3.trailingAnchor),
            bar4.topAnchor.constraint(equalTo: bar3.bottomAnchor, constant: 30),
            bar4.heightAnchor.constraint(equalTo: bar3.heightAnchor),
            
            bar5.leadingAnchor.constraint(equalTo: bar4.leadingAnchor),
            bar5.trailingAnchor.constraint(equalTo: bar4.trailingAnchor),
            bar5.topAnchor.constraint(equalTo: bar4.bottomAnchor, constant: 30),
            bar5.heightAnchor.constraint(equalTo: bar4.heightAnchor),
            
            bar6.leadingAnchor.constraint(equalTo: bar5.leadingAnchor),
            bar6.trailingAnchor.constraint(equalTo: bar5.trailingAnchor),
            bar6.topAnchor.constraint(equalTo: bar5.bottomAnchor, constant: 30),
            bar6.heightAnchor.constraint(equalTo: bar5.heightAnchor),
            
            slider.leadingAnchor.constraint(equalTo: bar5.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: bar5.trailingAnchor),
            slider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            slider.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc
    private func silderValueChanged(_ sender: UISlider) {
        bar1?.progress = CGFloat(sender.value)
        bar2?.progress = CGFloat(sender.value)
        bar3?.progress = CGFloat(sender.value)
        bar4?.progress = CGFloat(sender.value)
        bar5?.progress = CGFloat(sender.value)
        bar6?.progress = CGFloat(sender.value)
    }
    
    private func valueToDot(
        _ value: CGFloat,
        widthProportion: CGFloat = 1.0,
        needLabel: Bool = true,
        labelColor: UIColor? = nil
    ) -> SegmentedProgressBar.Dot {
        
        var label: NSMutableAttributedString?
        if needLabel {
            let unitText = "mins"
            let plainText = "\(Int(value))\(unitText)"
            label = NSMutableAttributedString(
                string: plainText,
                attributes: [
                    .foregroundColor: labelColor ?? .black,
                    .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
                ]
            )
            let unitFont = UIFont.systemFont(ofSize: 10, weight: .medium)
            let unitRange = (plainText as NSString).range(of: unitText)
            if unitRange.location != NSNotFound {
                label?.addAttribute(.font, value: unitFont, range: unitRange)
            }
        }
        var proportionValue = value
        if let maxValue = values.max(), maxValue > 0 {
            proportionValue = proportionValue / maxValue
        }
        return .init(
            value: proportionValue,
            widthProportion: widthProportion,
            label: label
        )
    }
}

