import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhoto: Image?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Photo.timestamp, order: .reverse) private var savedPhotos: [Photo]
    
    var body: some View {
        VStack {
            if let image = selectedPhoto {
                saveConfirmation(image)
            } else {
                photoPicker
            }
            photoList
        }
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        withAnimation {
                            selectedPhoto = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder func saveConfirmation(_ image: Image) -> some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            Text("Is this the photo you want?")
            Button {
                Task {
                    if let selectedItem = selectedItem {
                        await savePhotoFromPickerItem(selectedItem)
                        withAnimation {
                            self.selectedItem = nil
                            self.selectedPhoto = nil
                        }
                    }
                }
            } label: {
                Label("Add to Basket", systemImage: "square.and.arrow.down")
            }
        }
    }
    
    @ViewBuilder var photoPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            VStack {
                ZStack {
                    Circle()
                        .foregroundColor(.blue)
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundStyle(.white)
                        .scaledToFit()
                        .padding(24)
                }
                .frame(width: 120, height: 120)
                Text("Find a Photo")
            }
        }
    }
    
    @ViewBuilder var photoList: some View {
        List {
            ForEach(savedPhotos, id: \.self) { photo in
                if let image = UIImage(data: photo.photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width:300, height:300)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                Task {
                                    await deleteImage(photo)
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                }
            }
        }
    }
    
    private func savePhotoFromPickerItem(_ item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self) {
            let savedPhoto = Photo(timestamp: .now, photoData: data)
            modelContext.insert(savedPhoto)
        }
    }
    
    private func deleteImage(_ photo: Photo) async {
        modelContext.delete(photo)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Photo.self, inMemory: true)
}
