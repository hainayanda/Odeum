//
//  Utilities.swift
//  Odeum
//
//  Created by Nayanda Haberty on 25/01/21.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension UIResponder {
    var viewController: UIViewController? {
        let responder = next
        guard let viewController = responder as? UIViewController else {
            return responder?.viewController
        }
        return viewController
    }
}

func makeCircle(withSize size: CGSize = .init(width: 8, height: 8)) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer {
        UIGraphicsEndImageContext()
    }
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.setFillColor(UIColor.white.cgColor)
    context.setStrokeColor(UIColor.clear.cgColor)
    let bounds = CGRect(origin: .zero, size: size)
    context.addEllipse(in: bounds)
    context.drawPath(using: .fill)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    return image
}
#endif
