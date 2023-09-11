//
//  ImagePIcker.swift
//  Instafilter
//
//  Created by Mathieu Dubart on 11/09/2023.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    // ----- UIImage parcequ'on a besoin que l'image ai la donnée brute pour chaque pixel pour ensuite pouvoir les modifier avec CoreImage
    @Binding var image: UIImage?
    
    // ----- On rajoute une nested class (obligatoirement une classe, mais pas obligatoirement nested (elle peut être en dehors))
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {return}
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    // ----- If you you can load the object and you load it, typecast as? attempt a gentle conversion of photo to UIImage (if he can't convert, returns nil)
                    // ------ because it could be any type of file (live photo, photo, movie...)
                    self.parent.image = image as? UIImage
                }
            }
            
        }
    }
    
    
    
    func makeUIViewController(context: Context)-> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        // ----- alerte Swift UI quand quelque chose se passe (photo choisie, cancel, etc..) et lui dit d'utiliser ce coordinateur comme delegate pour notre PhPickerView
        picker.delegate = context.coordinator
        return picker
    }
        
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    // ----- Swift UI appelle de lui-même la fonction lorsqu'il instancie ImagePicker et sait quel paramètre lui donner
    func makeCoordinator() -> Coordinator {
        // ----- ici on passe self en paramètre notre struct ImagePicker avec le binding comme ça on peut modifier le binding depuis la classe.
        Coordinator(self)
    }
}
