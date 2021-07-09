//
//  WlkthroughViewController.swift
//  PageView
//
//  Created by 夏英浩 on 5/6/21.
//

import UIKit

class WalkthroughViewController: UIViewController {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet{
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    var numberOfPages = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func skipButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController{
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
                switch index {
                case 0...numberOfPages-2:
                    walkthroughPageViewController?.forwardPage()
                case numberOfPages-1:
                    dismiss(animated: true, completion: nil)
                default: break
                }
        }
        updateUI()
    }
    
    func updateUI(){
        if let index = walkthroughPageViewController?.currentIndex {
                switch index {
                case 0...numberOfPages-2:
                    nextButton.setTitle("NEXT", for: .normal)
                    skipButton.isHidden = false
                case numberOfPages-1:
                    nextButton.setTitle("GET STARTED", for: .normal)
                    skipButton.isHidden = true
                default: break
                }
                pageControl.currentPage = index
            }
    }
}

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate{
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
}
