//
//  UIImage+Resize.swift
//  BatPlotter
//
//  Created by edgars.baumanis on 26/01/2022.
//

import UIKit

extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {

        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
