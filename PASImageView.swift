//
//  PASImageView.swift
//  PASImageView
//
//  Created by Pierre Abi-aad on 09/06/2014.
//  Copyright (c) 2014 Pierre Abi-aad. All rights reserved.
//

import UIKit
import QuartzCore

let spm_identifier  = "spm.imagecache.tg"
let kLineWidth      :CGFloat = 3.0

func rad(degrees : Float) -> Float {
    return ((degrees) / Float((180.0/M_PI)))
}


class SPMImageCache : NSObject {
    var cachePath = String()
    let fileManager = NSFileManager.defaultManager()
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let rootCachePath : AnyObject = paths[0]
        
        self.cachePath = rootCachePath.stringByAppendingPathComponent(spm_identifier)

        if !self.fileManager.fileExistsAtPath(self.cachePath) {
            self.fileManager.createDirectoryAtPath(self.cachePath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        super.init()
    }
    
    func image(image: UIImage, URL: NSURL) {
        var imageData :NSData = NSData()
        let fileExtension = URL.pathExtension
        
        if fileExtension == "png" {
            imageData = UIImagePNGRepresentation(image)
        } else if fileExtension == "jpg" || fileExtension == "jpeg" {
            imageData = UIImageJPEGRepresentation(image, 1.0)
        }
        
        imageData.writeToFile(self.cachePath.stringByAppendingPathComponent(String(format: "%u.%@", URL.hash, fileExtension)), atomically: true)
    }
    
    func imageForURL(URL: NSURL) -> UIImage? {
        let fileExtension = URL.pathExtension
        let path = self.cachePath.stringByAppendingPathComponent(String(format: "%u.%@", URL.hash, fileExtension))
        if self.fileManager.fileExistsAtPath(path) {
            return UIImage(data: NSData(contentsOfFile: path))
        }
        return nil
    }
}


class PASImageView : UIView, NSURLSessionDownloadDelegate {
    var cacheEnabled                = true
    var placeHolderImage            = UIImage()
    var backgroundProgressColor     = UIColor.blackColor()
    var progressColor               = UIColor.redColor()
    var backgroundLayer             = CAShapeLayer()
    var progressLayer               = CAShapeLayer()
    var containerImageView          = UIImageView()
    var progressContainer           = UIView()
    var cache                       = SPMImageCache()
    var delegate                    :PASImageViewDelegate?
    
    convenience init(frame: CGRect, delegate: PASImageViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius         = CGRectGetWidth(self.bounds)/2.0
        self.layer.masksToBounds        = false
        self.clipsToBounds              = true
        
        println(CGRectGetMidX(self.bounds))
        println(CGRectGetMidX(self.bounds))
        let arcCenter   = CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
        let radius      = Float(min(CGRectGetMidX(self.bounds) - 1, CGRectGetMidY(self.bounds)-1))
        let circlePath  = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: -rad(90), endAngle: rad(360-90), clockwise: true)
        
        
        self.backgroundLayer.path           = circlePath.CGPath
        self.backgroundLayer.strokeColor    = backgroundProgressColor.CGColor
        self.backgroundLayer.fillColor      = UIColor.clearColor().CGColor
        self.backgroundLayer.lineWidth      = kLineWidth
        
        self.progressLayer.path             = self.backgroundLayer.path
        self.progressLayer.strokeColor      = progressColor.CGColor
        self.progressLayer.fillColor        = self.backgroundLayer.fillColor
        self.progressLayer.lineWidth        = self.backgroundLayer.lineWidth
        self.progressLayer.strokeEnd        = 0.0
        
        
        self.progressContainer                      = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        self.progressContainer.layer.cornerRadius   = CGRectGetWidth(self.bounds)/2.0
        self.progressContainer.layer.masksToBounds  = false
        self.progressContainer.clipsToBounds        = true
        self.progressContainer.backgroundColor      = UIColor.clearColor()
        
        self.containerImageView                     = UIImageView(frame: CGRectMake(1, 1, frame.size.width-2, frame.size.height-2))
        self.containerImageView.layer.cornerRadius  = CGRectGetWidth(self.bounds)/2.0
        self.containerImageView.layer.masksToBounds = false
        self.containerImageView.clipsToBounds       = true
        self.containerImageView.contentMode         = UIViewContentMode.ScaleAspectFill
        
        self.progressContainer.layer.addSublayer(self.backgroundLayer)
        self.progressContainer.layer.addSublayer(self.progressLayer)
        
        self.addSubview(self.containerImageView)
        self.addSubview(self.progressContainer)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleSingleTap:"))
        
    }
    
    func handleSingleTap(gesture: UIGestureRecognizer) {
        delegate?.PAImageView(didTapped: self)
    }
    
    func backgroundProgressColor(color: UIColor) {
        self.backgroundProgressColor        = color
        self.backgroundLayer.strokeColor    = self.backgroundProgressColor.CGColor
    }
    
    func progressColor(color: UIColor) {
        self.progressColor              = color
        self.progressLayer.strokeColor  = self.progressColor.CGColor
    }
    
    func placeHolderImage(image: UIImage) {
        self.placeHolderImage = image
        if self.containerImageView.image == nil {
            self.containerImageView.image = image
        }
    }
    
    func imageURL(URL: NSURL) {
        let urlRequest = NSURLRequest(URL: URL)
        var cachedImage = (self.cacheEnabled) ? self.cache.imageForURL(URL) : nil
        
        if cachedImage {
            self.updateImage(cachedImage!, animated: false)
        } else {
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
            let downloadTask = session.downloadTaskWithRequest(urlRequest)
            downloadTask.resume()
        }
    }
    
   func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        let image = UIImage(data: NSData(contentsOfURL: location))
        dispatch_async(dispatch_get_main_queue(), {
            self.updateImage(image , animated: true)
        })
        if self.cacheEnabled {
            self.cache.image(image, URL: downloadTask.response.URL)
        }
        
    }

    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress: Float = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        dispatch_async(dispatch_get_main_queue(), {
            self.progressLayer.strokeEnd        = progress;
            self.backgroundLayer.strokeStart    = progress;
        })
    }
    
    func updateImage(image: UIImage, animated: Bool) {
        let duration    = (animated) ? 0.3 : 0.0
        let delay       = (animated) ? 0.1 : 0.0

        self.containerImageView.transform   = CGAffineTransformMakeScale(0, 0)
        self.containerImageView.alpha       = 0.0
        self.containerImageView.image       = image
        
        UIView.animateWithDuration(duration, animations: {
            self.progressContainer.transform    = CGAffineTransformMakeScale(1.1, 1.1);
            self.progressContainer.alpha        = 0.0;
            UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.containerImageView.transform   = CGAffineTransformIdentity;
                self.containerImageView.alpha       = 1.0;
                }, completion: nil)
            }, completion: { finished in
                self.progressLayer.strokeColor = self.backgroundProgressColor.CGColor
                UIView.animateWithDuration(duration, animations: {
                    self.progressContainer.transform    = CGAffineTransformIdentity;
                    self.progressContainer.alpha        = 1.0;
                    })
            })
    }
    
}

protocol PASImageViewDelegate {
    
    func PAImageView(didTapped imageView: PASImageView)
}


