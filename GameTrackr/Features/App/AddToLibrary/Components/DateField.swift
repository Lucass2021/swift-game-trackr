import SwiftUI

struct DateField: View {
    @Binding var date: Date?
    var placeholder: String = "dd/mm/yyyy"

    @State private var showPicker = false
    @State private var draft = Date()

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    var body: some View {
        Button {
            draft = date ?? Date()
            showPicker = true
        } label: {
            HStack {
                Text(date.map { Self.formatter.string(from: $0) } ?? placeholder)
                    .font(.appBody(16))
                    .foregroundStyle(date == nil ? Color.appTextSecondary : Color.appTextPrimary)
                Spacer()
                AppIconView(icon: .calendar, size: 18)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .fieldBox()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                DatePicker("", selection: $draft, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.appPrimary)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(Color.appBackground)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Clear") {
                                date = nil
                                showPicker = false
                            }
                            .tint(Color.appTertiary)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                date = draft
                                showPicker = false
                            }
                            .tint(Color.appPrimary)
                        }
                    }
            }
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }
}
