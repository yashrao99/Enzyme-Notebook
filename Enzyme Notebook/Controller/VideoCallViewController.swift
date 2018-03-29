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
    @IBOutlet var remoteVideo: UIView!
    @IBOutlet weak var stackButtons: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        initializeAgoraEngine()
        setupVideo()
        joinChannel()
        setupLocalVideo()
        hideVideoMuted()
    }

    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self as? AgoraRtcEngineDelegate)
    }
    
    func setupVideo() {
        agoraKit.enableVideo()
        agoraKit.setVideoProfile(.portrait360P, swapWidthAndHeight: false)
    }
    
    func joinChannel() {
        agoraKit.joinChannel(byToken: nil, channelId: self.channel!, info: nil, uid: 0) {[weak self] (sid, uid, elapsed) -> Void in
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
        videoCanvas.renderMode = .adaptive
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideButtons()
        UIApplication.shared.isIdleTimerDisabled = false
        remoteVideo.removeFromSuperview()
        localVideo.removeFromSuperview()
        agoraKit = nil
    }
    
    func hideButtons() {
        stackButtons.isHidden = true
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickVideoMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        localVideo.isHidden = sender.isSelected
        localMute.isHidden = !sender.isSelected
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.switchCamera()
    }
    
    func hideVideoMuted() {
        videoMute.isHidden = true
        localMute.isHidden = true
    }
}
extension VideoCallViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        if (remoteVideo.isHidden) {
            remoteVideo.isHidden = false
        }
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .adaptive
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.remoteVideo.isHidden = true
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        remoteVideo.isHidden = true
        videoMute.isHidden = !muted
    }
}
