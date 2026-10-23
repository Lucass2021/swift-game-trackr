import SwiftUI

private enum Constants {
    static let iconSize: CGFloat = 18
    static let textSize: CGFloat = 16
    static let datePattern = "dd/MM/yyyy"
}

struct DateField: View {
    @Binding var date: Date?
    var placeholder: String = "dd/mm/yyyy"
    var isError = false

    @State private var showPicker = false
    @State private var draft = Date()

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.datePattern
        return formatter
    }()

    var body: some View {
        Button {
            draft = date ?? Date()
            showPicker = true
        } label: {
            HStack {
                Text(date.map { Self.formatter.string(from: $0) } ?? placeholder)
                    .font(.appBody(Constants.textSize))
                    .foregroundStyle(date == nil ? Color.appTextSecondary : Color.appTextPrimary)
                Spacer()
                AppIconView(icon: .calendar, size: Constants.iconSize)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .fieldBox(isError: isError)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                DatePicker("", selection: $draft, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.appPrimary)
                    .padding(Spacing.md)
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

#Preview {
    @Previewable @State var date: Date? = Date()
    DateField(date: $date, isError: true)
        .padding(Spacing.md)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
