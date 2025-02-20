import SwiftUI
import PhotosUI

struct LibraryButton: View {
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundStyle(Color.white.gradient)
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        LibraryButton(selectedItem: .constant(nil))
    }
}
