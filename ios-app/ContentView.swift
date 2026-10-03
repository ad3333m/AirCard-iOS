import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - UIFont helper

extension UIFont {
    /// Returns a rounded-design version of self when the platform provides it,
    /// otherwise the original font.
    func roundedIfPossible() -> UIFont {
        guard let desc = self.fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: desc, size: self.pointSize)
    }
}

// MARK: - Brand palette

/// Brand colors mirror the AirTweak app icon: dark navy → cyan.
enum Brand {
    static let deepNavy = Color(red: 0x0B/255.0, green: 0x1A/255.0, blue: 0x36/255.0)
    static let navy     = Color(red: 0x21/255.0, green: 0x4B/255.0, blue: 0x8E/255.0)
    static let blue     = Color(red: 0x2E/255.0, green: 0xA8/255.0, blue: 0xFF/255.0)
    static let cyan     = Color(red: 0x66/255.0, green: 0xD5/255.0, blue: 0xFF/255.0)
    static let ice      = Color(red: 0xB8/255.0, green: 0xF0/255.0, blue: 0xFF/255.0)

    // Used to be `violet` — keep the alias so older references still compile.
    static let violet = navy

    /// Navy → cyan-blue diagonal sweep for buttons. Uses light-enough stops
    /// on both ends so buttons stay visible over the dark app background.
    static let sweep = LinearGradient(
        colors: [
            Color(red: 0x2A/255.0, green: 0x63/255.0, blue: 0xE0/255.0),
            blue,
            cyan
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Softer sweep for section backgrounds.
    static let softSweep = LinearGradient(
        colors: [
            navy.opacity(0.22),
            blue.opacity(0.16),
            cyan.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct BrandPrimaryButton: ViewModifier {
    var enabled: Bool = true
    func body(content: Content) -> some View {
        let bg: AnyShapeStyle = enabled
            ? AnyShapeStyle(Brand.sweep)
            : AnyShapeStyle(Color.gray.opacity(0.35))
        return content
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(bg, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: enabled ? Brand.blue.opacity(0.35) : .clear,
                    radius: 14, x: 0, y: 6)
    }
}

struct BrandSecondaryButton: ViewModifier {
    var tint: Color = Brand.blue
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(tint.opacity(0.35), lineWidth: 1)
            )
    }
}

extension View {
    func brandPrimaryButton(enabled: Bool = true) -> some View {
        modifier(BrandPrimaryButton(enabled: enabled))
    }
    func brandSecondaryButton(tint: Color = Brand.blue) -> some View {
        modifier(BrandSecondaryButton(tint: tint))
    }

    /// Transparent Form background + fresh section styling.
    func brandForm() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.clear)
    }
}

// MARK: - Hero header

/// Glass hero panel with animated rings + tagline. Sits below the nav bar's
/// large title (which shows the tab name itself in rounded heavy white).
struct BrandHero: View {
    let subtitle: String
    let systemImage: String
    var accent: Color = Brand.cyan

    @State private var pulse: CGFloat = 0
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            AnimatedRings(systemImage: systemImage, accent: accent)
                .frame(width: 62, height: 62)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.opacity(0.55), accent.opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: accent.opacity(0.15), radius: 20, y: 8)
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) { appeared = true }
        }
    }
}

/// The rings glyph, but the outermost ring gently pulses and the middle ring
/// counter-rotates faintly for a "live" feel.
struct AnimatedRings: View {
    let systemImage: String
    var accent: Color = Brand.cyan

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.55
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .stroke(accent.opacity(pulseOpacity), lineWidth: 1.5)
                .scaleEffect(pulseScale)
            // Inner slowly rotating dashed ring
            Circle()
                .strokeBorder(
                    accent.opacity(0.35),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 6])
                )
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(rotation))
            // Filled dot behind icon
            Circle().fill(accent.opacity(0.14))
                .frame(width: 44, height: 44)

            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(accent)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
                pulseOpacity = 0.15
            }
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Settings sheet (shared across all tabs)

/// Settings panel accessible from every tab's top-left gear button.
/// Houses the per-card "Original Image" picker (moved out of the Cards tab).
struct SettingsSheet: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var activePickerCardId: String? = nil
    @State private var showPhotos = false
    @State private var showFiles  = false
    @State private var showSourceDialog = false
    @State private var selectedPhotos: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    BrandHero(
                        subtitle: "Store a copy of each card's original artwork so Restore can bring it back later.",
                        systemImage: "gearshape.2.fill"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Original Card Pictures") {
                    if vm.cards.isEmpty {
                        Text("No cards yet — scan one in the Cards tab first.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.cards, id: \.id) { card in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 54, height: 34)
                                    if let img = card.originalUIImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 54, height: 34)
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    } else {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(card.id.prefix(8) + "…" + card.id.suffix(6))
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    Text(card.originalUIImage != nil ? "Original saved" : "No original saved")
                                        .font(.caption2)
                                        .foregroundStyle(card.originalUIImage != nil ? .green : .secondary)
                                }
                                Spacer()
                                Button {
                                    activePickerCardId = card.id
                                    showSourceDialog = true
                                } label: {
                                    Text(card.originalUIImage == nil ? "Set" : "Change")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Brand.sweep, in: Capsule())
                                }
                                .buttonStyle(SpringPressButton())
                                if card.originalUIImage != nil {
                                    Button(role: .destructive) {
                                        vm.clearCardOriginalImage(for: card.id)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .brandForm()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Brand.cyan)
                        .font(.body.weight(.semibold))
                }
            }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceDialog, titleVisibility: .visible) {
                Button {
                    showPhotos = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                Button {
                    showFiles = true
                } label: {
                    Label("Choose from Files…", systemImage: "folder")
                }
                Button("Cancel", role: .cancel) {
                    activePickerCardId = nil
                }
            }
            .photosPicker(
                isPresented: $showPhotos,
                selection: $selectedPhotos,
                maxSelectionCount: 1,
                matching: .images
            )
            .onChange(of: selectedPhotos) { _, items in
                guard let item = items.first, let cid = activePickerCardId else {
                    if items.isEmpty { activePickerCardId = nil }
                    return
                }
                let targetId = cid
                Task {
                    if let image = await item.loadUIImage(maxDimension: 2560) {
                        await MainActor.run {
                            vm.setCardOriginalImage(for: targetId, image: image)
                        }
                    }
                    await MainActor.run {
                        selectedPhotos = []
                        activePickerCardId = nil
                    }
                }
            }
            .sheet(isPresented: $showFiles) {
                DocumentPickerView(allowedContentTypes: [
                    .image, .png, .jpeg, .heic,
                    UTType(filenameExtension: "webp") ?? .image,
                    UTType(filenameExtension: "tiff") ?? .image
                ]) { url in
                    guard let cid = activePickerCardId else { return }
                    if let data = try? Data(contentsOf: url),
                       let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                        vm.setCardOriginalImage(for: cid, image: image)
                    }
                    activePickerCardId = nil
                }
            }
        }
    }
}

/// Reusable top-left settings gear toolbar item. Add to every tab's `.toolbar`.
struct SettingsGearToolbar: ToolbarContent {
    @Binding var showSettings: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Brand.cyan)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
        }
    }
}

// MARK: - Card picture presets

/// Built-in abstract gradient card pictures. Shown in the per-card dropdown
/// as a grid of unlabeled thumbnails so the user can pick one in a tap.
enum CardPresets {
    struct Preset: Identifiable, Equatable {
        let id: Int
        let colors: [UIColor]
        let style: Style
    }

    enum Style { case diagonal, radial, stripes, waves, mesh }

