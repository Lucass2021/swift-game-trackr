import SwiftUI

struct CommunitySegmentControl: View {
    @Binding var selection: CommunitySegment

    var body: some View {
        HStack(spacing: 4) {
            ForEach(CommunitySegment.allCases) { segment in
                segmentButton(segment)
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.appSurfaceCard))
        .overlay(Capsule().stroke(Color.appOutline, lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private func segmentButton(_ segment: CommunitySegment) -> some View {
        let isSelected = selection == segment
        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                selection = segment
            }
        } label: {
            Text(segment.rawValue)
                .font(.appLabel(15))
                .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
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
