import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    var label: String = "Select Photo"

    var body: some View {
        VStack(spacing: 12) {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            self.selectedImage = nil
                            self.pickerItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        }
                        .padding(8)
                    }
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text(selectedImage == nil ? label : "Change Photo")
                }
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.pmPrimary.opacity(0.12))
                .foregroundStyle(Color.pmPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onChange(of: pickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
}
