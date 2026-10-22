import SwiftUI

private enum Constants {
    static let labelSize: CGFloat = 15
    static let borderWidth: CGFloat = 1
}

struct CommunitySegmentControl: View {
    @Binding var selection: CommunitySegment

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(CommunitySegment.allCases) { segment in
                segmentButton(segment)
            }
        }
        .padding(Spacing.xxs)
        .background(Capsule().fill(Color.appSurfaceCard))
        .overlay(Capsule().stroke(Color.appOutline, lineWidth: Constants.borderWidth))
        .padding(.horizontal, Spacing.lg)
    }

    private func segmentButton(_ segment: CommunitySegment) -> some View {
        let isSelected = selection == segment
        return Button {
            withAnimation(.snappy(duration: Durations.short)) {
                selection = segment
            }
        } label: {
            Text(segment.rawValue)
                .font(.appLabel(Constants.labelSize))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background {
                    if isSelected {
                        Capsule().fill(Color.appPrimary)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    @Previewable @State var selection: CommunitySegment = .myFeed
    CommunitySegmentControl(selection: $selection)
        .padding(.vertical)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
}