    static let all: [Preset] = [
        Preset(id: 1,  colors: [UIColor(red: 0.49, green: 0.30, blue: 1.00, alpha: 1), UIColor(red: 0.12, green: 0.88, blue: 0.82, alpha: 1)], style: .diagonal),
        Preset(id: 2,  colors: [UIColor(red: 1.00, green: 0.29, blue: 0.56, alpha: 1), UIColor(red: 1.00, green: 0.75, blue: 0.29, alpha: 1)], style: .diagonal),
        Preset(id: 3,  colors: [UIColor(red: 0.00, green: 0.75, blue: 1.00, alpha: 1), UIColor(red: 0.72, green: 1.00, blue: 0.97, alpha: 1)], style: .radial),
        Preset(id: 4,  colors: [UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1), UIColor(red: 0.00, green: 1.00, blue: 0.78, alpha: 1)], style: .radial),
        Preset(id: 5,  colors: [UIColor(red: 1.00, green: 0.33, blue: 0.33, alpha: 1), UIColor(red: 0.52, green: 0.00, blue: 0.80, alpha: 1)], style: .diagonal),
        Preset(id: 6,  colors: [UIColor(red: 0.17, green: 0.24, blue: 0.56, alpha: 1), UIColor(red: 0.98, green: 0.57, blue: 0.14, alpha: 1)], style: .stripes),
        Preset(id: 7,  colors: [UIColor(red: 0.05, green: 0.49, blue: 0.76, alpha: 1), UIColor(red: 0.00, green: 0.18, blue: 0.35, alpha: 1)], style: .waves),
        Preset(id: 8,  colors: [UIColor(red: 0.17, green: 0.80, blue: 0.44, alpha: 1), UIColor(red: 0.00, green: 0.28, blue: 0.17, alpha: 1)], style: .mesh),
        Preset(id: 9,  colors: [UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1), UIColor(red: 0.75, green: 0.75, blue: 0.80, alpha: 1)], style: .diagonal),
        Preset(id: 10, colors: [UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1), UIColor(red: 0.42, green: 0.42, blue: 0.48, alpha: 1)], style: .diagonal),
        Preset(id: 11, colors: [UIColor(red: 0.86, green: 0.07, blue: 0.24, alpha: 1), UIColor(red: 0.20, green: 0.02, blue: 0.05, alpha: 1)], style: .radial),
        Preset(id: 12, colors: [UIColor(red: 0.98, green: 0.74, blue: 0.02, alpha: 1), UIColor(red: 0.58, green: 0.35, blue: 0.00, alpha: 1)], style: .diagonal),
    ]

    /// Render a preset at the given size. Cached in-memory per (id, size) so
    /// repeated tile renders don't thrash the CPU.
    private static var cache: [String: UIImage] = [:]

    static func render(_ preset: Preset, size: CGSize) -> UIImage {
        let key = "\(preset.id)@\(Int(size.width))x\(Int(size.height))"
        if let cached = cache[key] { return cached }

        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = 1
        fmt.opaque = true
        let r = UIGraphicsImageRenderer(size: size, format: fmt)
        let img = r.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let cg = ctx.cgContext
            let cs = CGColorSpaceCreateDeviceRGB()
            let cs2 = preset.colors.map { $0.cgColor }
            switch preset.style {
            case .diagonal:
                let g = CGGradient(colorsSpace: cs, colors: cs2 as CFArray, locations: [0, 1])!
                cg.drawLinearGradient(g, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            case .radial:
                let g = CGGradient(colorsSpace: cs, colors: cs2 as CFArray, locations: [0, 1])!
                let c = CGPoint(x: size.width * 0.35, y: size.height * 0.3)
                cg.drawRadialGradient(g, startCenter: c, startRadius: 0,
                                      endCenter: CGPoint(x: size.width/2, y: size.height/2),
                                      endRadius: max(size.width, size.height), options: [])
            case .stripes:
                let g = CGGradient(colorsSpace: cs, colors: cs2 as CFArray, locations: [0, 1])!
                cg.drawLinearGradient(g, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
                cg.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
                var y: CGFloat = -size.height
                while y < size.height {
                    cg.saveGState()
                    cg.translateBy(x: size.width/2, y: size.height/2)
                    cg.rotate(by: -.pi / 6)
                    cg.translateBy(x: -size.width/2, y: -size.height/2)
                    cg.fill(CGRect(x: 0, y: y, width: size.width, height: 24))
                    cg.restoreGState()
                    y += 60
                }
            case .waves:
                let g = CGGradient(colorsSpace: cs, colors: cs2 as CFArray, locations: [0, 1])!
                cg.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
                cg.setStrokeColor(UIColor.white.withAlphaComponent(0.14).cgColor)
                cg.setLineWidth(3)
                for i in 0..<6 {
                    let path = CGMutablePath()
                    let y = size.height * CGFloat(i) / 5
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    while x < size.width {
                        path.addQuadCurve(to: CGPoint(x: x+80, y: y),
                                          control: CGPoint(x: x+40, y: y - 30))
                        x += 80
                    }
                    cg.addPath(path)
                    cg.strokePath()
                }
            case .mesh:
                let g = CGGradient(colorsSpace: cs, colors: cs2 as CFArray, locations: [0, 1])!
                cg.drawLinearGradient(g, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
                cg.setFillColor(UIColor.white.withAlphaComponent(0.06).cgColor)
                let step: CGFloat = 36
                var y: CGFloat = 0
                while y < size.height {
                    var x: CGFloat = (Int(y / step) % 2 == 0) ? 0 : step/2
                    while x < size.width {
                        cg.fillEllipse(in: CGRect(x: x, y: y, width: 10, height: 10))
                        x += step
                    }
                    y += step
                }
            }
            // Soft top sheen
            let sheen = CGGradient(colorsSpace: cs,
                                   colors: [UIColor.white.withAlphaComponent(0.18).cgColor,
                                            UIColor.white.withAlphaComponent(0).cgColor] as CFArray,
                                   locations: [0, 1])!
            cg.drawLinearGradient(sheen, start: .zero, end: CGPoint(x: 0, y: size.height*0.35), options: [])
        }
        cache[key] = img
        return img
    }
}

// MARK: - Springy button style

/// Adds a satisfying scale + haptic on press to any button.
struct SpringPressButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Shared helpers

func logLineColor(_ line: String) -> Color {
    if line.contains("✅") || line.contains("🎉") { return .green }
    if line.contains("❌") { return .red }
    if line.contains("⚠️") { return .orange }
    return .secondary
}

// MARK: - Share Sheet for Exporting .passthm

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Credits Sheet

struct CreditsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Brand
                    VStack(spacing: 8) {
                        Image(systemName: "creditcard.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)

                        Text("AirCard-iOS")
                            .font(.title2.bold())

                        Text("Apple Wallet Skins & Passcode Themes for iOS 18+")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    Divider()

                    VStack(alignment: .leading, spacing: 14) {
                        // mak5er (Lead & Core Developer)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Lead & Core Developer", systemImage: "crown.fill")
                                    .font(.caption.bold().uppercaseSmallCaps())
                                    .foregroundStyle(.orange)
                                Spacer()
                                Text("Chief")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }

                            HStack(spacing: 8) {
                                Text("@mak5er")
                                    .font(.headline.bold())

                                Spacer()

                                Link(destination: URL(string: "https://github.com/mak5er")!) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text("GitHub")
                                    }
                                    .font(.caption.bold())
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Link(destination: URL(string: "https://x.com/mak5er")!) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                        Text("Twitter / X")
                                    }
                                    .font(.caption.bold())
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        // merybist (Base IPA Developer)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Base IPA Developer", systemImage: "hammer.fill")
                                    .font(.caption.bold().uppercaseSmallCaps())
                                    .foregroundStyle(.blue)
                                Spacer()
                                Text("Base")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }

                            HStack(spacing: 8) {
                                Text("@merybist")
                                    .font(.headline.bold())

                                Spacer()

                                Link(destination: URL(string: "https://github.com/merybist")!) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                        Text("GitHub")
                                    }
                                    .font(.caption.bold())
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Link(destination: URL(string: "https://x.com/merybist")!) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                        Text("Twitter / X")
                                    }
                                    .font(.caption.bold())
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        // Technology acknowledgments
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "bolt.shield.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Core Exploit")
                                        .font(.subheadline.bold())
                                    Text("airlift (AirTraffic sync sandbox escape)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Divider()

                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.title3)
                                    .foregroundStyle(.purple)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Passcode Themes")
                                        .font(.subheadline.bold())
                                    Text(".passthm standard (Cowabunga / Nugget)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Divider()

                            HStack(spacing: 12) {
                                Image(systemName: "bolt.fill")
                                    .font(.title3)
                                    .foregroundStyle(.yellow)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("NeoSpring & PosterBoard")
                                        .font(.subheadline.bold())
                                    Text("SpringBoard reload & .tendies wallpapers (@neonmodder123, @skadz108, @rooootdev)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(uiColor: .tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Compact Scrollable Log View with 1-Click Copy

struct CompactLogView: View {
    let title: String
    let lines: [String]
    var onClear: (() -> Void)? = nil
    @State private var copied: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if let onClear = onClear, !lines.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .padding(.trailing, 6)
                }
                Button {
                    UIPasteboard.general.string = lines.joined(separator: "\n")
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        copied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        var t2 = Transaction()
                        t2.disablesAnimations = true
                        withTransaction(t2) {
                            copied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .bold))
                        Text(copied ? "Copied" : "Copy")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(copied ? .green : .blue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(Capsule())
                }
                .buttonStyle(.borderless)
                .transaction { $0.animation = nil }
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(logLineColor(line))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(idx)
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 180)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 0.5)
                )
                .onChange(of: lines.count) { _, _ in
                    if !lines.isEmpty {
                        proxy.scrollTo(lines.count - 1, anchor: .bottom)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Native Document Picker

struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let shouldStop = url.startAccessingSecurityScopedResource()
            defer {
                if shouldStop { url.stopAccessingSecurityScopedResource() }
            }
            parent.onPick(url)
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Root Tab View

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel

    init() {
        // Blur the tab bar and make it match the dark theme.
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        tabAppearance.backgroundColor = UIColor(red: 0x0B/255.0, green: 0x1A/255.0, blue: 0x36/255.0, alpha: 0.85)

        let accent = UIColor(red: 0x66/255.0, green: 0xD5/255.0, blue: 0xFF/255.0, alpha: 1)
        let inactive = UIColor(red: 0xB8/255.0, green: 0xC5/255.0, blue: 0xE0/255.0, alpha: 0.55)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = accent
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = inactive
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactive]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Transparent nav bars so our own hero shows through, with a rounded
        // heavy title in white/cyan.
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        let roundedInline = UIFont.systemFont(ofSize: 17, weight: .heavy).roundedIfPossible()
        let roundedLarge = UIFont.systemFont(ofSize: 34, weight: .heavy).roundedIfPossible()
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: roundedInline
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: roundedLarge
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    @State private var auroraShift: CGFloat = 0

    var body: some View {
        ZStack {
            // Global app background: deep navy → charcoal blue with an aura.
            LinearGradient(
                colors: [
                    Color(red: 0x08/255.0, green: 0x0F/255.0, blue: 0x24/255.0),
                    Color(red: 0x0F/255.0, green: 0x1B/255.0, blue: 0x36/255.0),
                    Color(red: 0x14/255.0, green: 0x1F/255.0, blue: 0x40/255.0),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Drifting aurora blobs
            GeometryReader { geo in
                Circle()
                    .fill(Brand.blue.opacity(0.28))
                    .frame(width: geo.size.width * 0.9)
                    .blur(radius: 90)
                    .offset(
                        x: -geo.size.width * 0.35 + auroraShift * 40,
                        y: -geo.size.height * 0.10 - auroraShift * 24
                    )
                Circle()
                    .fill(Brand.cyan.opacity(0.20))
                    .frame(width: geo.size.width * 0.75)
                    .blur(radius: 80)
                    .offset(
                        x: geo.size.width * 0.35 - auroraShift * 30,
                        y: geo.size.height * 0.45 + auroraShift * 20
                    )
                Circle()
                    .fill(Color(red: 0x7C/255.0, green: 0x4D/255.0, blue: 0xFF/255.0).opacity(0.12))
                    .frame(width: geo.size.width * 0.5)
                    .blur(radius: 70)
                    .offset(
                        x: -geo.size.width * 0.10 + auroraShift * 50,
                        y: geo.size.height * 0.10 + auroraShift * 45
                    )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                    auroraShift = 1.0
                }
            }

            TabView(selection: $vm.selectedTab) {
                PairingTab()
                    .tabItem { Label("Pairing", systemImage: "antenna.radiowaves.left.and.right") }
                    .tag(AppTab.pairing)

                WalletCardsTab()
                    .tabItem { Label("Cards", systemImage: "creditcard.and.123") }
                    .tag(AppTab.walletCards)

                PasscodeThemeTab()
                    .tabItem { Label("Passcode", systemImage: "lock.rectangle.stack.fill") }
                    .tag(AppTab.passcodeThemes)

                TendiesView()
                    .tabItem { Label("Wallpapers", systemImage: "photo.on.rectangle.angled") }
                    .tag(AppTab.wallpapers)
            }
            .tint(Brand.cyan)
        }
        .preferredColorScheme(.dark)
        .alert("Notice", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Success! 🎉", isPresented: $vm.showSuccessAlert) {
            Button("OK") {}
        } message: {
            Text(vm.successAlertMessage)
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportedThemeURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear {
            vm.showSuccessAlert = false
            vm.successAlertMessage = ""
        }
    }
}

// MARK: - Pairing Tab

struct PairingTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showDeleteConfirm = false
    @State private var showCredits = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Form {
                // Hero header
                Section {
                    BrandHero(
                        subtitle: "Wallet card skins, passcode themes & Home Screen tendies — all on-device.",
                        systemImage: "antenna.radiowaves.left.and.right"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Network / VPN Status
                Section("Network") {
                    VPNStatusRow(vm: vm)
                }

                // Pairing Status
                Section("Active Pairing") {
                    HStack(spacing: 10) {
                        if vm.hasPairingFile {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ready to exploit ✅")
                                    .font(.subheadline.bold())
                                Text("\(vm.pairingFileName) (\(vm.pairingFileSizeString))")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Not Paired")
                                    .font(.subheadline.bold())
                                Text("Tap 'Pair This iPhone' below to pair.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if vm.hasPairingFile {
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .confirmationDialog(
                    "Delete pairing session?",
                    isPresented: $showDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) { vm.deletePairingFile() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("The active pairing credentials will be removed.")
                }

                // On-Device Pairing Section (available for all iOS versions)
                Section("Pair on This iPhone") {
                    if vm.pairingPhase == .pairing {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                ProgressView().scaleEffect(0.85)
                                Text(vm.pairingStatus.isEmpty ? "Starting local pairing host…" : vm.pairingStatus)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let pin = vm.pairingPIN {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("ENTER THIS PIN ON THIS IPHONE:")
                                        .font(.caption2.bold().uppercaseSmallCaps())
                                        .foregroundStyle(.secondary)

                                    HStack(alignment: .center, spacing: 0) {
                                        Text(pin)
                                            .font(.system(size: 40, weight: .black, design: .monospaced))
                                            .foregroundStyle(.orange)
                                        Spacer()
                                        Button {
                                            UIPasteboard.general.string = pin
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        } label: {
                                            Label("Copy", systemImage: "doc.on.doc")
                                                .font(.caption.bold())
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.orange)
                                    }

                                    Text("Settings › Privacy & Security › Developer Mode › Pair with AirCard-iOS")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.primary)

                                     Button {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        Label("Open Settings App Now", systemImage: "arrow.up.forward.app")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.orange)
                                }
                                .padding(14)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button(role: .cancel) {
                                vm.cancelPairing()
                            } label: {
                                HStack(spacing: 8) {
                                    Spacer()
                                    Image(systemName: "xmark")
                                    Text("Cancel Pairing")
                                    Spacer()
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    } else {
                        VStack(spacing: 12) {
                            if !vm.pairingStatus.isEmpty && vm.pairingStatus != "idle" {
                                Text(vm.pairingStatus)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(
                                        vm.pairingStatus.contains("✅") ? .green :
                                        vm.pairingStatus.contains("❌") || vm.pairingStatus.contains("failed") ? .red :
                                        .secondary
                                    )
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            Button {
                                vm.startPairing()
                            } label: {
                                HStack(spacing: 8) {
                                    Spacer()
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .font(.body.weight(.semibold))
                                    Text(vm.hasPairingFile ? "Re-Pair This iPhone" : "Pair This iPhone")
                                        .font(.headline)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                    }
                }

                if !vm.log.isEmpty {
                    Section {
                        CompactLogView(
                            title: "Activity Log (\(vm.log.count) lines)",
                            lines: vm.log,
                            onClear: { vm.log.removeAll() }
                        )
                    }
                }
            }
            .brandForm()
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            .navigationTitle("Pairing")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                SettingsGearToolbar(showSettings: $showSettings)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCredits = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                            Text("Credits")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(.pink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.pink.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
            .sheet(isPresented: $showCredits) {
                CreditsSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet().environmentObject(vm)
            }
            .onAppear {
                vm.refreshNetworkStatus()
                vm.refreshPairingFile()
            }
            .refreshable {
                vm.refreshNetworkStatus()
                vm.refreshPairingFile()
            }
        }
    }
}

// MARK: - VPN Status Row

struct VPNStatusRow: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: vm.vpnUp
                      ? "checkmark.shield.fill"
                      : "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(vm.vpnUp ? .green : .orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.vpnUp ? "Loopback VPN Active" : "Loopback VPN Not Detected")
                        .font(.subheadline.bold())
                    Text(vm.vpnUp
                         ? "RSD tunnel ready — exploit will connect."
                         : "Connect LocalDevVPN before running flashes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !vm.vpnUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Setup LocalDevVPN:")
                        .font(.caption.bold())
                    ForEach([
                        "1. Open LocalDevVPN app and tap Connect.",
                        "2. Return to AirCard-iOS — status indicator turns green."
                    ], id: \.self) { step in
                        Text(step)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Link("Launch LocalDevVPN",
                         destination: URL(string: "localdevvpn://")!)
                        .font(.caption.bold())
                }
                .padding(10)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 8) {
                Text("Device IP:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("10.7.0.1", text: $vm.deviceIP)
                    .font(.caption.monospaced())
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(width: 120)
                Spacer()
                Button {
                    vm.refreshNetworkStatus()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }

            if !vm.networkDetail.isEmpty {
                Text(vm.networkDetail)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Apple Wallet Card View Component (Authentic AirCard Style)

struct WalletCardView: View {
    let card: CardItem
    let cardIndex: Int
    let onToggleSelected: (Bool) -> Void
    let onPickImage: () -> Void
    let onClearImage: () -> Void
    let onDelete: () -> Void
    let onPickOriginal: () -> Void
    let onClearOriginal: () -> Void
    let onPickPreset: (UIImage) -> Void

    @State private var copied = false
    @State private var showPresets = false

    var body: some View {
        VStack(spacing: 12) {
            // Realistic Apple Wallet Card Mockup (1.586 : 1 aspect ratio)
            GeometryReader { geo in
                let width = geo.size.width
                let height = width / 1.586

                ZStack {
                    if let img = card.uiImage {
                        // Custom skin applied
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                            // Subtle Apple Wallet Card Gloss Overlay
                            LinearGradient(
                                colors: [.white.opacity(0.22), .clear, .black.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                            // Neon rim
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Brand.sweep, lineWidth: 1.2)
                                .opacity(0.6)

                            // Top Right Remove Button
                            Button(action: onClearImage) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.95))
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .buttonStyle(.plain)
                            .padding(10)
                        }
                    } else {
                        // Empty / Placeholder Card Mockup
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Brand.softSweep)

                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Brand.sweep, lineWidth: 1.5)
                                .opacity(0.55)

                            // Contactless & Chip icons
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Brand.blue.opacity(0.7))
                                    Spacer()
                                    Image(systemName: "creditcard")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Brand.blue.opacity(0.6))
                                }
                                .padding(14)
                                Spacer()
                            }

                            // Center Action Callout
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(Brand.sweep)

                                Text("Assign Card Skin")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text("Tap to choose photo")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(width: width, height: height)
                .shadow(color: Brand.violet.opacity(0.20), radius: 14, y: 6)
                .contentShape(Rectangle())
                .onTapGesture { onPickImage() }
            }
            .aspectRatio(1.586, contentMode: .fit)

            // Card Controls & Meta Bar (extracted to help the type-checker)
            metaBar

            // Preset picture dropdown — a grid of unlabeled thumbnails.
            if showPresets {
                presetDropdown
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(card.isSelected ? Brand.cyan.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1.2)
        )
    }

    private var metaBar: some View {
        HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { card.isSelected },
                    set: { onToggleSelected($0) }
                ))
                .labelsHidden()

                Text("Card #\(cardIndex + 1)")
                    .font(.system(size: 13, weight: .semibold))

                // Monospace Hash Pill with Copy Button
                HStack(spacing: 4) {
                    Text(card.id.prefix(8) + "…" + card.id.suffix(6))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)

                    Button {
                        UIPasteboard.general.string = card.id
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                    } label: {
                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundStyle(copied ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemFill))
                .clipShape(Capsule())

                Spacer()

                if card.uiImage != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 14))
                }

                Menu {
                    if card.originalUIImage == nil {
                        Button {
                            onPickOriginal()
                        } label: {
                            Label("Set Original for Restore…", systemImage: "photo.badge.arrow.down")
                        }
                        Text("Save a copy of your card's original artwork so Restore can bring it back later.")
                    } else {
                        Button {
                            onPickOriginal()
                        } label: {
                            Label("Change Original Image…", systemImage: "photo")
                        }
                        Button(role: .destructive) {
                            onClearOriginal()
                        } label: {
                            Label("Clear Original", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    Image(systemName: card.originalUIImage != nil ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14))
                        .foregroundStyle(card.originalUIImage != nil ? .blue : .secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Dropdown-toggle arrow for the preset picker.
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showPresets.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(showPresets ? Brand.cyan : .secondary)
                        .rotationEffect(.degrees(showPresets ? 180 : 0))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    /// The preset dropdown: a grid of card-ratio thumbnails. Tap one to flash
    /// (well, queue to flash) that gradient as the card's new skin.
    private var presetDropdown: some View {
        let columns = [GridItem(.adaptive(minimum: 110, maximum: 180), spacing: 10)]
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Pick a card picture")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(Brand.cyan)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3)) { showPresets = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(CardPresets.all) { preset in
                    let thumbSize = CGSize(width: 320, height: 202)
                    let thumb = CardPresets.render(preset, size: thumbSize)
                    Button {
                        let full = CardPresets.render(preset, size: CGSize(width: 1536, height: 969))
                        onPickPreset(full)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            showPresets = false
                        }
                    } label: {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(1.586, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                    }
                    .buttonStyle(SpringPressButton())
                }
            }
        }
        .padding(.top, 6)
    }
}

// MARK: - Wallet Cards Tab

struct WalletCardsTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var newHashText = ""
    @State private var showAddSheet = false
    enum ActiveCardPicker: Identifiable {
        case singleCard(String)
        case originalCard(String)     // Sets the Original for one card
        case bulkAll                  // Sets custom skin for all selected
        case bulkOriginal             // Sets Original for all selected
        var id: String {
            switch self {
            case .singleCard(let id): return "custom_" + id
            case .originalCard(let id): return "original_" + id
            case .bulkAll: return "bulk_all"
            case .bulkOriginal: return "bulk_original"
            }
        }
    }
    @State private var activePicker: ActiveCardPicker? = nil
    @State private var showSourceDialog: Bool = false
    @State private var isPhotosPickerPresented: Bool = false
    @State private var isDocumentPickerPresented: Bool = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showCredits = false
    @State private var showRestoreCardsConfirm = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    BrandHero(
                        subtitle: "\(vm.cards.count) card\(vm.cards.count == 1 ? "" : "s") — flash custom skins, then restore whenever.",
                        systemImage: "creditcard.and.123"
                    )
                    scannerBanner

                    if vm.cards.isEmpty {
                        walletEmptyState
                            .padding(.top, 30)
                    } else {
                        cardsList
                    }
                }
                .padding(.vertical, 4)
                .transaction { $0.animation = nil }
            }
            .transaction { $0.animation = nil }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            .navigationTitle("Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                SettingsGearToolbar(showSettings: $showSettings)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vm.toggleCardScanning()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: vm.isScanningCards ? "stop.circle.fill" : "wave.3.left.circle")
                            Text(vm.isScanningCards ? "Stop Scan" : "Scan Cards")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(vm.isScanningCards ? .red : .blue)
                    }
                    .transaction { $0.animation = nil }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAddSheet = true
                        } label: {
                            Label("Add Card Manually", systemImage: "plus")
                        }
                        if !vm.cards.isEmpty {
                            Button {
                                activePicker = .bulkAll
                                showSourceDialog = true
                            } label: {
                                Label("Set Skin for All Cards...", systemImage: "photo.on.rectangle.angled")
                            }

                            Divider()

                            Button {
                                vm.selectAllCards(true)
                            } label: {
                                Label("Select All", systemImage: "checkmark.circle")
                            }

                            Button {
                                vm.selectAllCards(false)
                            } label: {
                                Label("Deselect All", systemImage: "circle")
                            }

                            Divider()

                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    vm.clearAllCards()
                                }
                            } label: {
                                Label("Clear All Cards", systemImage: "trash")
                            }

                            Divider()

                            Button {
                                showCredits = true
                            } label: {
                                Label("Credits", systemImage: "heart.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    flashButton
                }
            }
            .sheet(isPresented: $showCredits) {
                CreditsSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet().environmentObject(vm)
            }
            .sheet(isPresented: $showAddSheet) {
                AddCardSheet(hashText: $newHashText) {
                    vm.addCardHash(newHashText)
                    newHashText = ""
                    showAddSheet = false
                }
            }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceDialog, titleVisibility: .visible) {
                Button {
                    isPhotosPickerPresented = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                Button {
                    isDocumentPickerPresented = true
                } label: {
                    Label("Choose from Files…", systemImage: "folder")
                }
                Button("Cancel", role: .cancel) {
                    activePicker = nil
                }
            }
            .confirmationDialog(
                "Restore stock card picture?",
                isPresented: $showRestoreCardsConfirm,
                titleVisibility: .visible
            ) {
                Button("Restore Selected Cards", role: .destructive) {
                    vm.restoreStockCardSkins()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    """
                    Cards with a saved Original Image will be flashed back to that artwork. Cards without one show a plain stock rendering.

                    Force-close Wallet afterwards to see the change.
                    """
                )
            }
            .photosPicker(
                isPresented: $isPhotosPickerPresented,
                selection: $selectedPhotos,
                maxSelectionCount: 1,
                matching: .images
            )
            .onChange(of: selectedPhotos) { _, items in
                guard let item = items.first, let picker = activePicker else {
                    if items.isEmpty { activePicker = nil }
                    return
                }
                let currentPicker = picker
                Task {
                    if let image = await item.loadUIImage(maxDimension: 2560) {
                        await MainActor.run {
                            switch currentPicker {
                            case .singleCard(let cardId):
                                vm.setCardImage(for: cardId, image: image)
                            case .originalCard(let cardId):
                                vm.setCardOriginalImage(for: cardId, image: image)
                            case .bulkAll:
                                vm.setSkinForAllCards(image: image)
                            case .bulkOriginal:
                                vm.setOriginalForAllCards(image: image)
                            }
                        }
                    }
                    await MainActor.run {
                        selectedPhotos = []
                        activePicker = nil
                    }
                }
            }
            .sheet(isPresented: $isDocumentPickerPresented) {
                DocumentPickerView(allowedContentTypes: [
                    .image, .png, .jpeg, .heic,
                    UTType(filenameExtension: "webp") ?? .image,
                    UTType(filenameExtension: "tiff") ?? .image
                ]) { url in
                    guard let picker = activePicker else { return }
                    if let data = try? Data(contentsOf: url),
                       let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                        switch picker {
                        case .singleCard(let cardId):
                            vm.setCardImage(for: cardId, image: image)
                        case .originalCard(let cardId):
                            vm.setCardOriginalImage(for: cardId, image: image)
                        case .bulkAll:
                            vm.setSkinForAllCards(image: image)
                        case .bulkOriginal:
                            vm.setOriginalForAllCards(image: image)
                        }
                    }
                    activePicker = nil
                }
            }
        }
    }

    @ViewBuilder
    private var scannerBanner: some View {
        if vm.isScanningCards || !vm.scanStatusText.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if vm.isScanningCards {
                        ProgressView().scaleEffect(0.85)
                        Text("Live Scanner Active")
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    } else {
                        Image(systemName: "wave.3.left.circle")
                            .foregroundStyle(.secondary)
                        Text("Scanner Status")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if vm.isScanningCards {
                        Button("Stop") {
                            vm.stopCardScanning()
                        }
                        .font(.caption.bold())
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
                Text(vm.scanStatusText)
                    .font(.caption)
                    .foregroundStyle(vm.scanStatusText.contains("stopped") || vm.scanStatusText.contains("error") ? .orange : .secondary)
            }
            .padding(14)
            .background(vm.isScanningCards ? Color.blue.opacity(0.12) : Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
            .transaction { $0.animation = nil }
        }
    }

    @ViewBuilder
    private var cardsList: some View {
        VStack(spacing: 16) {
            ForEach(vm.cards, id: \.id) { card in
                let cardIndex = vm.cards.firstIndex(where: { $0.id == card.id }) ?? 0
                WalletCardView(
                    card: card,
                    cardIndex: cardIndex,
                    onToggleSelected: { isSelected in
                        vm.setCardSelected(id: card.id, selected: isSelected)
                    },
                    onPickImage: {
                        activePicker = .singleCard(card.id)
                        showSourceDialog = true
                    },
                    onClearImage: { vm.clearCardImage(for: card.id) },
                    onDelete: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        vm.deleteCard(id: card.id)
                    },
                    onPickOriginal: {
                        activePicker = .originalCard(card.id)
                        showSourceDialog = true
                    },
                    onClearOriginal: {
                        vm.clearCardOriginalImage(for: card.id)
                    },
                    onPickPreset: { img in
                        vm.setCardImage(for: card.id, image: img)
                    }
                )
                .id(card.id)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.85).combined(with: .opacity)
                ))
            }

            if !vm.cards.isEmpty {
                Button {
                    showRestoreCardsConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.backward.circle")
                        Text("Restore Stock Card Picture")
                    }
                    .brandSecondaryButton(tint: .orange)
                }
                .buttonStyle(SpringPressButton())
                .disabled(!vm.canRestoreCardSkins)
                .opacity(vm.canRestoreCardSkins ? 1.0 : 0.5)
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if !vm.cardFlashLog.isEmpty {
                CompactLogView(
                    title: "Flash Log (\(vm.cardFlashLog.count) lines)",
                    lines: vm.cardFlashLog,
                    onClear: { vm.cardFlashLog.removeAll() }
                )
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var flashButton: some View {
        Button {
            vm.flashCards()
        } label: {
            HStack(spacing: 5) {
                if case .running = vm.cardFlashPhase {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                    Text("Flashing…")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                } else if case .done(let ok) = vm.cardFlashPhase, !ok {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .heavy))
                    Text("Retry")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                } else {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11, weight: .heavy))
                    Text("Flash")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: 30)
            .background(flashBackground, in: Capsule())
            .shadow(color: Brand.blue.opacity(0.4), radius: 6, y: 2)
            .opacity(vm.canFlashCards && vm.cardFlashPhase != .running ? 1.0 : 0.55)
        }
        .buttonStyle(SpringPressButton())
        .disabled(!vm.canFlashCards || vm.cardFlashPhase == .running)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: vm.cardFlashPhase)
    }

    private var flashBackground: AnyShapeStyle {
        if case .done(let ok) = vm.cardFlashPhase, !ok {
            return AnyShapeStyle(LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
        return AnyShapeStyle(Brand.sweep)
    }

    private var scanButtonBackground: AnyShapeStyle {
        if vm.isScanningCards {
            return AnyShapeStyle(LinearGradient(
                colors: [.red, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
        return AnyShapeStyle(Brand.sweep)
    }

    private var walletEmptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Brand.sweep)
                    .frame(width: 92, height: 92)
                    .shadow(color: Brand.violet.opacity(0.35), radius: 18, y: 6)
                Image(systemName: "creditcard.viewfinder")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("No Cards Detected Yet")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Text("1.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Tap **Scan Cards** in the toolbar above.")
                }
                HStack(alignment: .top, spacing: 10) {
                    Text("2.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("On this iPhone, **double-click the Side button** (Apple Pay), authenticate with **Face ID**, and **tap your card**.")
                }
                HStack(alignment: .top, spacing: 10) {
                    Text("3.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Your card will appear here automatically!")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Button {
                    vm.toggleCardScanning()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: vm.isScanningCards ? "stop.circle.fill" : "wave.3.left.circle")
                        Text(vm.isScanningCards ? "Stop Scan" : "Scan Cards")
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(scanButtonBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: (vm.isScanningCards ? Color.red : Brand.blue).opacity(0.35), radius: 12, y: 5)
                }
                .buttonStyle(SpringPressButton())

                Button {
                    showAddSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add Manually")
                    }
                    .brandSecondaryButton()
                }
                .buttonStyle(SpringPressButton())
            }
            .padding(.horizontal, 24)
            .transaction { $0.animation = nil }
        }
        .frame(maxWidth: .infinity)
        .transaction { $0.animation = nil }
    }
}

