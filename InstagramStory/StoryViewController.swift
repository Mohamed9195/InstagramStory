//
//  StoryPopViewController.swift
//  Hebat
//
//  Created by mohamed hashem on 23/11/2020.
//  Copyright © 2020 mohamed hashem. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

let defaultStickerWidthHeight = CGFloat(54.0)
let defaultFontSize = CGFloat(38.0)
let minimumOffsetForSwipeUp = CGFloat(100.0)

protocol TakeScreenShout {
    func screenShoutImage(image: UIImage)
}

public class StoryViewController: UIViewController, UIGestureRecognizerDelegate, StickerPickerDelegate, TextEntryDelegate {
    
    @IBOutlet weak var imageBackGround: UIImageView!
    @IBOutlet weak var viewScreenShoutImage: UIView!
    @IBOutlet weak var takeImage: UIButton!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var saveItemButton: UIButton!
    @IBOutlet weak var textItemButton: UIButton!
    @IBOutlet weak var emojItemButton: UIButton!
    @IBOutlet weak var colorItemButton: UIButton!
    @IBOutlet weak var doneItemButton: UIButton!
    @IBOutlet weak var cropItemButton: UIButton!
    @IBOutlet weak var cropView: UIView!

    var activeSticker: Sticker?
    var allStickers: [Sticker] = []
    var waitingToExposeStickerPicker = false
    var delegateScreenShoutImage: TakeScreenShout?
    var currentImageBackGround: UIImage?
    var doCorpImage: Bool = false
    var changeBackGroundColor: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        imageBackGround.isUserInteractionEnabled = true
        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))
        imageBackGround.addGestureRecognizer(pinchMethod)
    }

    @objc func pinchImage(sender: UIPinchGestureRecognizer) {
        guard sender.view != nil, doCorpImage else { return }

        if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
            guard scale.a > 1.0 else { return }
            guard scale.d > 1.0 else { return }
            sender.view?.transform = scale
            sender.scale = 1.0
        }
    }
    
    @IBAction func cropImage(_ sender: UIButton) {
        viewScreenShoutImage.alpha = 0.3
        doCorpImage = true
        doneItemButton.isHidden = false

        cropItemButton.isHidden = true
        saveItemButton.isHidden = true
        textItemButton.isHidden = true
        emojItemButton.isHidden = true
        colorItemButton.isHidden = true
        takeImage.isHidden = true
    }

    @IBAction func doneCropImage(_ sender: UIButton) {
        viewScreenShoutImage.alpha = 1.0
        doCorpImage = false
        doneItemButton.isHidden = true

        cropItemButton.isHidden = false
        saveItemButton.isHidden = false
        textItemButton.isHidden = false
        emojItemButton.isHidden = false
        colorItemButton.isHidden = false
        takeImage.isHidden = false
    }

    @IBAction func changeImageNow(_ sender: Any) {
        doCorpImage = false
        changeBackGroundColor = !changeBackGroundColor
        changeBackGroundColor ? (colorCollectionView.isHidden = false) : (colorCollectionView.isHidden = true)
    }

    @IBAction func openImageLibrary(_ sender: UIButton) {
        doCorpImage = false
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default, handler: { [weak self] (_) in
                self?.showImagePicker(for: .camera)
            }))
        }

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Choose photo", comment: ""), style: .default, handler: { [weak self] (_) in
            self?.showImagePicker(for: .photoLibrary)
        }))

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = takeImage
            popoverController.sourceRect = view.frame
        }

        present(alertController, animated: true, completion: nil)
    }

    private func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func openTextEditor(_ sender: Any) {
        doCorpImage = false
        let textEditor = self.storyboard?.instantiateViewController(withIdentifier: "TextEntry") as! TextEntryViewController
        textEditor.modalPresentationStyle = .overCurrentContext
        textEditor.delegate = self
        self.present(textEditor, animated: true, completion: nil)
    }
    
    @IBAction func openStickerPicker(_ sender: Any) {
        doCorpImage = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StickerPicker") as! StickerPickerViewController
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveImageStory(_ sender: UIButton) {
        let newImage = self.viewScreenShoutImage.takeScreenshot()
        if newImage != nil {
            delegateScreenShoutImage?.screenShoutImage(image: newImage!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CREATE-IMAGE"), object: nil, userInfo: ["Image" : newImage!])
            self.dismiss(animated: true, completion: nil)
        }
    }

    // For placing stickers
    @IBAction func didPanOnStory(_ sender: Any) {
        let recognizer = sender as! UIPanGestureRecognizer
        
        if recognizer.state == .began {
            self.activeSticker = self.findSticker(point: recognizer.location(in: self.viewScreenShoutImage))
            if let sticker = self.activeSticker {
                self.viewScreenShoutImage.bringSubviewToFront(sticker)
            }else {
                waitingToExposeStickerPicker = true
            }
        } else if recognizer.state == .changed {
            let translation = recognizer.translation(in: self.viewScreenShoutImage)
            if let sticker = self.activeSticker {
                sticker.translation = translation
            } else {
                if waitingToExposeStickerPicker {
                    if abs(translation.y) > abs(translation.x)
                        && translation.y < (0.0 - minimumOffsetForSwipeUp) {
                        self.openStickerPicker(self)
                        waitingToExposeStickerPicker = false
                    }
                }
            }
        } else if recognizer.state == .ended {
            if let sticker = self.activeSticker {
                sticker.saveTranslation()
            }
            waitingToExposeStickerPicker = false
        }
    }
    
    // For scaling (resizing) stickers
    @IBAction func didPinchOnStory(_ sender: Any) {
        let recognizer = sender as! UIPinchGestureRecognizer
        
        if recognizer.state == .began {
            if let sticker = self.activeSticker {
                self.viewScreenShoutImage.bringSubviewToFront(sticker)
            }
        } else if recognizer.state == .changed {
            if let sticker = self.activeSticker {
                sticker.scale = recognizer.scale
            }
        } else if recognizer.state == .ended {
            if let sticker = self.activeSticker {
                sticker.saveScale()
            }
        }
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // Fo rotating stickers
    @IBAction func didRotateOnStory(_ sender: Any) {
        let recognizer = sender as! UIRotationGestureRecognizer
        
        if recognizer.state == .began {
            if let sticker = self.activeSticker {
                self.viewScreenShoutImage.bringSubviewToFront(sticker)
            }
        } else if recognizer.state == .changed {
            if let sticker = self.activeSticker {
                sticker.rotation = recognizer.rotation
            }
        } else if recognizer.state == .ended {
            if let sticker = self.activeSticker {
                sticker.saveRotation()
            }
        }
    }
    
    private func add(stickerText: String){
        let frame = CGRect(x: 0.0, y: 0.0, width: defaultStickerWidthHeight, height: defaultStickerWidthHeight)
        let sticker = Sticker(frame: frame)
        sticker.isUserInteractionEnabled = false
        sticker.text = stickerText
        self.viewScreenShoutImage.addSubview(sticker)
        
        sticker.translatesAutoresizingMaskIntoConstraints = false
        sticker.centerXAnchor.constraint(equalTo: self.viewScreenShoutImage.centerXAnchor).isActive = true
        sticker.centerYAnchor.constraint(equalTo: self.viewScreenShoutImage.centerYAnchor).isActive = true

        self.allStickers.append(sticker)
    }
    
    private func findSticker(point: CGPoint) -> Sticker? {
        var aSticker: Sticker? = nil
        self.allStickers.forEach { (sticker) in
            if sticker.frame.contains(point) {
                aSticker = sticker
            }
        }
        return aSticker
    }
    
    // MARK: - Gesture Recognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - StickerPickerDelegate
    func didPick(sticker: String) {
        self.dismiss(animated: true, completion: nil)
        self.add(stickerText: sticker)
    }
    
    // MARK: - TextEntryDelegate
    func didAdd(text: String) {
        self.dismiss(animated: true, completion: nil)
        self.add(stickerText: text)
    }
}


//MARK:- camera extension
extension StoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let originalImage: UIImage? = info[.originalImage] as? UIImage
        let editedImage: UIImage? = info[.editedImage] as? UIImage

        let image: UIImage = ((editedImage == nil) ? editedImage : originalImage)!

        imageBackGround.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- PickerView Delegate, DataSource
extension StoryViewController: UIColorPickerViewControllerDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  15
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorImageCollectionViewCell", for: indexPath) as? ColorImageCollectionViewCell else {
            fatalError("not found Color Image CollectionViewCell")
        }

        switch indexPath.row {
        case 0:  cell.colorButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case 1:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        case 2:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        case 3:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        case 4:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case 5:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case 6:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        case 7:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case 8:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case 9:  cell.colorButton.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        case 10: cell.colorButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        case 11: cell.colorButton.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        case 12: cell.colorButton.backgroundColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        case 13: cell.colorButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        case 14: cell.colorButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)

        default: cell.colorButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }

        cell.selectColorClosure = {
            self.viewScreenShoutImage.backgroundColor = cell.colorButton.backgroundColor
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorImageCollectionViewCell {
            self.viewScreenShoutImage.backgroundColor = cell.colorButton.backgroundColor
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
