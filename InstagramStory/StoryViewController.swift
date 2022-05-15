//
//  StoryPopViewController.swift
//  Hebat
//
//  Created by mohamed hashem on 23/11/2020.
//  Copyright © 2020 mohamed hashem.  All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import RxSwift
import PencilKit
import QCropper

let defaultStickerWidthHeight = CGFloat(54.0)
let defaultFontSize = CGFloat(38.0)
let minimumOffsetForSwipeUp = CGFloat(100.0)

struct FilterModel {
    
}
class StoryViewController: UIViewController, UIGestureRecognizerDelegate, StickerPickerDelegate, TextEntryDelegate, UIPopoverPresentationControllerDelegate, PKCanvasViewDelegate, PKToolPickerObserver {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageBackGround: UIImageView!
    @IBOutlet weak var viewScreenShoutImage: UIView!
    @IBOutlet weak var takeImage: UIButton!
    @IBOutlet weak var filterAndBackGroundCollectionView: UICollectionView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var saveItemButton: UIButton!
    @IBOutlet weak var textItemButton: UIButton!
    @IBOutlet weak var emojItemButton: UIButton!
    @IBOutlet weak var colorItemButton: UIButton!
    @IBOutlet weak var doneItemButton: UIButton!
    @IBOutlet weak var cropItemButton: UIButton!
    @IBOutlet weak var tageButton: UIButton!
    @IBOutlet weak var cropView: UIView!
    @IBOutlet weak var shareCount: UILabel!
    @IBOutlet weak var TrashView: UIView!
    
    var tableDataNew: [FollowingModel.FollowersAndFollowingModel] = []
    var toolPicker: PKToolPicker!
    static let canvasOverscrollHeight: CGFloat = 500
    var drawingIndex: Int = 0
    var hasModifiedDrawing = false
    
    var loadCollectionView = false
    var activeSticker: Sticker?
    var allStickers: [Sticker] = []
    var waitingToExposeStickerPicker = false
    var currentImageBackGround: UIImage?
    var doCorpImage: Bool = false
    var changeBackGroundColor: Bool = false
    var originalImage: UIImage = UIImage()
    let disposed = DisposeBag()
    var currentIndex: IndexPath?
    var cellColor = Array(repeating: false, count: 15)
 
    let tableView = UITableView()
    let popoverViewController = UIViewController()
    var resultSearchController = UISearchController()
    var friendsAre: FollowingModel?
    var IDS: [String: Int]?
    var counterShared = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.alwaysBounceVertical = true
        canvasView.delegate = self
        // Set up the tool picker
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            // Set up the tool picker, using the window of our parent because our view has not
            // been added to a window yet.
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar

            return controller
        })()
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        updateLayout(for: toolPicker)
        canvasView.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.window?.windowScene?.screenshotService?.delegate = nil
    }
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
    }
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    func updateLayout(for toolPicker: PKToolPicker) {
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AllFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "AllFriendTableViewCell")
        loadUserFollowing()
        tableView.reloadData()
        
        if imageBackGround.image != nil {
            originalImage = imageBackGround.image!
        } else {
            originalImage = #imageLiteral(resourceName: "Artboard 1")
        }

        imageBackGround.isUserInteractionEnabled = true

        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longImage(sender:)))
        longGesture.minimumPressDuration = 1
        longGesture.numberOfTouchesRequired = 1

        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self

        filterAndBackGroundCollectionView.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadCollectionView = true
        filterAndBackGroundCollectionView.reloadData()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        allStickers = []
        self.removeFromParent()
    }

    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }

    @objc func longImage(sender: UILongPressGestureRecognizer) {
        self.activeSticker = self.findSticker(point: sender.location(in: self.viewScreenShoutImage))
        if self.activeSticker != nil {
            self.activeSticker?.isHidden = true
        } else {
            waitingToExposeStickerPicker = true
        }
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
        if imageBackGround.image != nil {
            showPicker()
               
            let cropper = CropperViewController(originalImage: imageBackGround.image!)
             cropper.delegate = self
            self.present(cropper, animated: true, completion: nil)
        }
    }

    @IBAction func doneCropImage(_ sender: UIButton) {
        doneItemButton.isHidden = true
        shareCount.isHidden = false
        cropItemButton.isHidden = false
        saveItemButton.isHidden = false
        textItemButton.isHidden = false
        emojItemButton.isHidden = false
        colorItemButton.isHidden = false
        tageButton.isHidden = false
        takeImage.isHidden = false
    }

    @IBAction func changeImageNow(_ sender: Any) {
        if canvasView.isFirstResponder{
            canvasView.resignFirstResponder()
            canvasView.isUserInteractionEnabled = false
        } else{
            canvasView.becomeFirstResponder()
            canvasView.isUserInteractionEnabled = true
        }
    }
    
    func showPicker() {
        canvasView.resignFirstResponder()
        canvasView.isUserInteractionEnabled = false
    }

    @IBAction func openImageLibrary(_ sender: UIButton) {
        showPicker()
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

    @IBAction func openTextEditor(_ sender: Any) {
        showPicker()
        doCorpImage = false

        let textEditor = self.storyboard?.instantiateViewController(withIdentifier: "TextEntry") as! TextEntryViewController
        textEditor.modalPresentationStyle = .pageSheet
        textEditor.delegate = self
        self.present(textEditor, animated: true, completion: nil)
    }
    
    @IBAction func openStickerPicker(_ sender: Any) {
        showPicker()
        doCorpImage = false

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StickerPicker") as! StickerPickerViewController
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveImageStory(_ sender: UIButton) {
        let image = self.viewScreenShoutImage.takeScreenshot()
        guard let imageStory = image  else {
            PopUpAlert.showErrorToastWith(message: "please add an image before add story.".localized )
            return
        }

        var currentIDS: [Int] = []
        IDS?.forEach({ key, value in
            currentIDS.append(value)
        })

        PKHUDIndicator.showProgressView()
        HebatEndPoints.shared
            .provider.rx
            .request(.addStory(newStoryMultimedia: [imageStory], IDS: currentIDS))
            .filterSuccessfulStatusCodes()
            .timeout(.seconds(300), scheduler: MainScheduler.instance)
            .retry(2)
            .map(NewStoryModel.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }

                PKHUDIndicator.hideBySuccessFlash()
                self.dismiss(animated: true, completion: {
                    NotificationCenter
                        .default
                        .post(name: NSNotification.Name(rawValue: "SavePost"),
                              object: nil,
                              userInfo: ["storyId" : response.story_id ?? 0, "user": response.user])
                })
            }) { error in
                PKHUDIndicator.hideByErrorFlash()
                PopUpAlert.showErrorToastWith(error)
            }.disposed(by: disposed)
    }

    // For placing stickers
    @IBAction func didPanOnStory(_ sender: Any) {
        let recognizer = sender as! UIPanGestureRecognizer
        
        if recognizer.state == .began {
            self.activeSticker = self.findSticker(point: recognizer.location(in: self.viewScreenShoutImage))
            if let sticker = self.activeSticker {
                self.viewScreenShoutImage.bringSubviewToFront(sticker)
            } else {
                waitingToExposeStickerPicker = true
            }
        } else if recognizer.state == .changed {
            let translation = recognizer.translation(in: self.viewScreenShoutImage)
            if let sticker = self.activeSticker {
                sticker.translation = translation
                TrashView.isHidden = false
                if sticker.frame.minX < CGFloat(80), sticker.frame.minY < CGFloat(175) {
                    UIView.animate(withDuration: 0.4) { [weak self] in
                        self?.TrashView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    }
                }
                if sticker.frame.minX < CGFloat(33), sticker.frame.minY < CGFloat(125) {
                    self.activeSticker?.isHidden = true
                }
            } else {
                if waitingToExposeStickerPicker {
                    if abs(translation.y) > abs(translation.x)
                        && translation.y < (0.0 - minimumOffsetForSwipeUp) {
                    }
                }
            }
        } else if recognizer.state == .ended {
            if let sticker = self.activeSticker {
                if sticker.frame.minX < CGFloat(100), sticker.frame.minY < CGFloat(195) {
                    UIView.animate(withDuration: 0.4) {
                        sticker.transform = CGAffineTransform(translationX: -50, y: -50)
                        sticker.isHidden = true
                    } completion: { [weak self] _ in
                        self?.TrashView.isHidden = true
                    }
                } else {
                    sticker.saveTranslation()
                    UIView.animate(withDuration: 0.4) {
                        self.TrashView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    } completion: { [weak self] _ in
                        self?.TrashView.isHidden = true
                    }
                }
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
        navigationController?.popViewController(animated: true)
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
    
    @IBAction func touchToTage(_ sender: UIButton) {
        popoverViewController.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        popoverViewController.preferredContentSize =  CGSize(width: 200, height: 300)
        popoverViewController.modalPresentationStyle = .popover

        tableView.frame = CGRect(
            x: popoverViewController.view.bounds.origin.x,
            y: popoverViewController.view.bounds.origin.y,
            width: 200,
            height: 300)

        popoverViewController.view.addSubview(tableView)
        
        let popoverController = popoverViewController.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self
        popoverController?.sourceView = sender
        popoverController?.barButtonItem = navigationItem.rightBarButtonItem
        present(popoverViewController, animated: true, completion: nil)
    }
}

//MARK:- camera extension
extension StoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let originalImage: UIImage? = info[.originalImage] as? UIImage
        let editedImage: UIImage? = info[.editedImage] as? UIImage

        if let editImage = editedImage {
            imageBackGround.image = editImage
            self.originalImage = editImage
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = originalImage {
            imageBackGround.image = originalImage
            self.originalImage = originalImage
            picker.dismiss(animated: true, completion: nil)
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - View Font
extension UIFont {
    static func systemFontItalic(size fontSize: CGFloat = 17.0, fontWeight: UIFont.Weight = .regular) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: fontSize)
    }
}


//MARK:-
extension StoryViewController: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty, let friends = friendsAre?.following_data {
            let array = friends.filter {
                ($0.user.name ?? "").lowercased().contains(text.lowercased()) || ($0.user.name ?? "").lowercased().contains(text.lowercased())
            }
            tableDataNew = array
        } else {
            tableDataNew.removeAll()
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  !tableDataNew.isEmpty, resultSearchController.isActive {
            return tableDataNew.count
        } else {
            return friendsAre?.following_data.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllFriendTableViewCell", for: indexPath) as? AllFriendTableViewCell else {
            fatalError()
        }
        if !tableDataNew.isEmpty, resultSearchController.isActive {
            cell.nameLabel.text = tableDataNew[indexPath.row].user.name ?? ""
            let image = tableDataNew[indexPath.row].user.path
            cell.userImage.loadImage(urlString: image ?? "", asUser: true)
            cell.talentedLabel.text = tableDataNew[indexPath.row].user.talent ?? ""
          } else {
              cell.nameLabel.text = friendsAre?.following_data[indexPath.row].user.name ?? ""
              let image = friendsAre?.following_data[indexPath.row].user.path
              cell.userImage.loadImage(urlString: image ?? "", asUser: true)
              cell.talentedLabel.text = friendsAre?.following_data[indexPath.row].user.talent ?? ""
          }
       
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if IDS != nil, IDS!.count > 0 {
            if !tableDataNew.isEmpty, resultSearchController.isActive {
                IDS?[(tableDataNew[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "")] = tableDataNew[indexPath.row].user.id ?? 0
              } else {
                  IDS?[(friendsAre?.following_data[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "")] = friendsAre?.following_data[indexPath.row].user.id ?? 0
              }
            
        } else if IDS != nil, IDS!.isEmpty {
            if !tableDataNew.isEmpty, resultSearchController.isActive {
                IDS?[(tableDataNew[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "")] = tableDataNew[indexPath.row].user.id ?? 0
              } else {
                  IDS?[(friendsAre?.following_data[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "")] = friendsAre?.following_data[indexPath.row].user.id ?? 0
              }
        } else {
            if !tableDataNew.isEmpty, resultSearchController.isActive {
                IDS = [(tableDataNew[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "") : tableDataNew[indexPath.row].user.id ?? 0]
              } else {
                  IDS = [(friendsAre?.following_data[indexPath.row].user.name ?? "").replacingOccurrences(of: " ", with: "") : friendsAre?.following_data[indexPath.row].user.id ?? 0]
              }
        }
        counterShared = IDS?.count ?? 0
        shareCount.text = "\(counterShared)"
        popoverViewController.dismiss(animated: true, completion: nil)
    }
    
    func loadUserFollowing() {
        HebatEndPoints.shared
            .provider.rx
            .request(.getFollowings)
            .filterSuccessfulStatusCodes()
            .timeout(.seconds(120), scheduler: MainScheduler.instance)
            .retry(2)
            .map(FollowingModel.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { response in
                self.friendsAre = response

            }) { error in
                PopUpAlert.showErrorToastWith(error)

            }.disposed(by: disposed)
    }
}
