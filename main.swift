// JuicyCloud: a Clippy-style desktop mascot for macOS.
// Build with ./build.sh (needs Xcode Command Line Tools).

import Cocoa
import QuartzCore
import AVFoundation

// MARK: - Config

let appName = "JuicyCloud"
let mascotPad: CGFloat = 8
let supportDir = (NSHomeDirectory() as NSString).appendingPathComponent(".juicycloud")
let linesPath = (supportDir as NSString).appendingPathComponent("lines.txt")

let greeting = "Hello! I'm the government, and I'm here to help!"

let defaultLines: [String] = [
    "It looks like you're writing an SSP. Would you like help turning it into JSON?",
    "Have you tried turning your POA&M off and on again?",
    "Continuous monitoring means continuously. Not annually with extra steps.",
    "If it's not in the boundary, it's not my problem.",
    "20x faster. 0x spreadsheets. Probably.",
    "Machine-readable or it didn't happen.",
    "My authorization boundary is drawn exactly where I want it.",
    "Did someone say 3PAO? I'm ready for my close-up.",
    "Class A, B, C, D. I'm a Class C with Class D ambitions.",
    "Inheriting controls like it's old money.",
    "Encrypted at rest. Encrypted in transit. Looking good in both.",
    "Every finding is just a POA&M that believes in itself.",
    "Least privilege. Maximum swagger.",
    "Scanning... scanning... still fabulous.",
    "KSIs: vibes, but with evidence attached.",
    "Cloud native. Born this way.",
    "Significant change notification? I've been changing significantly all day.",
    "Ask me about my FIPS 140 validation.",
    "Rev5 isn't dead. It moved to a nice farm upstate. Visiting hours end June 11, 2027.",
    "Rev5 is my ex. We're still on speaking terms until at least 2028.",
    "Rev5 to 20x is a glow-up, not a breakup.",
    "FedRAMP Ready went Legacy. Thoughts and prayers.",
    "Low, Moderate, High? Sir, this is a Class B establishment.",
    "It's not an authorization anymore. It's a Certification. Please update your LinkedIn.",
    "No agency sponsor? 20x said what it said.",
    "A 600-page Word SSP walks into a bar. The bartender asks for the JSON.",
    "Your Excel POA&M wants to be JSON when it grows up.",
    "OSCAL: optional, like flossing.",
    "Have you read all of CR26? All of it? Be honest.",
    "Consolidated Rules for 2026: one rulebook to rule them all.",
    "Rev5 adopts CR26 by January 1, 2027. The countdown has entered the chat.",
    "Your 800-53 controls map to KSIs. It's the circle of life.",
    "20x Class D is still in the oven. Do not open the oven.",
    "Point-in-time assessment? In this decade?",
    "I don't do annual. I do always.",
    "Patch in days, not quarters. I'm begging you.",
    "Persistent validation: like a gym membership you actually use.",
    "The JAB isn't coming back. Stop leaving the porch light on.",
    "\"What if we did 50 FedRAMP authorizations a week?\" (Pete Waterman) What if we did 51?",
    "\"Did I mention that? Spoilers! Shh.\" (Pete Waterman) I can keep a secret too.",
    "\"If you're thinking about FedRAMP as compliance, you're done.\" (Pete Waterman)",
    "\"FedRAMP is rooted in the past.\" (Pete Waterman, 2025) Not anymore.",
    "\"I don't want my information out on the internet for three days.\" (Pete Waterman)",
    "Pete, on vendors who can't patch a known exploitable vuln in days: \"I don't want you in the federal marketplace.\"",
]