// MARK: - Add Card Sheet

struct AddCardSheet: View {
    @Binding var hashText: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Card Hash") {
                    TextField("Paste card hash (e.g. M6nDwZrkYbFl…)", text: $hashText, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .lineLimit(4...8)
                }
                Section {
                    Text("You can add multiple hashes at once — separate them with spaces, commas, or newlines.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { onAdd() }
                        .disabled(hashText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .bold()
                }
            }
        }
    }
}

// MARK: - Passcode Theme Tab

struct PasscodeThemeTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showCredits = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Form {
                // Hero header
                Section {
                    BrandHero(
                        subtitle: "Apply themed keypad art or design one from scratch.",
                        systemImage: "lock.rectangle.stack.fill"
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Mode picker
                Section {
                    Picker("Mode", selection: $vm.passcodeMode) {
                        ForEach(CreatorMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if vm.passcodeMode == .applyTheme {
                    ApplyThemeSection()
                } else {
                    ThemeCreatorSection()
                }

                // Flash log
                if !vm.passthmFlashLog.isEmpty {
                    Section {
                        CompactLogView(
                            title: "Flash Log (\(vm.passthmFlashLog.count) lines)",
                            lines: vm.passthmFlashLog,
                            onClear: { vm.passthmFlashLog.removeAll() }
                        )
                    }
                }
            }
            .brandForm()
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            .navigationTitle("Passcode")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                SettingsGearToolbar(showSettings: $showSettings)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCredits = true
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                    }
                }
            }
            .sheet(isPresented: $showCredits) {
                CreditsSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet().environmentObject(vm)
            }
            .onAppear { vm.scanDocumentsDirectory() }
        }
    }
}

