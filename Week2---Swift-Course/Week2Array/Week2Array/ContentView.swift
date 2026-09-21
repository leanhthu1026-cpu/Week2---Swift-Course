import SwiftUI

// MARK: - 1. Define the Computer Struct
struct Computer: Identifiable {
    let id = UUID()           // Mã định danh duy nhất
    var name: String          // Tên máy (vd: PC01)
    var location: String      // Vị trí (vd: Lab A)
    var isAvailable: Bool     // Trạng thái khả dụng
}

// MARK: - Main ContentView (Tab Navigation giữa các màn hình)
struct ContentView: View {
    // Dữ liệu mẫu khởi tạo bằng mảng [Computer]
    @State private var computers: [Computer] = [
        Computer(name: "PC01", location: "Lab A", isAvailable: true),
        Computer(name: "PC02", location: "Lab A", isAvailable: true),
        Computer(name: "PC03", location: "Lab B", isAvailable: false),
        Computer(name: "PC04", location: "Lab B", isAvailable: true),
        Computer(name: "PC05", location: "Lab C", isAvailable: true)
    ]

    var body: some View {
        TabView {
            HomeListView(computers: $computers)
                .tabItem {
                    Label("Home", systemImage: "desktopcomputer")
                }

            AddComputerView(computers: $computers)
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            CheckComputerView(computers: computers)
                .tabItem {
                    Label("Check", systemImage: "magnifyingglass")
                }

            StatisticsView(computers: computers)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

// MARK: - 1. Home / List View (Background: picd)
struct HomeListView: View {
    @Binding var computers: [Computer]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Hình nền picd
                Image("picd")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Header (Icon & Title)
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Computer Lab")
                        .font(.title2).bold()
                        .foregroundColor(.white)

                    Text("Manage computers easily")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    // List computers
                    List {
                        ForEach(computers) { computer in
                            HStack {
                                Image(systemName: "desktopcomputer")
                                    .foregroundColor(.yellow)

                                VStack(alignment: .leading) {
                                    Text(computer.name)
                                        .fontWeight(.medium)
                                    Text(computer.location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                // Status Badge & Chevron
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(computer.isAvailable ? Color.green : Color.red)
                                        .frame(width: 10, height: 10)

                                    Text(computer.isAvailable ? "Available" : "In Use")
                                        .foregroundColor(computer.isAvailable ? .green : .red)
                                        .font(.subheadline)

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.85)) // Giúp chữ dễ đọc trên nền ảnh
                        }
                        .onDelete(perform: removeComputer)
                    }
                    .scrollContentBackground(.hidden) // Ẩn nền xám mặc định của List để thấy ảnh nền

                    // Add Computer Button
                    Button {
                        showingAddSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add Computer")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Total count footer
                    Text("Total computers: \(computers.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $showingAddSheet) {
                AddComputerView(computers: $computers)
            }
        }
    }

    func removeComputer(at offsets: IndexSet) {
        computers.remove(atOffsets: offsets)
    }
}

// MARK: - 2. Add Computer View (Background: pice)
struct AddComputerView: View {
    @Binding var computers: [Computer]
    @Environment(\.dismiss) private var dismiss

    @State private var computerName: String = ""
    @State private var location: String = "Lab A"
    @State private var isAvailable: Bool = true
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Hình nền pice
                Image("pice")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
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
                            .background(Color.blue)
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

// MARK: - 3. Check Computer View (Background: picf)
struct CheckComputerView: View {
    var computers: [Computer]
    @State private var searchName: String = ""
    @State private var foundComputer: Computer? = nil
    @State private var hasSearched: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Hình nền picf
                Image("picf")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 24)

                    TextField("Enter computer name (e.g. PC03)", text: $searchName)
                        .padding(10)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button {
                        let trimmed = searchName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            foundComputer = computers.first(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame })
                            hasSearched = true
                        }
                    } label: {
                        Text("Check")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Badge thông báo kết quả
                    if hasSearched {
                        if let pc = foundComputer {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("\(pc.name) is in \(pc.location) (\(pc.isAvailable ? "Available" : "In Use"))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("\(searchName) is not in the lab!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Check Computer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 4. Statistics View (Background: picg)
struct StatisticsView: View {
    var computers: [Computer]

    var body: some View {
        NavigationStack {
            ZStack {
                // Hình nền picg
                Image("picg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Card: Total Computers
                    HStack(spacing: 20) {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Computers")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(computers.count)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Card: Computer List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Computer List")
                            .font(.headline)

                        if computers.isEmpty {
                            Text("No computers found.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(computers) { pc in
                                HStack {
                                    Text("•")
                                        .fontWeight(.bold)
                                    Text("\(pc.name) - \(pc.location)")
                                    Spacer()
                                    Text(pc.isAvailable ? "Available" : "In Use")
                                        .font(.caption)
                                        .foregroundColor(pc.isAvailable ? .green : .red)
                                }
                                .font(.body)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
