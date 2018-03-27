//
//  VideoCallViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/26/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit
import AgoraRtcEngineKit

class VideoCallViewController: UIViewController {
    
    var agoraKit: AgoraRtcEngineKit!
    let AppID: String = "fcb977e770bb4f1fbd7283e529ff9b82"
    var channel: String?
    
    @IBOutlet weak var localVideo : UIView!
    @IBOutlet weak var videoMute: UIImageView!
    @IBOutlet weak var localMute: UIImageView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var hangUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAgoraEngine()
        setupVideo()
        joinChannel()
        setupLocalVideo()
    }
}


extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }
    
    func setupVideo() {
        agoraKit.enableVideo()
        agoraKit.setVideoProfile(._VideoProfile_360P, swapWidthAndHeight: false)
    }
    
    func joinChannel() {
        agoraKit.joinChannel(byToken: nil, channelId: "demoChannel1", info: nil, uid: 0) {[weak self] (sid, uid, elapsed) -> Void in
            if let weakSelf = self {
                weakSelf.agoraKit.setEnableSpeakerphone(true)
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
    
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .render_Fit
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    
    
}
