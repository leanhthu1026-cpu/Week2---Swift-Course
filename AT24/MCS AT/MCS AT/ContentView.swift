import SwiftUI

struct ContentView: View {
    // Danh sách sinh viên mẫu ban đầu
    @State private var students: [Student] = [
        Student(id: "S001", name: "An", gpa: 8.5),
        Student(id: "S002", name: "Binh", gpa: 9.0),
        Student(id: "S003", name: "Chi", gpa: 7.8),
        Student(id: "S004", name: "Duy", gpa: 9.2),
        Student(id: "S005", name: "Lan", gpa: 8.0)
    ]
    
    // Quản lý tìm kiếm & lọc
    @State private var searchText: String = ""
    @State private var onlyHighAchievers: Bool = false
    @State private var isSortedDescending: Bool = false
    
    // State hiển thị Alert / Modal
    @State private var showingAddSheet: Bool = false
    @State private var showingTopStudentAlert: Bool = false
    @State private var topStudentMessage: String = ""
    @State private var studentToEdit: Student? = nil

    // Danh sách sau khi lọc và sắp xếp
    var displayStudents: [Student] {
        var list = students
        
        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        
        if onlyHighAchievers {
            list = list.filter { $0.gpa >= 8.0 }
        }
        
        if isSortedDescending {
            list.sort { $0.gpa > $1.gpa }
        }
        
        return list
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                // Header (Icon + Title + Slogan)
                VStack(spacing: 6) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.blue)

                    Text("Student Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    Text("A better class, a brighter tomorrow")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 12)

                // Thanh tìm kiếm (Hỗ trợ chuẩn đa nền tảng)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search student by name...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.secondary.opacity(0.12)) // Tương thích cả macOS và iOS
                .cornerRadius(10)
                .padding(.horizontal)

                // Thanh công cụ Lọc & Sắp xếp
                HStack {
                    Toggle(isOn: $onlyHighAchievers) {
                        Text("GPA ≥ 8.0")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .toggleStyle(.button)
                    .tint(.blue)

                    Button(action: { isSortedDescending.toggle() }) {
                        Label(
                            isSortedDescending ? "Sorted GPA ↓" : "Sort GPA",
                            systemImage: "arrow.up.arrow.down"
                        )
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(isSortedDescending ? .blue : .secondary)

                    Spacer()

                    Button(action: checkTopStudent) {
                        Label("Top GPA", systemImage: "crown.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding(.horizontal)

                // Danh sách sinh viên
                List {
                    ForEach(displayStudents) { student in
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.blue.opacity(0.7))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                HStack(spacing: 8) {
                                    Text("ID: \(student.id)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "GPA: %.1f", student.gpa))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Nút chỉnh sửa
                            Button(action: { studentToEdit = student }) {
                                Image(systemName: "pencil.circle")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteStudent)
                }
                #if os(iOS)
                .listStyle(.plain)
                #endif

                // Nút thêm sinh viên và đếm số lượng
                VStack(spacing: 8) {
                    Button(action: { showingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Student")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    Text("Total students: \(displayStudents.count) (All: \(students.count))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 12)
            }
            .frame(minWidth: 420, minHeight: 560)
            .sheet(isPresented: $showingAddSheet) {
                AddStudentSheet { newStudent in
                    students.append(newStudent)
                }
            }
            .sheet(item: $studentToEdit) { student in
                EditStudentSheet(student: student) { updatedStudent in
                    if let index = students.firstIndex(where: { $0.id == updatedStudent.id }) {
                        students[index] = updatedStudent
                    }
                }
            }
            .alert("Highest GPA Student", isPresented: $showingTopStudentAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(topStudentMessage)
            }
        }
    }

    private func deleteStudent(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { displayStudents[$0].id }
        students.removeAll { itemsToDelete.contains($0.id) }
    }

    private func checkTopStudent() {
        if let top = students.max(by: { $0.gpa < $1.gpa }) {
            topStudentMessage = "\(top.name) (ID: \(top.id))\nGPA: \(top.gpa)"
        } else {
            topStudentMessage = "The student list is empty."
        }
        showingTopStudentAlert = true
    }
}

// MARK: - Sheet Thêm sinh viên
struct AddStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (Student) -> Void

    @State private var id: String = ""
    @State private var name: String = ""
    @State private var gpa: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Student Details") {
                    TextField("ID (e.g. S006)", text: $id)
                    TextField("Full Name", text: $name)
                    TextField("GPA (0.0 - 10.0)", text: $gpa)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .frame(minWidth: 320, minHeight: 220)
            .navigationTitle("Add Student")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !id.trimmingCharacters(in: .whitespaces).isEmpty,
                              !name.trimmingCharacters(in: .whitespaces).isEmpty,
                              let gpaValue = Double(gpa), (0.0...10.0).contains(gpaValue) else {
                            errorMessage = "Please enter a valid ID, Name, and GPA (0 - 10)."
                            return
                        }
                        onAdd(Student(id: id, name: name, gpa: gpaValue))
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Sheet Sửa thông tin sinh viên
struct EditStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let student: Student
    var onSave: (Student) -> Void

    @State private var name: String
    @State private var gpa: String
    @State private var errorMessage: String = ""

    init(student: Student, onSave: @escaping (Student) -> Void) {
        self.student = student
        self.onSave = onSave
        _name = State(initialValue: student.name)
        _gpa = State(initialValue: String(student.gpa))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Student ID: \(student.id)") {
                    TextField("Name", text: $name)
                    TextField("GPA", text: $gpa)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .frame(minWidth: 320, minHeight: 200)
            .navigationTitle("Edit Student")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
                              let gpaValue = Double(gpa), (0.0...10.0).contains(gpaValue) else {
                            errorMessage = "Invalid name or GPA value."
                            return
                        }
                        onSave(Student(id: student.id, name: name, gpa: gpaValue))
                        dismiss()
                    }
                }
            }
        }
    }
}
