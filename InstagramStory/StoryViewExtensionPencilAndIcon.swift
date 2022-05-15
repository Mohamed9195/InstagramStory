//
//  StoryViewExtensionPencil.swift
//  Hebat
//
//  Created by Mohamed Hashem on 24/12/2021.
//  Copyright © 2021 mohamed hashem. All rights reserved.
//

import UIKit

//MARK:- Story View Controller Functionality
extension StoryViewController: PencilDelegate {
    func didAddImage(image: UIImage) {
        imageBackGround.image = image
        originalImage = image
    }
    
    func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = ["public.image"]
        //imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
    }

    func add(stickerText: String, color: UIColor = .white) {
        let frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width - 48, height: defaultStickerWidthHeight)
        let sticker = Sticker(frame: frame)
        sticker.isUserInteractionEnabled = false
        sticker.text = stickerText
        sticker.label?.textColor = color
        if stickerText.count < 40 {
            sticker.label?.numberOfLines = 1

        } else if stickerText.count >= 40, stickerText.count < 80 {
            sticker.label?.font = UIFont(name: "Helvetica", size: 24)
            sticker.label?.numberOfLines = 4

        } else {
            sticker.label?.font = UIFont(name: "Helvetica", size: 24)
            sticker.label?.numberOfLines = 8

        }

        self.viewScreenShoutImage.addSubview(sticker)

        sticker.translatesAutoresizingMaskIntoConstraints = false
        sticker.centerXAnchor.constraint(equalTo: self.viewScreenShoutImage.centerXAnchor).isActive = true
        sticker.centerYAnchor.constraint(equalTo: self.viewScreenShoutImage.centerYAnchor).isActive = true

        self.allStickers.append(sticker)
    }

    func findSticker(point: CGPoint) -> Sticker? {
        var aSticker: Sticker? = nil
        self.allStickers.forEach { (sticker) in
            if sticker.frame.contains(point) {
                aSticker = sticker
            }
        }
        return aSticker
    }

    func removeSticker(point: CGPoint) {
        for (index, sticker) in self.allStickers.enumerated() {
            if sticker.frame.contains(point) {
                self.allStickers.remove(at: index)
            }
        }
    }

    // MARK: - Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - StickerPickerDelegate
    func didPick(sticker: String) {
        self.dismiss(animated: true, completion: nil)
        self.add(stickerText: sticker)
    }

    // MARK: - TextEntryDelegate
    func didAdd(text: String, color: UIColor) {
        self.dismiss(animated: true, completion: nil)
        self.add(stickerText: text, color: color)
    }
}
