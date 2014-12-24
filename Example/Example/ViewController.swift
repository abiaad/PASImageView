//
//  ViewController.swift
//  Example
//
//  Created by Giordano Scalzo on 21/08/2014.
//  Copyright (c) 2014 Effective Code. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var imageView = PASImageView(frame: CGRectMake(0, 0, 200, 200))
        imageView.center = CGPointMake(view.bounds.width / 2, view.bounds.height / 2)
        
        imageView.backgroundProgressColor(UIColor.whiteColor())
        imageView.progressColor(UIColor.redColor())
        view.addSubview(imageView)

        if let anURL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/e/e6/Batman_cossplay.JPG") {
            imageView.imageURL(anURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

