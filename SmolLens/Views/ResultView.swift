import SwiftUI

struct ResultView: View {
    let result: String

    var body: some View {
        VStack {
            Text(result)
                .padding()
                .background(.ultraThickMaterial)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.top, 32)

            Spacer()
        }
    }
}
