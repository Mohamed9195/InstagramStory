//
//  ScreenShoutImageStoryViewController.swift
//  Hebat
//
//  Created by mohamed hashem on 10/02/2021.
//  Copyright © 2021 mohamed hashem. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ScreenShoutImageStoryViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageTakedView: UIImageView!
    @IBOutlet weak var viewScreenShoutImage: UIView!
    @IBOutlet weak var scrollViewImage: UIScrollView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var imageStory: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollViewImage.minimumZoomScale = 0.2
        self.scrollViewImage.maximumZoomScale = 3.5
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageTakedView
    }

    @IBAction func openImageLibrary(_ sender: UIButton) {
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
            popoverController.sourceView = addImageButton
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

    @IBAction func takeScreenShoutView(_ sender: UIButton) {
        let newImage = self.viewScreenShoutImage.takeScreenshot()

        let storyBoard = UIStoryboard(name: "PopUpViews", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "StoryViewController") as? StoryViewController
        viewController?.modalPresentationStyle = .fullScreen
        viewController?.currentImageBackGround = newImage
        if viewController != nil {
            self.present(viewController!, animated: true, completion: nil)
        }
    }

    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- camera extension
extension ScreenShoutImageStoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let originalImage: UIImage? = info[.originalImage] as? UIImage
        let editedImage: UIImage? = info[.editedImage] as? UIImage

        let image: UIImage = ((editedImage == nil) ? editedImage : originalImage)!

        imageTakedView.image = image
        imageStory = image
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK:- PickerView Delegate, DataSource
extension ScreenShoutImageStoryViewController: UIColorPickerViewControllerDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            self.scrollViewImage.backgroundColor = cell.colorButton.backgroundColor
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorImageCollectionViewCell {
            scrollViewImage.backgroundColor = cell.colorButton.backgroundColor
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


extension UIView {

    func takeScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
