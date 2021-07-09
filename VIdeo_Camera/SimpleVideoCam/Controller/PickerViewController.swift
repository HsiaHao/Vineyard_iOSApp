//
//  PickerViewController.swift
//  SimpleVideoCam
//
//  Created by 夏英浩 on 5/2/21.
//  Copyright © 2021 AppCoda. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var plotPicker: UIPickerView!
    @IBOutlet weak var varietyPicker: UIPickerView!
    @IBOutlet weak var rowPicker: UIPickerView!
    
    @IBOutlet weak var newVideoButton: UIButton!
    
    var plotPickerData: [String] = []
    var varietyPickerData: [String] = []
    var rowPickerData: [String] = []
    
    var curr_plot = "1"
    var curr_variety = "New York Muscart"
    var curr_row = "1"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("picker view loaded")
        setVideoBUtton()
        overrideUserInterfaceStyle = .light
        
        title = "Vineyard"
        
        plotPicker.tag = 1
        varietyPicker.tag = 2
        rowPicker.tag = 3
        
        plotPicker.setValue(UIColor.white, forKey: "textColor")
        varietyPicker.setValue(UIColor.white, forKey: "textColor")
        rowPicker.setValue(UIColor.white, forKey: "textColor")
        
        setDelegate()
        setPickerData()
    }
    
    func setVideoBUtton(){
        newVideoButton.layer.cornerRadius = 8
        newVideoButton.layer.masksToBounds  = true
        print("test length:",newVideoButton.intrinsicContentSize.width)
        newVideoButton.setTitle("Start a New Video", for: .normal)
        newVideoButton.sizeToFit()
    }
    
    func setPickerData(){
        for i in 1...100{
            plotPickerData.append(String(i))
        }
        
        for i in 1...100{
            rowPickerData.append(String(i))
        }
        
        varietyPickerData = ["New York Muscat", "Van Buren Grapevine", "Alden", "Amsden", "Autumn Royal"]
    }
    
    func setDelegate(){
        self.plotPicker.delegate = self
        self.plotPicker.dataSource = self
        
        self.varietyPicker.delegate = self
        self.varietyPicker.dataSource = self
        
        self.rowPicker.delegate = self
        self.rowPicker.dataSource = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SimpleVideoCamController{
            let vc = segue.destination as? SimpleVideoCamController
            vc?.row_in_yard = curr_row
            vc?.variety = curr_variety
            vc?.plot = curr_plot
        }
    }

}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag==1{
            // plot
            if component==1{
                return plotPickerData.count
            }else{
                return 1
            }
        }else if pickerView.tag==2{
            //variety
            if component==1{
                return varietyPickerData.count
            }else{
                return 1
            }
        }else{
            //row
            if component==1{
                return rowPickerData.count
            }else{
                return 1
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag==1{
            if component==0{
                return "Plot:"
            }else{
                curr_plot = plotPickerData[row]
                return plotPickerData[row]
            }
        }else if pickerView.tag==2{
            if component==0{
                return "Variety:"
            }else{
                curr_variety = varietyPickerData[row]
                return varietyPickerData[row]
            }
        }else{
            if component==0{
                return "Row:"
            }else{
                curr_row = rowPickerData[row]
                return rowPickerData[row]
            }
        }
    }
}
