//
//  PlayVideoViewController.swift
//  iSocialize
//
//  Created by Tracy Pan on 12/01/18.
//  Copyright © 2018 Tracy Pan. All rights reserved.
//
import UIKit
import AVKit
import MobileCoreServices

class PlayVideoViewController: UIViewController {
    
    @IBAction func playVideo(_ sender: AnyObject) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        
    }
}
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey  : Any]) {
        // 1
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            else {
                return
        }
        
        // 2
        dismiss(animated: true) {
            //3
            let player = AVPlayer(url: url)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
}