// MARK: Apply Theme section

struct ApplyThemeSection: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        // Themes dropped directly into Documents folder
        if !vm.documentsThemes.isEmpty {
            Section {
                ForEach(vm.documentsThemes, id: \.self) { file in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Brand.sweep)
                                .frame(width: 34, height: 34)
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text(file)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button {
                            vm.loadPassthmFromDocuments(filename: file)
                        } label: {
                            Text("Load")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Brand.sweep, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("Themes in App Folder")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(Brand.blue)
            }
        }

        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Brand.cyan)
                    Text("How to load a theme")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                }
                Text("Open the Files app → On My iPhone → AirTweak, and drop your .passthm file there. It will show up above with a Load button.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    vm.scanDocumentsDirectory()
                    vm.passthmFlashLog = ["🔄 Rescanned app folder — \(vm.documentsThemes.count) theme(s) found."]
                } label: {
                    Label("Refresh app folder", systemImage: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Brand.blue)
                }
                .buttonStyle(.borderless)

                if vm.loadedTheme != nil {
                    Button(role: .destructive) {
                        vm.clearLoadedTheme()
                    } label: {
                        Label("Clear loaded theme", systemImage: "xmark.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.vertical, 4)
        }

        if let theme = vm.loadedTheme {
            Section("Interactive Lock Screen Preview") {
                KeypadPreviewView(keys: theme.keysPreview)
                    .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                    .listRowBackground(Color.clear)
            }

            Section("Theme Information") {
                LabeledContent("Files in theme", value: "\(theme.fileCount)")
                LabeledContent("Digits styled", value: "\(theme.keysPreview.count) keys")

                Button {
                    vm.adoptThemeIntoCreator()
                } label: {
                    Label("Edit in Theme Creator", systemImage: "pencil")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.bordered)
            }

            PasscodeTargetSection()

            Section {
                VStack(spacing: 12) {
                    flashButton

                    Button(role: .destructive) {
                        vm.clearLoadedTheme()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Remove / Unload Theme")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
            }
        }
    }

    @ViewBuilder
    private var flashButton: some View {
        if case .running = vm.passthmFlashPhase {
            HStack(spacing: 10) {
                ProgressView()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flashing Theme…").font(.subheadline.bold())
                    ProgressView(value: vm.passthmFlashProgress)
                }
            }
            .padding(.vertical, 4)
        } else if case .done(let ok) = vm.passthmFlashPhase, !ok {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                    Text("Retry Flash Theme")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!vm.canFlashPassthm)
        } else {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bolt.fill")
                    Text("Flash Theme to iPhone")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.canFlashPassthm)
        }
    }
}