// Quips for when you switch into a particular app (bundle ID -> lines).
let appLines: [String: [String]] = [
    "com.microsoft.Excel": [
        "It looks like you're building a POA&M in Excel. CR26 would like a word. In JSON.",
        "Another spreadsheet? Rev5 called. It wants its templates back.",
    ],
    "com.microsoft.Word": [
        "It looks like you're writing a 600-page SSP. Would you like to make it machine-readable instead?",
        "It looks like you're writing a policy. Want me to add 'shall' forty more times?",
    ],
    "com.microsoft.Powerpoint": [
        "It looks like you're making slides about 20x. Have you considered more clouds?",
    ],
    "com.microsoft.Outlook": [
        "It looks like you're writing an email. Reply-all responsibly.",
    ],
    "com.apple.mail": [
        "It looks like you're writing an email. Reply-all responsibly.",
    ],
    "com.microsoft.teams2": [
        "Before you hit send: is that CUI?",
    ],
    "com.microsoft.teams": [
        "Before you hit send: is that CUI?",
    ],
    "com.tinyspeck.slackmacgap": [
        "Before you hit send: is that CUI?",
    ],
    "com.apple.Terminal": [
        "Ooh, a terminal. Persistent validation, I presume?",
    ],
    "com.googlecode.iterm2": [
        "Ooh, a terminal. Persistent validation, I presume?",
    ],
    "com.microsoft.VSCode": [
        "Shipping code? Don't forget the SBOM.",
    ],
    "com.todesktop.230313mzl4w4u92": [
        "Shipping code? Don't forget the SBOM.",
    ],
]

// How the voice should say jargon. Checked in order, so list longer forms first.
let pronunciations: [(String, String)] = [
    ("POA&Ms", "poe-ams"),
    ("POA&M", "poe-am"),
    ("3PAO", "three P A O"),
    ("CR26", "C R 26"),
    ("20x", "twenty X"),
    ("Rev5", "Rev 5"),
    ("KSIs", "K S I's"),
    ("SSP", "S S P"),
    ("CUI", "C U I"),
    ("SBOM", "S-bomb"),
    ("800-53", "eight hundred fifty-three"),
    ("FIPS 140", "fips one forty"),
    ("ConMon", "con-mon"),
]

/// Turns a bubble line into something that sounds natural out loud.
func spokenText(_ text: String) -> String {
    var s = text
    if let re = try? NSRegularExpression(pattern: "\\(Pete Waterman(, \\d{4})?\\)") {
        s = re.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s),
                                        withTemplate: "says Pete Waterman.")
    }
    s = s.replacingOccurrences(of: "\"", with: "")
    for (word, sound) in pronunciations {
        s = s.replacingOccurrences(of: word, with: sound)
    }
    return s
}

// MARK: - Voice

final class Speaker: NSObject, AVSpeechSynthesizerDelegate {
    var onStart: (() -> Void)?
    var onFinish: (() -> Void)?
    private let synth = AVSpeechSynthesizer()
    private var current: AVSpeechUtterance?

    override init() {
        super.init()
        synth.delegate = self
    }

    func speak(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = VoicePicker.best() ?? AVSpeechSynthesisVoice(language: "en-US")
        u.rate = AVSpeechUtteranceDefaultSpeechRate
        u.pitchMultiplier = 1.0
        current = u
        synth.speak(u)
    }

    func stop() {
        current = nil   // ignore callbacks from what we just cut off
        synth.stopSpeaking(at: .immediate)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { if utterance === self.current { self.onStart?() } }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { if utterance === self.current { self.onFinish?() } }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { if utterance === self.current { self.onFinish?() } }
    }

}

/// Picks the best-sounding male English voice installed, so users never have to choose.
enum VoicePicker {
    /// Novelty and retro voices to skip.
    static let skip: Set<String> = [
        "Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Fred", "Good News",
        "Jester", "Junior", "Organ", "Ralph", "Superstar", "Trinoids", "Whisper", "Wobble", "Zarvox",
        "Eddy", "Grandpa", "Reed", "Rocko",
    ]
    /// Tiebreakers among voices of equal quality, best first.
    static let preferred = ["Evan", "Nathan", "Alex", "Tom", "Aaron", "Daniel", "Oliver", "Arthur", "Lee"]

    static func baseName(_ v: AVSpeechSynthesisVoice) -> String {
        v.name.components(separatedBy: " (").first ?? v.name
    }

