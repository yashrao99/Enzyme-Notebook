//
//  SetMeetingChannelViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/26/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

class SetMeetingViewController: UIViewController {
    
    @IBOutlet weak var channelName: UITextField!
    @IBOutlet weak var startCall: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func startCall(_ sender: UIButton) {
        if !(channelName.text?.isEmpty)! {
            self.performSegue(withIdentifier: "startCall", sender: self)
        } else {
            print("Enter Channel Name")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VideoCallViewController {
            vc.channel = channelName.text!
        }
    }
}
