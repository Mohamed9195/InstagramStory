//
//  StoryViewExtensionFilter.swift
//  Hebat
//
//  Created by Mohamed Hashem on 24/12/2021.
//  Copyright © 2021 mohamed hashem. All rights reserved.
//

import UIKit
import QCropper

extension StoryViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            imageBackGround.image = image
            originalImage = image
        }
    }
}

//MARK:- PickerView Delegate, DataSource
extension StoryViewController: UIColorPickerViewControllerDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorCollectionView {
            return  15
        } else {
            if loadCollectionView {
                if collectionView.tag == 1 {
                    return  15
                } else {
                    return  15
                }
            } else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorCollectionView {
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

            cell.selectColorClosure = { [weak self] in
                guard let self = self else { return }
                self.viewScreenShoutImage.backgroundColor = cell.colorButton.backgroundColor
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
                fatalError("not found Color Image FilterCollectionViewCell")
            }
            
            //if cellColor[indexPath.row] {
            // cell.filterView.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            //        } else {
            cell.filterView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            cell.filterView.layer.borderWidth = 0.7
            //        }
            
            switch indexPath.row {
            case 0: cell.filterImage.image = UIImage(named: "original")
            case 1: cell.filterImage.image = UIImage(named: "CICrystallize")
            case 2: cell.filterImage.image = UIImage(named: "CICMYKHalftone")
            case 3: cell.filterImage.image = UIImage(named: "CIGaussianBlur")
            case 4: cell.filterImage.image = UIImage(named: "CILanczosScaleTransform")
            case 5: cell.filterImage.image = UIImage(named: "CIBloom")
            case 6: cell.filterImage.image = UIImage(named: "CISepiaTone")
            case 7: cell.filterImage.image = UIImage(named: "Transfer")
            case 8: cell.filterImage.image = UIImage(named: "Tonal")
            case 9: cell.filterImage.image = UIImage(named: "Process")
            case 10: cell.filterImage.image = UIImage(named: "Noir")
            case 11: cell.filterImage.image = UIImage(named: "Mono")
            case 12: cell.filterImage.image = UIImage(named: "Instant")
            case 13: cell.filterImage.image = UIImage(named: "Fade")
            case 14: cell.filterImage.image = UIImage(named: "Chrome")
                
            default: cell.filterImage.image = UIImage(named: "original")
            }
            
            cell.selectFilterClosure = { [weak self] in
                guard let self = self else { return }
                
                for (index, _) in self.cellColor.enumerated() {
                    if index == indexPath.row {
                        self.cellColor[indexPath.row] = true
                    } else {
                        self.cellColor[indexPath.row] = false
                    }
                }
                
                let image = self.originalImage
                DispatchQueue.main.async {
                    switch indexPath.row {
                    case 0:
                        self.imageBackGround.image = self.originalImage
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 1:
                        self.imageBackGround.image = image.addFilter(filter: .CICrystallize)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 2:
                        self.imageBackGround.image = image.addFilter(filter: .CICMYKHalftone)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 3:
                        self.imageBackGround.image = image.addFilter(filter: .CIGaussianBlur)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 4:
                        self.imageBackGround.image = image.addFilter(filter: .CILanczosScaleTransform)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 5:
                        self.imageBackGround.image = image.addFilter(filter: .CIBloom)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 6:
                        self.imageBackGround.image = image.addFilter(filter: .CISepiaTone)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 7:
                        self.imageBackGround.image = image.addFilter(filter: .Transfer)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 8:
                        self.imageBackGround.image = image.addFilter(filter: .Tonal)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 9:
                        self.imageBackGround.image = image.addFilter(filter: .Process)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 10:
                        self.imageBackGround.image = image.addFilter(filter: .Noir)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 11:
                        self.imageBackGround.image = image.addFilter(filter: .Mono)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 12:
                        self.imageBackGround.image = image.addFilter(filter: .Instant)
                        self.imageBackGround.contentMode = .scaleAspectFit
                    case 13:
                        self.imageBackGround.image = image.addFilter(filter: .Fade); self.imageBackGround.contentMode = .scaleAspectFit
                    case 14: self.imageBackGround.image = image.addFilter(filter: .Chrome); self.imageBackGround.contentMode = .scaleAspectFit
                        
                    default: self.imageBackGround.contentMode = .scaleAspectFit
                    }
                }
                self.filterAndBackGroundCollectionView.reloadData()
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorImageCollectionViewCell {
                viewScreenShoutImage.backgroundColor = cell.colorButton.backgroundColor
            }
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: - CollectionView DelegateFlowLayout
extension StoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colorCollectionView {
            return CGSize(width: 20, height: 20.0)
        } else {
        return CGSize(width: 35.0, height: 40.0)
        }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
}
