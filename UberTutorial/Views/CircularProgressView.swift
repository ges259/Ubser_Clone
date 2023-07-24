//
//  CircularProgressView.swift
//  UberTutorial
//
//  Created by 계은성 on 2023/07/25.
//

import UIKit

final class CircularProgressView: UIView {
    
    // MARK: - Properties
    
    // 원으로 시간 표시
    private var progressLayer: CAShapeLayer!
    
    private var trackLayer: CAShapeLayer!
    // 맥박(?) 효과
    private var pulsatingLayer: CAShapeLayer!
    
    
    
    // MARK: - Helper Functions
    private func configureCircleLayers() {
        self.pulsatingLayer = circleShapeLayer(strokeColor: .clear,
                                               fillColor: .pulsatingFillColor)
        self.layer.addSublayer(self.pulsatingLayer)
        
        
        self.trackLayer = circleShapeLayer(strokeColor: .trackStrokeColor,
                                           fillColor: .clear)
        self.layer.addSublayer(self.trackLayer)
        self.trackLayer.strokeEnd = 1
        
        
        self.progressLayer = circleShapeLayer(strokeColor: .outlineStrokeColor,
                                              fillColor: .clear)
        self.layer.addSublayer(self.progressLayer)
        self.progressLayer.strokeEnd = 1
    }
    
    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        let center = CGPoint(x: 0, y: 0)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: self.frame.width / 2.5,
                                        startAngle: -(.pi / 2),
                                        endAngle: 1.5 * .pi,
                                        clockwise: true) // 시계방향
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        
        return layer
    }
    
    
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
            // 애니메이션 크기
            animation.toValue = 1.25
            // 애니메이션 커졌다 - 작아졌다 시간 간격
            animation.duration = 0.8
            // 애니메이션 효과
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            // 자체 재생 ( 알아서 시작 )
            animation.autoreverses = true
            //
            animation.repeatCount = Float.infinity
        
        self.pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func setProgressWithAnimation(duration: TimeInterval,
                                          value: Float,
                                          completion: @escaping () -> Void) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "StrokeEnd")
            animation.duration = duration
            animation.fromValue = 1
            animation.toValue = value
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        self.progressLayer.strokeEnd = CGFloat(value)
        self.progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
    
    
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureCircleLayers()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
