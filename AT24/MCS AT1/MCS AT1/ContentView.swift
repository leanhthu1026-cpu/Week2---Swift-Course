import SwiftUI

// MARK: - Màn hình chính
struct ContentView: View {
    // Danh sách sinh viên khởi tạo mặc định
    @State private var students: [Student] = [
        Student(id: "S001", name: "An", gpa: 8.5),
        Student(id: "S002", name: "Binh", gpa: 9.0),
        Student(id: "S003", name: "Chi", gpa: 7.8),
        Student(id: "S004", name: "Duy", gpa: 9.2),
        Student(id: "S005", name: "Lan", gpa: 8.0)
    ]
    
    // Quản lý tìm kiếm, lọc và sắp xếp
    @State private var searchText: String = ""
    @State private var onlyHighAchievers: Bool = false
    @State private var isSortedDescending: Bool = false
    
    // Quản lý hiển thị Sheet thêm/sửa và Alert thủ khoa
    @State private var showingAddSheet: Bool = false
    @State private var showingTopStudentAlert: Bool = false
    @State private var topStudentMessage: String = ""
    @State private var studentToEdit: Student? = nil

    // Danh sách sinh viên sau khi áp dụng tìm kiếm, lọc GPA và sắp xếp
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
            ZStack {
                // Lớp lót màu trắng
                Color.white.ignoresSafeArea()
                
                // Ảnh nền "pic" với độ mờ hiển thị 40%
                Image("pic")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.4)

                VStack(spacing: 14) {
                    // Header: Biểu tượng nhóm người, tiêu đề ứng dụng và slogan
                    VStack(spacing: 6) {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.pink)

                        Text("Student Manager")
                            .font(.title2.bold())
                            .fontWeight(.bold)
                            .foregroundColor(.pink)

                        Text("A better class, a brighter tomorrow")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)

                    // Thanh tìm kiếm sinh viên theo tên
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)

                        TextField("Search student by name...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(15)
                    .background(Color.pink.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Thanh công cụ: Lọc GPA ≥ 8.0, Sắp xếp GPA và Xem sinh viên Top GPA
                    HStack(spacing: 10) {
                        // Nút lọc sinh viên có GPA ≥ 8.0
                        Button(action: { onlyHighAchievers.toggle() }) {
                            Text("GPA ≥ 8.0")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(onlyHighAchievers ? Color.yellow.opacity(0.4) : Color.green.opacity(0.85))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(onlyHighAchievers ? Color.blue : Color.white.opacity(0), lineWidth: 1)
                                )
                                .foregroundColor(onlyHighAchievers ? .blue : .primary)
                        }
                        .buttonStyle(.plain)

                        // Nút sắp xếp danh sách theo GPA giảm dần
                        Button(action: { isSortedDescending.toggle() }) {
                            Label(
                                isSortedDescending ? "Sorted GPA ↓" : "Sort GPA",
                                systemImage: "arrow.up.arrow.down"
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSortedDescending ? Color.yellow.opacity(0.4) : Color.green.opacity(0.85))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSortedDescending ? Color.blue : Color.gray.opacity(0), lineWidth: 1)
                            )
                            .foregroundColor(isSortedDescending ? .blue : .primary)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        // Nút hiển thị thông tin thủ khoa GPA cao nhất
                        Button(action: checkTopStudent) {
                            Label("Top GPA", systemImage: "crown.fill")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.yellow)
                    }
                    .padding(.horizontal)

                    // Danh sách hiển thị từng thẻ sinh viên riêng lẻ
                    List {
                        ForEach(displayStudents) { student in
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.blue.opacity(0.8))

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

                                // Nút mở Sheet chỉnh sửa thông tin sinh viên
                                Button(action: { studentToEdit = student }) {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            // Thẻ sinh viên bo tròn góc 20, nền trắng 90% và có bóng đổ
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                            )
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteStudent)
                    }
                    .padding(.top, 30)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                    // Cụm nút mở Sheet thêm mới sinh viên và hiển thị tổng số lượng
                    VStack(spacing: 8) {
                        Button(action: { showingAddSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Student")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        Text("Total students: \(displayStudents.count) (All: \(students.count))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 70)
                }
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

    // Xóa sinh viên qua thao tác vuốt (swipe-to-delete)
    private func deleteStudent(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { displayStudents[$0].id }
        students.removeAll { itemsToDelete.contains($0.id) }
    }

    // Tìm và hiển thị sinh viên có điểm GPA cao nhất
    private func checkTopStudent() {
        if let top = students.max(by: { $0.gpa < $1.gpa }) {
            topStudentMessage = "\(top.name) (ID: \(top.id))\nGPA: \(top.gpa)"
        } else {
            topStudentMessage = "The student list is empty."
        }
        showingTopStudentAlert = true
    }
}

// MARK: - Sheet Thêm sinh viên mới
struct AddStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (Student) -> Void

    @State private var id: String = ""
    @State private var name: String = ""
    @State private var gpa: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Lớp lót nền và ảnh nền "pica"
                Color.white.ignoresSafeArea()

                Image("pica")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(1)

                // Form nhập thông tin sinh viên mới
                Form {
                    Section {
                        TextField("ID (e.g. S006)", text: $id)
                        TextField("Full Name", text: $name)
                        TextField("GPA (0.0 - 10.0)", text: $gpa)
                    } header: {
                        Text("Student Details")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    }
                    .listRowBackground(Color.white.opacity(0.9))
                    .padding(10)

                    // Hiển thị thông báo lỗi nếu nhập liệu không hợp lệ
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Student")
            .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Sheet Chỉnh sửa thông tin sinh viên
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
            ZStack {
                // Lớp lót nền và ảnh nền "pica"
                Color.white.ignoresSafeArea()

                Image("pica")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(1)

                // Form chỉnh sửa tên và điểm GPA
                Form {
                    Section {
                        TextField("Name", text: $name)
                        TextField("GPA (0.0 - 10.0)", text: $gpa)
                    } header: {
                        Text("Student ID: \(student.id)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    }
                    .listRowBackground(Color.white.opacity(0.88))

                    // Hiển thị thông báo lỗi nếu nhập liệu không hợp lệ
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(10)
            }
            .navigationTitle("Edit Student")
            .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
