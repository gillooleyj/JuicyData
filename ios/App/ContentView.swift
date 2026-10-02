import SwiftUI

struct ContentView: View {
    @StateObject private var speaker = Speaker()
    @AppStorage("voiceOn") private var voiceOn = true

    @State private var line = Lines.greeting
    @State private var deck: [String] = []
    @State private var taps = 0
    @State private var showSettings = false
    @State private var greeted = false

    var body: some View {
        ZStack {
            skyGradient.ignoresSafeArea()

            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(.black.opacity(0.6))
                            .padding(10)
                            .background(.white.opacity(0.55), in: Circle())
                    }
                    .accessibilityLabel("Settings")
                }
                .padding(.horizontal)

                Spacer(minLength: 0)

                Text(line)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 14 + BubbleShape.tailHeight)
                    .background(BubbleShape().fill(BubbleShape.fill))
                    .overlay(BubbleShape().stroke(.black, lineWidth: 2))
                    .padding(.horizontal, 24)
                    .id(line)
                    .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))

                mascot

                Spacer(minLength: 0)

                HStack(spacing: 18) {
                    Text("Tap the cloud")
                        .font(.footnote)
                        .foregroundStyle(.black.opacity(0.55))
                    ShareLink(item: line) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.footnote.weight(.semibold))
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
        .onAppear {
            guard !greeted else { return }
            greeted = true
            if voiceOn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    speaker.speak(Lines.greeting)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(speaker: speaker)
        }
    }

    private var mascot: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 360)
                .rotationEffect(.degrees(speaker.isSpeaking ? sin(t * 22) * 1.3 : 0), anchor: .bottom)
                .offset(y: sin(t * 2.2) * 4)
        }
        .keyframeAnimator(initialValue: 0.0, trigger: taps) { content, angle in
            content.rotationEffect(.degrees(angle), anchor: .bottom)
        } keyframes: { _ in
            KeyframeTrack {
                CubicKeyframe(5, duration: 0.08)
                CubicKeyframe(-5, duration: 0.12)
                CubicKeyframe(4, duration: 0.10)
                CubicKeyframe(-3, duration: 0.10)
                CubicKeyframe(0, duration: 0.12)
            }
        }
        .padding(.horizontal, 30)
        .contentShape(Rectangle())
        .onTapGesture { tapped() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Cloud mascot. Double tap for a new line.")
    }

    private func tapped() {
        taps += 1
        let next = nextLine()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            line = next
        }
        if voiceOn {
            speaker.speak(next)
        }
    }

    private func nextLine() -> String {
        if deck.isEmpty {
            deck = Lines.all.shuffled()
            if deck.count > 1, deck.last == line { deck.swapAt(0, deck.count - 1) }
        }
        return deck.popLast() ?? Lines.greeting
    }
}

#Preview {
    ContentView()
}
