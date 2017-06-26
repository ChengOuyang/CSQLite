//
//  CAnimationTools.swift
//  CSQLite
//
//  Created by yanwei on 17/6/22.
//  Copyright © 2017年 clou. All rights reserved.
//

import UIKit

public enum CAnimationType {
    case cornerRadius
}

extension CAnimationType {
    
    public func animation(fromValue: Any?, toValue: Any?, duration: CFTimeInterval) ->CABasicAnimation {
        switch self {
        case .cornerRadius:
            let animation = CABasicAnimation(keyPath:"cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = duration
//            animation.delegate
            return animation
        }
    }
}
