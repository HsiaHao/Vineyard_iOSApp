//
//  HomeViewController.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 5/2/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
    }
    
    @IBAction func newVIdeoPressed(_ sender: UIButton) {
        print("new video")
    }
    @IBAction func showVideoList(_ sender: UIButton) {
        print("List")
    }
    @IBAction func showTutorial(_ sender: UIButton) {
        print("tutorial")
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(identifier: "WalkthroughViewController") as? WalkthroughViewController{
            present(walkthroughViewController, animated: true, completion: nil)
        }
        
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
