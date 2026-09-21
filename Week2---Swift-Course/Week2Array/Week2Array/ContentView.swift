import SwiftUI

// MARK: - Main ContentView (Tab Navigation giữa các màn hình)
struct ContentView: View {
    // Mảng dữ liệu dùng chung
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

    var body: some View {
        NavigationStack {
            ZStack {
                Image("picd")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Computer Lab")
                        .font(.title2).bold()
                        .foregroundColor(.white)

                    Text("Manage computers easily")
                        .font(.subheadline)
                        .foregroundColor(.white)

                    List {
                        ForEach(computers) { computer in
                            HStack {
                                Image(systemName: "desktopcomputer")
                                    .foregroundColor(.gray)

                                VStack(alignment: .leading) {
                                    Text(computer.name)
                                        .fontWeight(.medium)
                                    Text(computer.location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

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
                            .listRowBackground(Color.white.opacity(0.85))
                        }
                        .onDelete(perform: removeComputer)
                    }
                    .scrollContentBackground(.hidden)

                    // Điều hướng sang AddComputerView bằng NavigationLink
                    NavigationLink {
                        AddComputerView(computers: $computers)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add Computer")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 50)
                        .background(Color.pink.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Text("Total computers: \(computers.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
            }
            .navigationTitle("")
        }
    }

    func removeComputer(at offsets: IndexSet) {
        computers.remove(atOffsets: offsets)
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
                Image("picf")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
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

// MARK: - 4. Statistics View (Background: picg - Thiết kế chuẩn theo Slide)
struct StatisticsView: View {
    var computers: [Computer]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("picg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Biểu tượng đồ thị cam
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // Summary Card (Total count)
                    HStack(spacing: 16) {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text("Total Computers")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(computers.count)")
                                .font(.system(size: 28, weight: .bold))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.08))
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Tiêu đề Computer List
                    HStack {
                        Text("Computer List")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Bảng danh sách chi tiết (List of computers)
                    List(computers) { computer in
                        HStack {
                            Image(systemName: "desktopcomputer")
                                .foregroundColor(.gray)

                            VStack(alignment: .leading) {
                                Text(computer.name)
                                    .font(.headline)
                                Text(computer.location)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(computer.isAvailable ? Color.green : Color.red)
                                    .frame(width: 10, height: 10)

                                Text(computer.isAvailable ? "Available" : "In Use")
                                    .font(.subheadline)
                                    .foregroundColor(computer.isAvailable ? .green : .red)

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.85))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
