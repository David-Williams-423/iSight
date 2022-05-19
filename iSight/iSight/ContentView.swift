//
//  ContentView.swift
//  iSight
//
//  Created by David Williams on 4/27/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {

    @StateObject var vm = CameraService()

    let voice = AVSpeechSynthesisVoice(language: "English")


    var body: some View {

        ZStack {

            CameraViewUI(viewModel: vm)
                .ignoresSafeArea()

            VStack {

                Spacer()

                ZStack {
                    Rectangle()
                        .frame(height: 75)
                        .background(.regularMaterial)
                        .cornerRadius(20)
                        .padding()

                    HStack {

                        Text(vm.analysis.description)
                            .font(.largeTitle)
                        
                        Spacer()

                        Text(String(Int(round(vm.analysis.confidence * 100))) + "%")

                    }
                    .padding(40)
                }

            }

        }
        .onTapGesture {
            let utterance = AVSpeechUtterance(string: vm.analysis.description)
            utterance.voice = voice
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

