import WidgetKit
import SwiftUI

struct QuipEntry: TimelineEntry {
    let date: Date
    let line: String
}

struct QuipProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuipEntry {
        QuipEntry(date: .now, line: Lines.greeting)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuipEntry) -> Void) {
        completion(QuipEntry(date: .now, line: Lines.all.randomElement() ?? Lines.greeting))
    }

    /// A new line every hour for the next 12 hours, then WidgetKit asks again.
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuipEntry>) -> Void) {
        let shuffled = Lines.all.shuffled()
        let now = Date()
        let entries = (0..<12).map { i in
            QuipEntry(date: now.addingTimeInterval(Double(i) * 3600),
                      line: shuffled.isEmpty ? Lines.greeting : shuffled[i % shuffled.count])
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct JuicyWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuipEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .accessoryRectangular {
                    Color.clear
                } else {
                    skyGradient
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryRectangular:
            Text(entry.line)
                .font(.caption)
                .minimumScaleFactor(0.6)
                .widgetAccentable()
        case .systemSmall:
            VStack(spacing: 2) {
                bubble(size: 11, lines: 4)
                Image("Mascot").resizable().scaledToFit()
            }
        case .systemMedium:
            HStack(spacing: 8) {
                Image("Mascot").resizable().scaledToFit()
                bubble(size: 14, lines: 6, tailX: 0.2)
            }
        default:
            VStack(spacing: 6) {
                bubble(size: 17, lines: 6)
                Image("Mascot").resizable().scaledToFit()
            }
        }
    }

    private func bubble(size: CGFloat, lines: Int, tailX: CGFloat = 0.6) -> some View {
        Text(entry.line)
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundStyle(.black)
            .lineLimit(lines)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 8)
            .padding(.top, 6)
            .padding(.bottom, 6 + BubbleShape.tailHeight)
            .background(BubbleShape(tailX: tailX).fill(BubbleShape.fill))
            .overlay(BubbleShape(tailX: tailX).stroke(.black, lineWidth: 1.5))
    }
}

struct JuicyWidget: Widget {
    let kind = "JuicyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuipProvider()) { entry in
            JuicyWidgetView(entry: entry)
        }
        .configurationDisplayName("JuicyCloud")
        .description("A fresh 20x quip every hour.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

@main
struct JuicyWidgetBundle: WidgetBundle {
    var body: some Widget {
        JuicyWidget()
    }
}
