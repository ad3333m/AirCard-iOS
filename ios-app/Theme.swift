import SwiftUI

// MARK: - Brand palette

/// Brand colors mirror the AirTweak app icon: violet → blue → cyan.
enum Brand {
    static let violet = Color(red: 0x7C/255.0, green: 0x4D/255.0, blue: 0xFF/255.0)
    static let blue   = Color(red: 0x35/255.0, green: 0x8C/255.0, blue: 0xFF/255.0)
    static let cyan   = Color(red: 0x1E/255.0, green: 0xE0/255.0, blue: 0xD0/255.0)

    /// Diagonal violet → blue → cyan sweep used across headers & primary buttons.
    static let sweep = LinearGradient(
        colors: [violet, blue, cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Softer sweep for section backgrounds so text stays readable.
    static let softSweep = LinearGradient(
        colors: [
            violet.opacity(0.18),
            blue.opacity(0.14),
            cyan.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Purely dark background so the neon accents pop even in light mode.
    static let deep = Color(red: 0x0C/255.0, green: 0x10/255.0, blue: 0x22/255.0)
}

// MARK: - Reusable modifiers

/// Chunky, gradient-filled primary action button.
struct BrandPrimaryButton: ViewModifier {
    var enabled: Bool = true
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Group {
                    if enabled {
                        Brand.sweep
                    } else {
                        Color.gray.opacity(0.35)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: enabled ? Brand.blue.opacity(0.35) : .clear,
                    radius: 14, x: 0, y: 6)
    }
}

/// Softer secondary button — outlined, with brand-tinted border.
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

/// Frosted glass-style card panel (used for section groupings).
struct GlassCard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func brandPrimaryButton(enabled: Bool = true) -> some View {
        modifier(BrandPrimaryButton(enabled: enabled))
    }
    func brandSecondaryButton(tint: Color = Brand.blue) -> some View {
        modifier(BrandSecondaryButton(tint: tint))
    }
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCard(padding: padding))
    }
}

// MARK: - Hero header

/// Big gradient title that sits above the content area on each tab.
struct BrandHero: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Brand.sweep)
                    .frame(width: 46, height: 46)
                    .shadow(color: Brand.violet.opacity(0.4), radius: 10, y: 4)
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        Brand.sweep
                    )
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
