//
//  ContentView.swift
//  Instafilter
//
//  Created by Mathieu Dubart on 06/09/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var chosenImage: UIImage?
    @State private var showingImagePicker = false
    @State private var processedImage: UIImage?
    
    // ----- préciser le type CIFilter pour qu'on puisse remplacer le filtre.
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack{
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    if image == nil {
                        Text("Tap to select a picture")
                            .foregroundStyle(Color.white)
                            .font(.headline)
                    }
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    
                    Slider(value: $filterIntensity, in: 0...1)
                        .onChange(of: filterIntensity) {
                            applyProcessing()
                        }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(image != nil ? false : true)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: chosenImage) {
                loadImage()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $chosenImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Crystallize"){ setFilter(CIFilter.crystallize()) }
                Button("Edges"){ setFilter(CIFilter.edges()) }
                Button("Gaussian Blur"){ setFilter(CIFilter.gaussianBlur()) }
                Button("Gloom"){ setFilter(CIFilter.gloom()) }
                Button("Pixellate"){ setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone"){ setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask"){ setFilter(CIFilter.unsharpMask()) }
                Button("Vignette"){ setFilter(CIFilter.vignette()) }
                Button("Xray"){ setFilter(CIFilter.xRay()) }
                Button("Thermal"){ setFilter(CIFilter.thermal()) }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    func loadImage() {
        guard let chosenImage = chosenImage else { return }
        
        let beginImage = CIImage(image: chosenImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            processedImage = uiImage
            image = Image(uiImage: uiImage)
        }
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Something went wrong: \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

#Preview {
    ContentView()
}
