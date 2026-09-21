import SwiftUI

struct AddComputerView: View {
    @Binding var computers: [Computer]
    @Environment(\.dismiss) private var dismiss

    @State private var computerName: String = ""
    @State private var location: String = "Lab A"
    @State private var isAvailable: Bool = true
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Image("pice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                TextField("Enter computer name (e.g. PC06)", text: $computerName)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)

                TextField("Enter location (e.g. Lab A)", text: $location)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)

                Toggle("Available", isOn: $isAvailable)
                    .padding()
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(8)

                Button {
                    addComputer()
                } label: {
                    Text("Add")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 50)
                        .background(Color.purple.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Computer")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func addComputer() {
        let trimmedName = computerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a computer name."
            showAlert = true
            return
        }

        if computers.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            alertMessage = "\(trimmedName) already exists!"
            showAlert = true
            return
        }

        let newPC = Computer(name: trimmedName, location: location, isAvailable: isAvailable)
        computers.append(newPC)
        computerName = ""
        dismiss()
    }
}
