import SwiftUI

struct ResultView: View {
    let result: String

    var body: some View {
        VStack(spacing: 16) {
            // Result text display
            Text(result)
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.bottom, 32)
    }
}
