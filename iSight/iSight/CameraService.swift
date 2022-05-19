//
//  CameraService.swift
//  iSight
//
//  Created by David Williams on 5/15/22.
//

import Foundation
import SwiftUI
import AVFoundation
import Vision

struct Analysis {
    var description: String = "Unsure"
    var confidence: Double = 0.0
}

class CameraService: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var analysis = Analysis()
    var frameCounter = 14

    var previewLayer: AVCaptureVideoPreviewLayer!

    override init() {
        super.init()

        let session = AVCaptureSession()
        session.beginConfiguration()

        let videoDevice = AVCaptureDevice.default(for: .video)
        guard videoDevice != nil,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
              session.canAddInput(videoDeviceInput) else {
            return
        }
        session.addInput(videoDeviceInput)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main) // has to be the main queue to update the view
        session.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: session)

        session.commitConfiguration()

        session.startRunning()

    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        frameCounter += 1

        if frameCounter == 15 {

            frameCounter = 0

            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

            guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
            let request = VNCoreMLRequest(model: model) { finishedReq, err in

                guard let results = finishedReq.results as? [VNClassificationObservation] else {return}

                guard let firstObservation = results.first else {return}

                var description = ""

                if firstObservation.confidence < 0.3 {
                    description = "Unsure"
                } else {
                    description = firstObservation.identifier.split(separator: ",")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                }

                self.analysis = Analysis(description: description, confidence: Double(firstObservation.confidence))
            }

            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

            print(self.analysis)

        }
    }
}


