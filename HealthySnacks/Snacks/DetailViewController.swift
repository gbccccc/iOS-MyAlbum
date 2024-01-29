//
//  DetailViewController.swift
//  HealthySnacks
//
//  Created by cofincup on 2024/1/29.
//  Copyright © 2024 Razeware. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tag: UILabel!
    @IBOutlet var confidence: UILabel!
  
    var image: TaggedImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image!.image
        self.navigationItem.title = String(format: "%@ %.1f%%", image!.tag, image!.confidence * 100)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
