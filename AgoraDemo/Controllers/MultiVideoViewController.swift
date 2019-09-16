//
//  MultiVideoViewController.swift
//  AgoraDemo
//
//  Created by Rickie on 9/11/19.
//  Copyright © 2019 Rickie. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit


class MultiVideoViewController : UIViewController
{
    var agoraKit: AgoraRtcEngineKit!
    var Channel_ID : String?
    
    @IBOutlet weak var fullView: UIView!

   // @IBOutlet weak var remoteView: UIView!
    @IBOutlet var smallViews: [UIView]!
    
    var MaxRemoteVideos : Int {
        get {
            return smallViews.count
        }
    }
    
    private var RemoteSessions : [UInt:AgoraRtcVideoCanvas] = Dictionary()
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
    }
    
    func joinChannel() {
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        if let channel = Channel_ID {
            agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channel, info:nil, uid:0)
            {  (sid, uid, elapsed) -> Void in
                // Did join the channel
                print ("\(uid) joined channel:", channel)
            }
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            print ("Error: Channel_ID is nil!")
        }
    }
    
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func setupVideo() {
        agoraKit.enableVideo()  // Enables video mode.
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                           frameRate: .fps15,
                                           bitrate: AgoraVideoBitrateStandard,
                                           orientationMode: .adaptative)
        ) // Default video profile is 360P
        
       let _ =  self.smallViews.map{ $0.isHidden = true }
    }
    
    func setupLocalVideo(localVideo : UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .hidden // means filled and cropped
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    // MARK: - UI properties and actions
    private var videoOff = false
    private var micOff = false
    private var speakerOff = false

    @IBAction func onCameraSwitching(_ sender: Any) {
        print ("Switching camera")
        agoraKit.switchCamera()
    }
    
    @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
        print ("toggle video on/off")
        videoOff.toggle()
        sender.tintColor = videoOff ? UIColor.gray : nil
        // mute local video
        agoraKit.muteLocalVideoStream(videoOff)
    }
    
    @IBAction func voiceButtonPressed(_ sender: UIBarButtonItem) {
        print ("toggle mic on/off")
        micOff.toggle()
        sender.tintColor = micOff ? UIColor.gray : nil
        // mute local audio
        agoraKit.muteLocalAudioStream(micOff)
    }
    
    @IBAction func speakerButtonPressed(_ sender: UIBarButtonItem) {
        print ("toggle speaker on/off")
        speakerOff.toggle()
        sender.tintColor = speakerOff ? UIColor.gray : nil
        agoraKit.setEnableSpeakerphone(!speakerOff)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        print ("share screen is TBD")
    }
    
    @IBOutlet weak var fullScreenView: UIView!
    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAgoraEngine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVideo()
        setupLocalVideo(localVideo: fullView)
        joinChannel()
        RemoteSessions = Dictionary()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leaveChannel()
    }
    
}


extension MultiVideoViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        
        if RemoteSessions.keys.contains(uid) {
            print ("User already here...??")
            return
        }
        
        let connectedCount = RemoteSessions.count
        if connectedCount < MaxRemoteVideos {
            let remoteView = smallViews[connectedCount]
            remoteView.isHidden = false
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = remoteView
            videoCanvas.renderMode = .hidden
            RemoteSessions[uid] = videoCanvas
            agoraKit.setupRemoteVideo(videoCanvas)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        if let canvas = RemoteSessions[uid] {
            canvas.view?.isHidden = true
            RemoteSessions[uid] = nil
        }
        self.RearrangeSmallViews()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        
        if let canvas = RemoteSessions[byUid] {
            canvas.view?.alpha = muted ? 0.3 : 1
        }
    }
}

extension MultiVideoViewController {
    private func RearrangeSmallViews() {
        let _ =  self.smallViews.map{ $0.isHidden = true }
        var i = 0
        for canvas in RemoteSessions.values {
            canvas.view = self.smallViews[i]
            self.smallViews[i].isHidden = false
            i += 1
        }
    }
}
