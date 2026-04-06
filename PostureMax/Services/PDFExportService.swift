import UIKit
import SwiftData

struct PDFExportService {
    static func generateReport(
        profile: UserProfile,
        logs: [DailyLog],
        photos: [PosturePhoto],
        streak: StreakRecord
    ) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        let data = pdfRenderer.pdfData { context in
            // Title Page
            context.beginPage()
            var yOffset: CGFloat = margin

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.systemTeal
            ]
            let title = "PostureMax Progress Report"
            title.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: titleAttrs)
            yOffset += 45

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let subtitle = "Prepared for \(profile.displayName)"
            subtitle.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: subtitleAttrs)
            yOffset += 25

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateStr = "Generated: \(dateFormatter.string(from: Date()))"
            dateStr.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: subtitleAttrs)
            yOffset += 50

            // Summary Section
            let headingAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            "Summary".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headingAttrs)
            yOffset += 35

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.label
            ]

            let summaryLines = [
                "Current Streak: \(streak.currentStreak) days",
                "Longest Streak: \(streak.longestStreak) days",
                "Total Days Logged: \(streak.totalDaysLogged)",
                "Total Progress Photos: \(photos.count)",
                ""
            ]

            for line in summaryLines {
                line.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: bodyAttrs)
                yOffset += 22
            }

            // Average scores
            if !logs.isEmpty {
                yOffset += 10
                "Averages (Last 30 Logs)".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headingAttrs)
                yOffset += 35

                let recentLogs = Array(logs.suffix(30))
                let avgPosture = recentLogs.map(\.postureRating).reduce(0, +) / max(recentLogs.count, 1)
                let avgPain = recentLogs.map(\.painLevel).reduce(0, +) / max(recentLogs.count, 1)
                let avgNeck = recentLogs.map(\.neckAlignment).reduce(0, +) / max(recentLogs.count, 1)
                let avgShoulder = recentLogs.map(\.shoulderBalance).reduce(0, +) / max(recentLogs.count, 1)
                let avgSpine = recentLogs.map(\.spineAlignment).reduce(0, +) / max(recentLogs.count, 1)

                let avgLines = [
                    "Average Posture Rating: \(avgPosture)/10",
                    "Average Pain Level: \(avgPain)/10",
                    "Average Neck Alignment: \(avgNeck)/10",
                    "Average Shoulder Balance: \(avgShoulder)/10",
                    "Average Spine Alignment: \(avgSpine)/10"
                ]

                for line in avgLines {
                    line.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 22
                }
            }

            // Daily Log Details Page
            if !logs.isEmpty {
                context.beginPage()
                yOffset = margin
                "Daily Log History".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headingAttrs)
                yOffset += 35

                let logDateFormatter = DateFormatter()
                logDateFormatter.dateStyle = .medium

                for log in logs.suffix(20) {
                    if yOffset > pageHeight - 100 {
                        context.beginPage()
                        yOffset = margin
                    }

                    let logLine = "\(logDateFormatter.string(from: log.date)) — Posture: \(log.postureRating)/10, Pain: \(log.painLevel)/10"
                    logLine.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 20

                    if !log.notes.isEmpty {
                        let noteLine = "  Notes: \(log.notes)"
                        let constrainedRect = CGRect(x: margin + 10, y: yOffset, width: pageWidth - 2 * margin - 10, height: 40)
                        noteLine.draw(in: constrainedRect, withAttributes: [
                            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                            .foregroundColor: UIColor.secondaryLabel
                        ])
                        yOffset += 30
                    }

                    yOffset += 10
                }
            }
        }

        return data
    }
}