    static func best() -> AVSpeechSynthesisVoice? {
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en") && !skip.contains(baseName($0)) && !$0.identifier.contains("eloquence")
        }
        func score(_ v: AVSpeechSynthesisVoice) -> (Int, Int, Int, Int) {
            let male = v.gender == .male ? 1 : 0
            let us = v.language == "en-US" ? 1 : 0
            let rank = preferred.firstIndex(of: baseName(v)).map { 100 - $0 } ?? 0
            return (male, v.quality.rawValue, us, rank)
        }
        return candidates.max { score($0) < score($1) }
    }

    /// e.g. "Evan (Premium)"
    static func describe(_ v: AVSpeechSynthesisVoice?) -> String {
        guard let v = v else { return "System default" }
        switch v.quality.rawValue {
        case 3...: return "\(baseName(v)) (Premium)"
        case 2: return "\(baseName(v)) (Enhanced)"
        default: return "\(baseName(v)) (Basic)"
        }
    }
}

func loadLines() -> [String] {
    if let text = try? String(contentsOfFile: linesPath, encoding: .utf8) {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
        if !lines.isEmpty { return lines }
    }
    return defaultLines
}

// MARK: - Mascot view

final class MascotView: NSView {
    var onClick: (() -> Void)?
    var onDragEnd: (() -> Void)?
    var menuBuilder: (() -> NSMenu)?

    private let imageLayer = CALayer()
    private var mouseStart = NSPoint.zero
    private var originStart = NSPoint.zero
    private var dragged = false

    init(image: NSImage) {
        super.init(frame: .zero)
        let root = CALayer()
        layer = root          // layer-hosting view
        wantsLayer = true

        imageLayer.contents = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        imageLayer.contentsGravity = .resizeAspect
        imageLayer.minificationFilter = .trilinear
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0)   // wiggle from the feet
        imageLayer.shadowColor = NSColor.black.cgColor
        imageLayer.shadowOpacity = 0.3
        imageLayer.shadowRadius = 5
        imageLayer.shadowOffset = CGSize(width: 0, height: -3)
        root.addSublayer(imageLayer)
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer.frame = NSRect(x: mascotPad, y: mascotPad,
                                  width: newSize.width - mascotPad * 2,
                                  height: newSize.height - mascotPad * 2)
        CATransaction.commit()
    }

    // MARK: Animations

    func startIdle() {
        let bob = CABasicAnimation(keyPath: "transform.translation.y")
        bob.fromValue = -2.5
        bob.toValue = 2.5
        bob.duration = 1.4
        bob.autoreverses = true
        bob.repeatCount = .infinity
        bob.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageLayer.add(bob, forKey: "bob")
    }

    func shake() {
        let a = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        a.values = [0.0, 0.07, -0.07, 0.06, -0.06, 0.03, 0.0]
        a.duration = 0.6
        a.isAdditive = true
        imageLayer.add(a, forKey: "shake")
    }

    func startTalking() {
        let a = CABasicAnimation(keyPath: "transform.rotation.z")
        a.fromValue = -0.018
        a.toValue = 0.018
        a.duration = 0.16
        a.autoreverses = true
        a.repeatCount = .infinity
        a.isAdditive = true
        imageLayer.add(a, forKey: "talk")
    }

    func stopTalking() { imageLayer.removeAnimation(forKey: "talk") }

    func hop() {
        let a = CAKeyframeAnimation(keyPath: "transform.translation.y")
        a.values = [0.0, 16.0, 0.0, 6.0, 0.0]
        a.keyTimes = [0, 0.3, 0.6, 0.8, 1]
        a.duration = 0.55
        a.isAdditive = true
        imageLayer.add(a, forKey: "hop")
    }

    // MARK: Mouse

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        mouseStart = NSEvent.mouseLocation
        originStart = window?.frame.origin ?? .zero
        dragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        let p = NSEvent.mouseLocation
        let dx = p.x - mouseStart.x
        let dy = p.y - mouseStart.y
        if abs(dx) + abs(dy) > 3 { dragged = true }
        if dragged {
            window?.setFrameOrigin(NSPoint(x: originStart.x + dx, y: originStart.y + dy))
        }
    }

    override func mouseUp(with event: NSEvent) {
        if dragged { onDragEnd?() } else { onClick?() }
    }

    override func menu(for event: NSEvent) -> NSMenu? { menuBuilder?() }
}

