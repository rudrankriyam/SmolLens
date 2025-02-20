import SwiftUI 

struct CameraControlsView: View {
    var onCapture: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: onCapture) {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 65, height: 65)
                        )
                }
                
                Spacer()
            }
            .padding(.bottom, 30)
        }
    }
}
