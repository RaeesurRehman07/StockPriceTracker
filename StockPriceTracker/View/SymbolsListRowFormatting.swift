import UIKit

// MARK: - SymbolsListRowFormatting - 

enum SymbolsListRowFormatting {

    private static let changeEpsilon = 0.0001

    static func detailAttributed(for item: SymbolsListItemViewModel) -> NSAttributedString {
        guard let quote = item.quote else {
            return NSAttributedString(
                string: "Waiting for price…",
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .subheadline),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        }

        return makePriceChangeAttributed(price: quote.price, change: quote.change)
    }

    private static func makePriceChangeAttributed(price: Double, change: Double) -> NSAttributedString {
        let priceText = String(format: "$%.2f", price)
        let bodyFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let priceColor = UIColor.label

        let (arrowName, changeColor): (String, UIColor)
        if change > changeEpsilon {
            arrowName = "arrowtriangle.up.fill"
            changeColor = UIColor.systemGreen
        } else if change < -changeEpsilon {
            arrowName = "arrowtriangle.down.fill"
            changeColor = UIColor.systemRed
        } else {
            arrowName = "equal.circle.fill"
            changeColor = UIColor.secondaryLabel
        }

        let changeText = String(format: "%+.2f", change)

        let result = NSMutableAttributedString(
            string: priceText,
            attributes: [
                .font: bodyFont,
                .foregroundColor: priceColor
            ]
        )

        result.append(NSAttributedString(string: " · ", attributes: [
            .font: bodyFont,
            .foregroundColor: UIColor.secondaryLabel
        ]))

        if let attachment = makeSymbolAttachment(name: arrowName, color: changeColor, font: bodyFont) {
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: " ", attributes: [.font: bodyFont]))
        }

        result.append(NSAttributedString(string: changeText, attributes: [
            .font: bodyFont,
            .foregroundColor: changeColor
        ]))

        return result
    }

    private static func makeSymbolAttachment(name: String, color: UIColor, font: UIFont) -> NSTextAttachment? {
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        guard let image = UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal) else {
            return nil
        }
        let attachment = NSTextAttachment()
        attachment.image = image
        let capHeight = font.capHeight
        let yOffset = (capHeight - image.size.height) / 2
        attachment.bounds = CGRect(x: 0, y: yOffset, width: image.size.width, height: image.size.height)
        return attachment
    }
}