// MARK: - Speech bubble

final class BubbleView: NSView {
    var onClick: (() -> Void)?
    var tailX: CGFloat = 40 { didSet { needsDisplay = true } }
    let tailH: CGFloat = 12
    private let label = NSTextField(wrappingLabelWithString: "")

    init() {
        super.init(frame: .zero)
        label.font = NSFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.isSelectable = false
        label.drawsBackground = false
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    /// Lays out the text and returns the size the bubble window should be.
    func layoutFor(text: String, maxWidth: CGFloat) -> NSSize {
        label.stringValue = text
        let pad: CGFloat = 14
        let fit = label.cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: maxWidth - pad * 2, height: 10_000))
        let textW = ceil(fit.width)
        let textH = ceil(fit.height)
        let w = max(textW + pad * 2, 70)
        label.frame = NSRect(x: pad, y: tailH + 10, width: w - pad * 2, height: textH)
        return NSSize(width: w, height: textH + 20 + tailH)
    }

    override func draw(_ dirtyRect: NSRect) {
        let fill = NSColor(srgbRed: 1.0, green: 0.99, blue: 0.80, alpha: 1)   // classic Clippy yellow
        let body = NSRect(x: 1, y: tailH, width: bounds.width - 2, height: bounds.height - tailH - 1)
        let bodyPath = NSBezierPath(roundedRect: body, xRadius: 10, yRadius: 10)
        bodyPath.lineWidth = 1.5
        fill.setFill(); bodyPath.fill()
        NSColor.black.setStroke(); bodyPath.stroke()

        let tx = min(max(tailX, 22), bounds.width - 22)
        let tail = NSBezierPath()
        tail.move(to: NSPoint(x: tx - 8, y: tailH + 1.5))
        tail.line(to: NSPoint(x: tx - 2, y: 1))
        tail.line(to: NSPoint(x: tx + 8, y: tailH + 1.5))
        tail.close()
        fill.setFill(); tail.fill()

        let edges = NSBezierPath()
        edges.lineWidth = 1.5
        edges.move(to: NSPoint(x: tx - 8, y: tailH))
        edges.line(to: NSPoint(x: tx - 2, y: 1))
        edges.line(to: NSPoint(x: tx + 8, y: tailH))
        edges.stroke()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with event: NSEvent) { onClick?() }
}

