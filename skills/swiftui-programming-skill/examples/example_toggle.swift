import SwiftUI

struct ToggleView: View {
    @State private var isOn = false
    
    var body: some View {
        ZStack {
            (isOn ? Color.blue : Color.gray)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(isOn ? "Light Mode" : "Dark Mode")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
                Toggle("Toggle Mode", isOn: $isOn)
                    .padding()
                    .toggleStyle(SwitchToggleStyle(tint: .white))
            }
        }
    }
}