// MARK: - Passcode Target Section (matching AirCard macOS)

struct PasscodeTargetSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showRestoreConfirmation = false

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.badge.clock")
                        .foregroundColor(.blue)
                        .font(.headline)
                    Text("Flash & Language Target")
                        .font(.headline)
                }

                // 1. Target System
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Caches")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("System Caches", selection: $vm.targetTelephonyVersion) {
                        Text("TelephonyUI-10 (iOS 18+)").tag("TelephonyUI-10")
                        Text("TelephonyUI-9 (iOS 16–17)").tag("TelephonyUI-9")
                        Text("TelephonyUI-8 (iOS 14–15)").tag("TelephonyUI-8")
                        Text("Universal (All)").tag("all")
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Divider()

                // 2. System Language
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Language")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("System Language", selection: $vm.passcodeLanguageTarget) {
                        ForEach(PasscodeLanguageTarget.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Divider()

                // 3. Font Weight / Style
                VStack(alignment: .leading, spacing: 4) {
                    Text("Font Weight / Style")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("Font Weight / Style", selection: $vm.passcodeBoldTarget) {
                        ForEach(PasscodeBoldTarget.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                // Dynamic hint
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both ? "globe" : "bolt.fill")
                        .font(.caption)
                        .foregroundColor(vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both ? .secondary : .orange)
                        .padding(.top, 1)

                    if vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both {
                        Text("Universal mode flashes ~600 files for all languages & Bold text. Selecting a specific language (e.g. Ukrainian) speeds up flashing dramatically.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("Fast mode selected: only targets \(vm.passcodeLanguageTarget.rawValue) with \(vm.passcodeBoldTarget.rawValue).")
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stock Passcode")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)

                    if case .running = vm.passthmRestorePhase {
                        HStack(spacing: 10) {
                            ProgressView()

                            Text("Backing up custom keypad assets…")
                                .font(.subheadline)
                        }

                    } else {
                        Button(role: .destructive) {
                            showRestoreConfirmation = true
                        } label: {
                            Label(
                                "Restore Stock Passcode",
                                systemImage: "arrow.uturn.backward.circle"
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                        }
                        .buttonStyle(.bordered)
                        .disabled(!vm.canRestorePassthm)
                    }

                    if case .done(let ok) = vm.passthmRestorePhase,
                       ok {
                        Button {
                            vm.respringAfterPasscodeRestore()
                        } label: {
                            Label(
                                "Respring for Stock Passcode",
                                systemImage: "arrow.clockwise.circle.fill"
                            )
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if !vm.passthmRestoreLog.isEmpty {
                        Text(
                            vm.passthmRestoreLog
                                .suffix(5)
                                .joined(separator: "\n")
                        )
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .confirmationDialog(
            "Restore the Apple passcode keypad?",
            isPresented: $showRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Back Up Theme & Restore Stock",
                role: .destructive
            ) {
                vm.restoreStockPasscode()
            }

            Button("Cancel", role: .cancel) {}

        } message: {
            Text(
                """
                AirCard will move the custom keypad files — matching the loaded theme, or all 0–9 keys if none is loaded — out of TelephonyUI.

                They will be backed up under /var/mobile/Media before you respring.
                """
            )
        }
    }
}

// MARK: Theme Creator section

struct ThemeCreatorSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedDigitForPicker: String? = nil
    @State private var showKeySourceDialog: Bool = false
    @State private var isKeyPhotosPickerPresented: Bool = false
    @State private var isKeyDocumentPickerPresented: Bool = false
    @State private var selectedKey: [PhotosPickerItem] = []

    @State private var showPosterSourceDialog: Bool = false
    @State private var isPosterPhotosPickerPresented: Bool = false
    @State private var isPosterDocumentPickerPresented: Bool = false
    @State private var selectedPoster: [PhotosPickerItem] = []

    var body: some View {
        Section("Slice Mode") {
            Picker("", selection: $vm.sliceMode) {
                ForEach(SliceMode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
        }

        if vm.sliceMode == .posterSlice {
            posterSliceSection
        } else {
            individualKeysSection
        }

        // Preview
        Section("Interactive Lock Screen Preview") {
            KeypadPreviewView(keys: vm.effectiveKeys)
                .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                .listRowBackground(Color.clear)
        }

        PasscodeTargetSection()

        // Action Section
        Section {
            VStack(spacing: 12) {
                flashButton

                if !vm.effectiveKeys.isEmpty {
                    Button {
                        _ = vm.exportPassthm()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Export .passthm...")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        vm.clearAllCreator()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Clear All")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
        }
    }

    private var posterSliceSection: some View {
        Group {
            Section("Poster Image") {
                Button {
                    showPosterSourceDialog = true
                } label: {
                    Label(vm.posterImage == nil ? "Select Photo for Keypad…" : "Change Photo…",
                          systemImage: "photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .confirmationDialog("Choose Poster Image Source", isPresented: $showPosterSourceDialog, titleVisibility: .visible) {
                Button {
                    isPosterPhotosPickerPresented = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                Button {
                    isPosterDocumentPickerPresented = true
                } label: {
                    Label("Choose from Files…", systemImage: "folder")
                }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(
                isPresented: $isPosterPhotosPickerPresented,
                selection: $selectedPoster,
                maxSelectionCount: 1,
                matching: .images
            )
            .onChange(of: selectedPoster) { _, items in
                guard let item = items.first else { return }
                Task {
                    if let image = await item.loadUIImage(maxDimension: 2560) {
                        await MainActor.run { vm.setPosterImage(image) }
                    }
                    await MainActor.run { selectedPoster = [] }
                }
            }
            .sheet(isPresented: $isPosterDocumentPickerPresented) {
                DocumentPickerView(allowedContentTypes: [
                    .image, .png, .jpeg, .heic,
                    UTType(filenameExtension: "webp") ?? .image,
                    UTType(filenameExtension: "tiff") ?? .image
                ]) { url in
                    if let data = try? Data(contentsOf: url),
                       let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                        vm.setPosterImage(image)
                    }
                }
            }

            if vm.posterImage != nil {
                Section("Slicing Style") {
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("", selection: $vm.maskToCircles) {
                            Text("Seamless Poster").tag(false)
                            Text("Circle Buttons").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: vm.maskToCircles) { _, _ in
                            vm.updatePosterSlicing()
                        }

                        Text(vm.maskToCircles ? "Artwork is clipped into individual circular button icons." : "Seamless artwork spans across dialer keys without circular cuts (Adobe Dog style).")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Zoom & Framing")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Reset Position") {
                                withAnimation(.spring()) {
                                    vm.resetPosterPosition()
                                }
                            }
                            .font(.caption2)
                            .buttonStyle(.borderless)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "minus.magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Slider(value: $vm.posterZoom, in: 0.5...3.0, step: 0.05)
                                .onChange(of: vm.posterZoom) { _, _ in
                                    vm.updatePosterSlicing()
                                }

                            Image(systemName: "plus.magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Text(String(format: "%.1fx", vm.posterZoom))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .frame(width: 38, alignment: .trailing)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "hand.draw")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                            Text("Drag anywhere on the dialer preview to reposition")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var individualKeysSection: some View {
        Section("Individual Keys") {
            Text("Tap a button row to assign a custom image.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(KeypadLayout.allButtons) { btn in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 44, height: 44)
                        if let img = vm.customKeys[btn.digit] {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        } else {
                            Text(btn.digit)
                                .font(.title3.bold())
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Key \(btn.digit)")
                            .font(.subheadline.weight(.medium))
                        if !btn.letters.isEmpty {
                            Text(btn.letters)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if vm.customKeys[btn.digit] != nil {
                        Button(role: .destructive) {
                            vm.clearIndividualKey(digit: btn.digit)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDigitForPicker = btn.digit
                    showKeySourceDialog = true
                }
            }
        }
        .confirmationDialog("Choose Key \(selectedDigitForPicker ?? "") Image Source", isPresented: $showKeySourceDialog, titleVisibility: .visible) {
            Button {
                isKeyPhotosPickerPresented = true
            } label: {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }
            Button {
                isKeyDocumentPickerPresented = true
            } label: {
                Label("Choose from Files…", systemImage: "folder")
            }
            Button("Cancel", role: .cancel) {
                selectedDigitForPicker = nil
            }
        }
        .photosPicker(
            isPresented: $isKeyPhotosPickerPresented,
            selection: $selectedKey,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: selectedKey) { _, items in
            guard let item = items.first,
                  let digit = selectedDigitForPicker else {
                if items.isEmpty { selectedDigitForPicker = nil }
                return
            }
            let currentDigit = digit
            Task {
                if let image = await item.loadUIImage(maxDimension: 1024) {
                    await MainActor.run { vm.setIndividualKey(digit: currentDigit, image: image) }
                }
                await MainActor.run {
                    selectedKey = []
                    selectedDigitForPicker = nil
                }
            }
        }
        .sheet(isPresented: $isKeyDocumentPickerPresented) {
            DocumentPickerView(allowedContentTypes: [
                .image, .png, .jpeg, .heic,
                UTType(filenameExtension: "webp") ?? .image,
                UTType(filenameExtension: "tiff") ?? .image
            ]) { url in
                guard let digit = selectedDigitForPicker else { return }
                if let data = try? Data(contentsOf: url),
                   let image = ImageEngine.safeImageFromData(data, maxDimension: 1024) {
                    vm.setIndividualKey(digit: digit, image: image)
                }
                selectedDigitForPicker = nil
            }
        }
    }

    @ViewBuilder
    private var flashButton: some View {
        if case .running = vm.passthmFlashPhase {
            HStack(spacing: 10) {
                ProgressView()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flashing Theme…").font(.subheadline.bold())
                    ProgressView(value: vm.passthmFlashProgress)
                }
            }
            .padding(.vertical, 4)
        } else if case .done(let ok) = vm.passthmFlashPhase, !ok {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                    Text("Retry Flash Theme")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!vm.canFlashPassthm)
        } else {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bolt.fill")
                    Text("Flash Theme to iPhone")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.canFlashPassthm)
        }
    }
}

// MARK: - Keypad Preview (clean modern lock screen dialer preview)

struct KeypadPreviewView: View {
    @EnvironmentObject var vm: AppViewModel
    let keys: [String: UIImage]

    @State private var dragOffsetStart: CGPoint = .zero
    @State private var isDragging: Bool = false

    private func scaledPosterDimensions(for poster: UIImage, gridW: CGFloat, gridH: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let imgW = poster.size.width
        let imgH = poster.size.height
        guard imgW > 0, imgH > 0 else { return (gridW, gridH) }

        let imgAspect = imgW / imgH
        let gridAspect = gridW / gridH

        if imgAspect > gridAspect {
            let h = gridH * vm.posterZoom
            return (width: h * imgAspect, height: h)
        } else {
            let w = gridW * vm.posterZoom
            return (width: w, height: w / imgAspect)
        }
    }

    var body: some View {
        let scale: CGFloat = 0.68
        let btnD: CGFloat = KeypadLayout.buttonDiameter * scale
        let colW: CGFloat = KeypadLayout.colWidth * scale
        let rowH: CGFloat = KeypadLayout.rowHeight * scale
        let gridW: CGFloat = KeypadLayout.gridWidth * scale
        let gridH: CGFloat = KeypadLayout.gridHeight * scale

        let isSeamlessPoster = (vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && !vm.maskToCircles && vm.posterImage != nil)

        ZStack {
            // Dark luxury frosted card backdrop
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09))

            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.clear, Color.black.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 12) {
                // Keypad grid
                ZStack {
                    // Layer 1: Background wallpaper in Seamless Poster mode
                    if isSeamlessPoster, let poster = vm.posterImage {
                        let dims = scaledPosterDimensions(for: poster, gridW: gridW, gridH: gridH)
                        Image(uiImage: poster)
                            .resizable()
                            .frame(width: dims.width, height: dims.height)
                            .position(
                                x: gridW / 2.0 + (vm.posterOffset.x * scale),
                                y: gridH / 2.0 + (vm.posterOffset.y * scale)
                            )
                    }

                    // Layer 2: 10 Keypad buttons
                    ForEach(KeypadLayout.allButtons) { btn in
                        let cx = CGFloat(btn.col) * colW + colW / 2
                        let cy = CGFloat(btn.row) * rowH + rowH / 2

                        keypadButton(btn: btn, btnD: btnD, scale: scale, isSeamlessPoster: isSeamlessPoster)
                            .position(x: cx, y: cy)
                    }
                }
                .frame(width: gridW, height: gridH)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            if vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil {
                                if !isDragging {
                                    isDragging = true
                                    dragOffsetStart = vm.posterOffset
                                }
                                vm.posterOffset = CGPoint(
                                    x: dragOffsetStart.x + value.translation.width / scale,
                                    y: dragOffsetStart.y + value.translation.height / scale
                                )
                                vm.updatePosterSlicing()
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            dragOffsetStart = vm.posterOffset
                        }
                )

                // Drag hint pill (only shown when dragging poster is possible)
                if vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 10))
                        Text("Drag preview to reposition")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: (vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil) ? 320 : 295)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func keypadButton(btn: KeypadButtonGeometry, btnD: CGFloat, scale: CGFloat, isSeamlessPoster: Bool) -> some View {
        ZStack {
            if isSeamlessPoster {
                // Seamless mode: Frosted glass touch target ring
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: btnD, height: btnD)

                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.0)
                    .frame(width: btnD, height: btnD)

                VStack(spacing: 0) {
                    Text(btn.digit)
                        .font(.system(size: 26 * scale, weight: .light))
                        .foregroundStyle(.white.opacity(0.95))
                    if !btn.letters.isEmpty {
                        Text(btn.letters)
                            .font(.system(size: 8.5 * scale, weight: .semibold))
                            .tracking(0.8 * scale)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            } else if let img = keys[btn.digit] {
                // Custom theme button: Pure artwork without clashing superimposed text!
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: btnD, height: btnD)

                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: btnD, height: btnD)
                    .clipShape(Circle())

                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    .frame(width: btnD, height: btnD)
            } else {
                // Default iOS dialer style for unstyled buttons
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: btnD, height: btnD)

                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    .frame(width: btnD, height: btnD)

                VStack(spacing: 0) {
                    Text(btn.digit)
                        .font(.system(size: 26 * scale, weight: .light))
                        .foregroundStyle(.white)
                    if !btn.letters.isEmpty {
                        Text(btn.letters)
                            .font(.system(size: 8.5 * scale, weight: .semibold))
                            .tracking(0.8 * scale)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
        }
        .frame(width: btnD, height: btnD)
    }
}