// MARK: - App

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var window: NSPanel!
    var mascot: MascotView!
    var bubbleWindow: NSPanel!
    var bubble: BubbleView!
    var statusItem: NSStatusItem!

    var lines: [String] = []
    var deck: [String] = []
    var lastLine: String?
    var hideTimer: Timer?
    let speaker = Speaker()
    var chatterTimer: Timer?
    var bubbleGen = 0
    var lastAppQuip = Date.distantPast
    var imageAspect: CGFloat = 0.75
    let defaults = UserDefaults.standard

    // MARK: Settings

    var sizeHeight: CGFloat {
        get { let v = defaults.double(forKey: "height"); return v > 0 ? CGFloat(v) : 220 }
        set { defaults.set(Double(newValue), forKey: "height") }
    }
    var chatterMinutes: Int {
        get { defaults.object(forKey: "chatter") == nil ? 15 : defaults.integer(forKey: "chatter") }
        set { defaults.set(newValue, forKey: "chatter") }
    }
    /// 0 = off, 1 = only when clicked, 2 = all lines
    var voiceMode: Int {
        get { defaults.integer(forKey: "voiceMode") }
        set { defaults.set(newValue, forKey: "voiceMode") }
    }
    var appAware: Bool {
        get { defaults.object(forKey: "appAware") == nil ? true : defaults.bool(forKey: "appAware") }
        set { defaults.set(newValue, forKey: "appAware") }
    }

    // MARK: Launch

    func applicationDidFinishLaunching(_ notification: Notification) {
        lines = loadLines()
        guard let url = Bundle.main.url(forResource: "mascot", withExtension: "png"),
              let img = NSImage(contentsOf: url) else {
            let alert = NSAlert()
            alert.messageText = "mascot.png is missing from the app bundle."
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        imageAspect = img.size.width / img.size.height

        buildMascotWindow(image: img)
        speaker.onStart = { [weak self] in self?.mascot.startTalking() }
        speaker.onFinish = { [weak self] in self?.speechFinished() }
        buildBubble()
        buildStatusItem()
        rescheduleChatter()

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appActivated(_:)),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.mascot.hop()
            self?.say(greeting, fromClick: true)   // spoken whenever voice is on
        }
    }

    func configureFloating(_ w: NSPanel) {
        w.isOpaque = false
        w.backgroundColor = .clear
        w.hasShadow = false
        w.level = .floating
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        w.hidesOnDeactivate = false
        w.isReleasedWhenClosed = false
    }

    func mascotSize() -> NSSize {
        let h = sizeHeight
        return NSSize(width: round(h * imageAspect) + mascotPad * 2, height: h + mascotPad * 2)
    }

    func buildMascotWindow(image: NSImage) {
        let size = mascotSize()
        window = NSPanel(contentRect: NSRect(origin: .zero, size: size),
                         styleMask: [.borderless, .nonactivatingPanel],
                         backing: .buffered, defer: false)
        configureFloating(window)

        mascot = MascotView(image: image)
        mascot.frame = NSRect(origin: .zero, size: size)
        mascot.onClick = { [weak self] in self?.mascotClicked() }
        mascot.onDragEnd = { [weak self] in self?.savePosition() }
        mascot.menuBuilder = { [weak self] in self?.buildMenu() ?? NSMenu() }
        window.contentView = mascot

        window.setFrameOrigin(initialOrigin(for: size))
        window.orderFrontRegardless()
        mascot.startIdle()
    }

    func initialOrigin(for size: NSSize) -> NSPoint {
        if let s = defaults.string(forKey: "origin") {
            let p = NSPointFromString(s)
            let r = NSRect(origin: p, size: size).insetBy(dx: 20, dy: 20)
            if NSScreen.screens.contains(where: { $0.visibleFrame.intersects(r) }) { return p }
        }
        let vf = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        return NSPoint(x: vf.maxX - size.width - 24, y: vf.minY + 24)
    }

    func savePosition() {
        defaults.set(NSStringFromPoint(window.frame.origin), forKey: "origin")
        if bubbleWindow.isVisible { positionBubble() }
    }

    // MARK: Bubble

    func buildBubble() {
        bubble = BubbleView()
        bubble.onClick = { [weak self] in self?.hideBubble() }
        bubbleWindow = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
                               styleMask: [.borderless, .nonactivatingPanel],
                               backing: .buffered, defer: false)
        configureFloating(bubbleWindow)
        bubbleWindow.hasShadow = true
        bubbleWindow.contentView = bubble
    }

    func positionBubble() {
        let m = window.frame
        let s = bubbleWindow.frame.size
        let vf = (window.screen ?? NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let headX = m.minX + m.width * 0.6       // aim the tail at the cloud
        var x = headX - s.width * 0.5
        x = min(max(x, vf.minX + 4), vf.maxX - s.width - 4)
        var y = m.maxY - 10
        if y + s.height > vf.maxY { y = vf.maxY - s.height }
        bubbleWindow.setFrameOrigin(NSPoint(x: x, y: y))
        bubble.tailX = headX - x
    }

    func say(_ text: String, fromClick: Bool = false) {
        guard window.isVisible else { return }
        bubbleGen += 1
        let size = bubble.layoutFor(text: text, maxWidth: 260)
        bubbleWindow.setContentSize(size)
        positionBubble()
        bubble.needsDisplay = true

        if bubbleWindow.parent == nil { window.addChildWindow(bubbleWindow, ordered: .above) }
        if !bubbleWindow.isVisible { bubbleWindow.alphaValue = 0 }
        bubbleWindow.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            self.bubbleWindow.animator().alphaValue = 1
        }
        bubbleWindow.invalidateShadow()

        hideTimer?.invalidate()
        let readSecs = max(4.0, Double(text.count) / 14.0)
        let speakIt = voiceMode == 2 || (voiceMode == 1 && fromClick)
        if speakIt {
            speaker.speak(spokenText(text))
            scheduleHide(after: readSecs * 3 + 5)   // safety net; normally hides when speech ends
        } else {
            speaker.stop()
            mascot.stopTalking()
            scheduleHide(after: readSecs)
        }
    }

    func scheduleHide(after secs: Double) {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: secs, target: self,
                                         selector: #selector(hideBubble), userInfo: nil, repeats: false)
    }

    func speechFinished() {
        mascot.stopTalking()
        if bubbleWindow.isVisible { scheduleHide(after: 1.5) }
    }

    @objc func hideBubble() {
        hideTimer?.invalidate()
        hideTimer = nil
        speaker.stop()
        mascot.stopTalking()
        guard bubbleWindow.isVisible else { return }
        let gen = bubbleGen
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.18
            self.bubbleWindow.animator().alphaValue = 0
        }, completionHandler: {
            guard gen == self.bubbleGen else { return }   // a new line started meanwhile
            self.window.removeChildWindow(self.bubbleWindow)
            self.bubbleWindow.orderOut(nil)
        })
    }

    func nextLine() -> String {
        if deck.isEmpty {
            deck = lines.shuffled()
            if deck.count > 1, deck.last == lastLine { deck.swapAt(0, deck.count - 1) }
        }
        let line = deck.popLast() ?? "..."
        lastLine = line
        return line
    }

    // MARK: Behaviors

    func mascotClicked() {
        mascot.shake()
        say(nextLine(), fromClick: true)
    }

    func rescheduleChatter() {
        chatterTimer?.invalidate()
        chatterTimer = nil
        guard chatterMinutes > 0 else { return }
        chatterTimer = Timer.scheduledTimer(timeInterval: Double(chatterMinutes) * 60, target: self,
                                            selector: #selector(chatter), userInfo: nil, repeats: true)
    }

    @objc func chatter() {
        guard window.isVisible, !bubbleWindow.isVisible else { return }
        mascot.hop()
        say(nextLine())
    }

    @objc func appActivated(_ note: Notification) {
        guard appAware, window.isVisible,
              let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let id = app.bundleIdentifier,
              let quips = appLines[id], let quip = quips.randomElement(),
              Date().timeIntervalSince(lastAppQuip) > 600,
              Double.random(in: 0...1) < 0.5 else { return }
        lastAppQuip = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.mascot.hop()
            self?.say(quip)
        }
    }

    // MARK: Menus

    func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "☁️"
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) { populate(menu) }

    func buildMenu() -> NSMenu {
        let m = NSMenu()
        populate(m)
        return m
    }

    func populate(_ menu: NSMenu) {
        menu.removeAllItems()
        func item(_ title: String, _ sel: Selector, key: String = "", tag: Int = 0, on: Bool = false) -> NSMenuItem {
            let i = NSMenuItem(title: title, action: sel, keyEquivalent: key)
            i.target = self
            i.tag = tag
            i.state = on ? .on : .off
            return i
        }
        func sub(_ title: String, _ items: [NSMenuItem]) -> NSMenuItem {
            let parent = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            let m = NSMenu()
            items.forEach { m.addItem($0) }
            parent.submenu = m
            return parent
        }

        menu.addItem(item(window.isVisible ? "Hide \(appName)" : "Show \(appName)", #selector(toggleVisible)))
        menu.addItem(item("Say Something", #selector(saySomething)))
        menu.addItem(item("Shake It", #selector(shakeIt)))
        menu.addItem(.separator())
        menu.addItem(sub("Size", [("Small", 160), ("Medium", 220), ("Large", 300)].map {
            item($0.0, #selector(setSize(_:)), tag: $0.1, on: Int(sizeHeight) == $0.1)
        }))
        menu.addItem(sub("Chattiness", [("Quiet", 0), ("Every 5 minutes", 5), ("Every 15 minutes", 15), ("Every hour", 60)].map {
            item($0.0, #selector(setChatter(_:)), tag: $0.1, on: chatterMinutes == $0.1)
        }))
        menu.addItem(item("React to Apps", #selector(toggleAppAware), on: appAware))

        var voiceItems: [NSMenuItem] = [
            item("Off", #selector(setVoiceMode(_:)), tag: 0, on: voiceMode == 0),
            item("Only When Clicked", #selector(setVoiceMode(_:)), tag: 1, on: voiceMode == 1),
            item("All Lines", #selector(setVoiceMode(_:)), tag: 2, on: voiceMode == 2),
            .separator(),
        ]
        let best = VoicePicker.best()
        let current = NSMenuItem(title: "Voice: \(VoicePicker.describe(best))", action: nil, keyEquivalent: "")
        current.isEnabled = false
        voiceItems.append(current)
        if (best?.quality.rawValue ?? 0) < 3 {
            voiceItems.append(item("Get a Better Voice…", #selector(betterVoiceHelp)))
        }
        menu.addItem(sub("Speech", voiceItems))
        menu.addItem(.separator())
        menu.addItem(item("Edit Lines…", #selector(editLines)))
        menu.addItem(item("Reload Lines", #selector(reloadLines)))
        menu.addItem(.separator())
        menu.addItem(item("Quit \(appName)", #selector(quit), key: "q"))
    }

    @objc func toggleVisible() {
        if window.isVisible {
            hideBubble()
            window.orderOut(nil)
        } else {
            window.orderFrontRegardless()
            mascot.hop()
        }
    }

    @objc func saySomething() {
        if !window.isVisible { window.orderFrontRegardless() }
        mascot.hop()
        say(nextLine(), fromClick: true)
    }

    @objc func shakeIt() { mascot.shake() }

    @objc func setSize(_ sender: NSMenuItem) {
        sizeHeight = CGFloat(sender.tag)
        let old = window.frame
        let s = mascotSize()
        let origin = NSPoint(x: old.midX - s.width / 2, y: old.minY)   // keep feet planted
        window.setFrame(NSRect(origin: origin, size: s), display: true)
        mascot.frame = NSRect(origin: .zero, size: s)
        savePosition()
    }

    @objc func setChatter(_ sender: NSMenuItem) {
        chatterMinutes = sender.tag
        rescheduleChatter()
    }

    @objc func toggleAppAware() { appAware.toggle() }

    @objc func setVoiceMode(_ sender: NSMenuItem) {
        voiceMode = sender.tag
        if voiceMode == 0 {
            speaker.stop()
        } else {
            say("Voice on. You're welcome.", fromClick: true)
        }
    }

    @objc func betterVoiceHelp() {
        let alert = NSAlert()
        alert.messageText = "Get a better voice"
        alert.informativeText = """
        1. Open System Settings > Accessibility > Spoken Content.
        2. Next to System Voice, open the menu and choose Manage Voices.
        3. Under English, download Evan (Premium). Nathan or Tom (Enhanced) also work well.
        4. Quit and reopen \(appName). It switches to the new voice automatically.
        """
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    @objc func editLines() {
        let fm = FileManager.default
        try? fm.createDirectory(atPath: supportDir, withIntermediateDirectories: true)
        if !fm.fileExists(atPath: linesPath) {
            let header = "# One line per row. Lines starting with # are ignored.\n# Save this file, then choose Reload Lines from the cloud menu.\n\n"
            try? (header + defaultLines.joined(separator: "\n") + "\n")
                .write(toFile: linesPath, atomically: true, encoding: .utf8)
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: linesPath))
    }

    @objc func reloadLines() {
        lines = loadLines()
        deck = []
        mascot.hop()
        say("Fresh material loaded. \(lines.count) lines ready.")
    }

    @objc func quit() { NSApp.terminate(nil) }
}

// MARK: - Main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)   // no Dock icon; lives in the menu bar
app.run()
