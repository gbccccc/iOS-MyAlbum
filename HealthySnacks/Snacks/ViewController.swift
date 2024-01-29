/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.



import UIKit
import CoreML
import Vision

private let reuseIdentifier = "Cell"

class ViewController: UIViewController {
    
    var images: [TaggedImage] = []
    @IBOutlet var verticalStackView: UIStackView!
    var horizontalStackViews: [UIStackView] = []
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var photoLibraryButton: UIButton!
    @IBOutlet var resultsView: UIView!
    @IBOutlet var resultsLabel: UILabel!
    @IBOutlet var resultsConstraint: NSLayoutConstraint!

    var firstTime = true

    lazy var classificationRequest: VNCoreMLRequest = {
        do {
//          TODO: load mlmodel
            let classifier = try SnackClassifier(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
        
//        NOTICE:*****VERY IMPORTANT*****
//        You see Could not create inference context error because Neural Engine is not supported in the simulator.
//
//        You can use CPU only for VNRequest in simulator by uncomment the following lines.
            #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            #endif
        
            return request
        
        
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addButton(image: UIImage) {
        if images.count % 3 == 0 {
            let horizontalStackView = UIStackView()
            verticalStackView.addArrangedSubview(horizontalStackView)
            horizontalStackView.spacing = 3
            horizontalStackView.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor).isActive = true
            horizontalStackViews.append(horizontalStackView)
        }
        
        let horizontalStackView = horizontalStackViews.last!
        let button = UIButton()
        horizontalStackView.addArrangedSubview(button)
        let buttonHeight = (verticalStackView.frame.width - 6) / 3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(image, for: .normal)
    }
    
    @IBAction func takePicture() {
        presentPhotoPicker(sourceType: .camera)
    }

    @IBAction func choosePhoto() {
        presentPhotoPicker(sourceType: .photoLibrary)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
//        hideResultsView()
    }

//    func showResultsView(delay: TimeInterval = 0.1) {
//        resultsConstraint.constant = 100
//        view.layoutIfNeeded()
//
//        UIView.animate(withDuration: 0.5,
//                       delay: delay,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.6,
//                       options: .beginFromCurrentState,
//                       animations: {
//            self.resultsView.alpha = 1
//            self.resultsConstraint.constant = -10
//            self.view.layoutIfNeeded()
//        },
//                       completion: nil)
//    }
//
//    func hideResultsView() {
//        UIView.animate(withDuration: 0.3) {
//            self.resultsView.alpha = 0
//        }
//    }

    func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage")
            return
        }

        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }

    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
//        ******Explain the following code in your report******
            if let results = request.results as? [VNClassificationObservation] {
                if results.isEmpty {
                    self.resultsLabel.text = "nothing found"
                } else if results[0].confidence < 0.1 {
                    self.resultsLabel.text = "not sure"
                } else {
                    self.resultsLabel.text = String(format: "%@ %.1f%%", results[0].identifier, results[0].confidence * 100)
                }
            } else if let error = error {
                self.resultsLabel.text = "error: \(error.localizedDescription)"
            } else {
                self.resultsLabel.text = "???"
            }
//            self.showResultsView()
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[.originalImage] as! UIImage
        addButton(image: image)
        images.append(TaggedImage(image: image))
        
//        classify(image: image)
    }
}
