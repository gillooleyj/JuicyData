// Shared by the app and the widget.
import Foundation

enum Lines {
    static let greeting = "Hello! I'm the government, and I'm here to help!"

    static let all: [String] = [
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
}

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
