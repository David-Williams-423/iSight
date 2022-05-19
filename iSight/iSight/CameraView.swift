//
//  CameraView.swift
//  iSight
//
//  Created by David Williams on 5/9/22.
//

import AVFoundation
import UIKit
import SwiftUI
import Vision

final class CameraView: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {

    
    var viewModel: CameraService

    init(viewModel: CameraService) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let previewLayer = viewModel.previewLayer!
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)
    }


    @objc func rotated() {

        let pixelWidth = UIScreen.main.nativeBounds.width
        let pixelHeight = UIScreen.main.nativeBounds.height
        let pointWidth = pixelWidth / UIScreen.main.nativeScale
        let pointHeight = pixelHeight / UIScreen.main.nativeScale

        let orientation = transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)

        viewModel.previewLayer?.connection?.videoOrientation = orientation

        if orientation == .portrait {
            viewModel.previewLayer.frame = CGRect(x: 0, y: 0, width: pointWidth, height: pointHeight)
        }

        if orientation == .landscapeLeft || orientation == .landscapeRight {
            viewModel.previewLayer.frame = CGRect(x: 0, y: 0, width: pointHeight, height: pointWidth)
        }

        viewModel.previewLayer.videoGravity = .resizeAspectFill
    }


    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }

    func failed() {
        let ac = UIAlertController(title: "Camera not supported.", message: "Your device does not support a camera. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}

struct CameraViewUI: UIViewControllerRepresentable {

    @ObservedObject var viewModel = CameraService()

    func makeUIViewController(context: Context) -> CameraView {
        return CameraView(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: CameraView, context: Context) {
        
    }

}
