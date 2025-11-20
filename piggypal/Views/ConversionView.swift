//
//  ConversionView.swift
//  piggypal
//
//  Created by csuftitan on 11/13/25.
//

import SwiftUI

// API access key (may need to change if publish since free trial only allows 100 requests)
private let EXCHANGE_HOST_API_KEY = "0fbeedb0e51d871fc005bfd77c89c06c"

// Color
extension Color {
    static let pigPinkPrimary  = Color(hex: 0xFFC9D4)
    static let pigPinkAccent   = Color(hex: 0xFE9FB1)
    static let pigRoseDeep     = Color(hex: 0xAD646E)
    static let pigCoinYellow   = Color(hex: 0xFCDE7E)
    static let pigGoldMuted    = Color(hex: 0xE6C985)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8)  & 0xff) / 255,
                  blue:  Double((hex)       & 0xff) / 255,
                  opacity: alpha)
    }
}

// Helpers for currency code list
private let preferredCodes = ["USD","EUR","JPY","GBP","AUD","CAD","CNY","KRW","INR","MXN"]

// Keeps order
struct LinkedHashSet<T: Hashable>: Sequence {
    private var seen = Set<T>()
    private var items: [T] = []
    init(_ array: [T]) {
        for x in array where !seen.contains(x) {
            seen.insert(x)
            items.append(x)
        }
    }
    func makeIterator() -> IndexingIterator<[T]> { items.makeIterator() }
}

private func buildCodes() -> [String] {
    let merged = Array(LinkedHashSet(preferredCodes + Locale.commonISOCurrencyCodes))
    // most popular currency codes at the top and rest alphabetically
    return merged.sorted { lhs, rhs in
        let li = preferredCodes.firstIndex(of: lhs)
        let ri = preferredCodes.firstIndex(of: rhs)
        if li != nil || ri != nil { return (li ?? .max) < (ri ?? .max) }
        return lhs < rhs
    }
}

// MARK: - Main View
struct ConversionView: View {
    // User input (live selections)
    @State private var amountText: String = ""
    @State private var fromCode: String = "USD"
    @State private var toCode:   String = "EUR"

    // Result state (live)
    @State private var lastUpdated: Date? = nil
    @State private var converted: Double? = nil
    @State private var effectiveRate: Double = 0

    // 👇 Display state (frozen until you tap Convert)
    @State private var displayFromCode: String? = nil
    @State private var displayToCode: String? = nil
    @State private var displayAmount: Double? = nil

    // API loading and error states
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Currency codes
    @State private var codes: [String] = buildCodes()

    // Conversion history
    @State private var history: [String] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    amountCard
                    currencyRow
                    rateChip
                    convertButton
                    resultCard
                    if !history.isEmpty { recentList }
                }
                .padding(20)
            }
            .background(Color.white)
            .navigationTitle("Convert")
            // Fetch rate automatically on load and currency changes
            .task { fetchOneUnitRate() }
            .onChange(of: fromCode) { _ in fetchOneUnitRate() }
            .onChange(of: toCode)   { _ in fetchOneUnitRate() }
            // Error
            .alert("Conversion Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    // UI Components
    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.7))

            HStack(spacing: 12) {
                TextField("Enter amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.black)

                Button(action: swapCurrencies) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(12)
                        .background(Color.pigPinkAccent)
                        .clipShape(Circle())
                }
            }

            Text("Uses latest rate")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.6))
        }
        .padding(16)
        .background(Color.pigPinkPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.pigRoseDeep.opacity(0.15), radius: 12, y: 6)
    }

    private var currencyRow: some View {
        HStack(spacing: 12) {
            currencyPill(selection: $fromCode, label: "From")
            Spacer(minLength: 12)
            currencyPill(selection: $toCode, label: "To")
        }
    }

    private func currencyPill(selection: Binding<String>, label: String) -> some View {
        Menu {
            ForEach(codes, id: \.self) { code in
                Button {
                    selection.wrappedValue = code
                } label: {
                    HStack {
                        Text(code).bold()
                        Spacer()
                        if selection.wrappedValue == code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.pigPinkAccent)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selection.wrappedValue)
                    .bold()
                    .foregroundStyle(.black.opacity(0.7))
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 999).stroke(Color.pigGoldMuted, lineWidth: 1))
            .clipShape(Capsule())
        }
    }

    private var rateChip: some View {
        let rateText: String = effectiveRate > 0
            ? "1 \(fromCode) = \(trimRate(effectiveRate)) \(toCode)"
            : (isLoading ? "Loading rate..." : "Rate not loaded")

        return HStack(spacing: 8) {
            Text(chipText(rateText))
                .font(.footnote)
            if isLoading { ProgressView().scaleEffect(0.8) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.pigGoldMuted)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var convertButton: some View {
        Button(action: convert) {
            Text(isLoading ? "Converting…" : "Convert")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(.black)
                .background(Color.pigCoinYellow)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .opacity(amountIsValid && !isLoading ? 1 : 0.5)
        .disabled(!amountIsValid || isLoading)
        .shadow(color: Color.pigRoseDeep.opacity(0.12), radius: 10, y: 5)
    }

    private var resultCard: some View {
        // Use the *display* (frozen) codes/amount so symbols don’t change until Convert
        let dispTo = displayToCode
        let dispFrom = displayFromCode
        let dispAmount = displayAmount

        return VStack(alignment: .leading, spacing: 10) {
            Text("Converted Amount")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.7))

            Text(displayResultTop(dispTo: dispTo))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.black)
                .minimumScaleFactor(0.5)

            if let amt = dispAmount, let from = dispFrom, effectiveRate > 0 {
                Text("from \(formatMoney(amt, code: from))")
                    .font(.footnote)
                    .foregroundStyle(.black.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.pigPinkPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.pigRoseDeep.opacity(0.15), radius: 12, y: 6)
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Conversions")
                .font(.headline)

            ForEach(history.indices, id: \.self) { i in
                HStack {
                    Rectangle()
                        .fill(Color.pigPinkAccent)
                        .frame(width: 4)
                    Text(history[i])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.leading, 8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.top, 4)
    }

    // Logic functions
    private var amountIsValid: Bool {
        Double(amountText.filter { "0123456789.".contains($0) }) != nil
    }

    private func swapCurrencies() {
        (fromCode, toCode) = (toCode, fromCode)
        if amountIsValid { convert() } else { fetchOneUnitRate() }
    }

    private func fetchOneUnitRate() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let out = try await RateService.shared.convert(from: fromCode, to: toCode, amount: 1)
                self.effectiveRate = out.rate
                self.lastUpdated = out.date
            } catch {
                self.errorMessage = (error as? RateService.ServiceError)?.friendlyMessage ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    private func convert() {
        guard let amount = Double(amountText.filter { "0123456789.".contains($0) }) else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let out = try await RateService.shared.convert(from: fromCode, to: toCode, amount: amount)
                self.effectiveRate = out.rate
                self.converted = out.result
                self.lastUpdated = out.date

                // Freeze display until convert button is clicked again
                self.displayFromCode = fromCode
                self.displayToCode = toCode
                self.displayAmount = amount

                let resultString = "\(formatMoney(amount, code: fromCode)) → \(formatMoney(out.result, code: toCode))"
                let line = "\(fromCode)→\(toCode) · \(resultString)"
                self.history.insert(line, at: 0)
                if self.history.count > 5 { self.history.removeLast() }
            } catch {
                self.errorMessage = (error as? RateService.ServiceError)?.friendlyMessage ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    private func formatMoney(_ value: Double, code: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        return f.string(from: NSNumber(value: value)) ?? "\(value) \(code)"
    }

    private func displayResultTop(dispTo: String?) -> String {
        if let converted, let to = dispTo {
            return formatMoney(converted, code: to)
        }
        return "Your result will appear here"
    }

    private func chipText(_ rate: String) -> String {
        if let lastUpdated {
            let rel = RelativeDateTimeFormatter()
            rel.unitsStyle = .short
            let ago = rel.localizedString(for: lastUpdated, relativeTo: Date())
            return "\(rate) · updated \(ago)"
        }
        return rate
    }

    private func trimRate(_ r: Double) -> String {
        String(format: "%.4f", r)
    }
}

// Networking layer for exchangerate.host API
final class RateService {
    static let shared = RateService()
    private init() {}

    enum ServiceError: Error {
        case badURL, httpError(Int), decodingFailed, apiFailure(String)
        var friendlyMessage: String {
            switch self {
            case .badURL: return "Could not create request."
            case .httpError(let code): return "Network error (\(code))."
            case .decodingFailed: return "Could not read the exchange rate."
            case .apiFailure(let msg): return msg.isEmpty ? "The exchange service returned an error." : msg
            }
        }
    }

    struct HostConvertResponse: Decodable {
        let success: Bool?
        let date: String?
        let result: Double?
        let info: Info?
        struct Info: Decodable { let rate: Double? }
        struct ErrorObj: Decodable { let type: String?, code: String?, info: String? }
        let error: ErrorObj?
    }

    // Calls exchangerate.host then outputs unit rate, conversion result, and date
    func convert(from: String, to: String, amount: Double) async throws -> (rate: Double, result: Double, date: Date?) {
        guard let url = url_host(from: from, to: to, amount: amount) else {
            throw ServiceError.badURL
        }

        let (data, resp) = try await URLSession.shared.data(from: url)
        try check(resp)

        guard let decoded = try? JSONDecoder().decode(HostConvertResponse.self, from: data) else {
            throw ServiceError.decodingFailed
        }
        if let e = decoded.error?.info { throw ServiceError.apiFailure(e) }
        guard (decoded.success ?? true), let res = decoded.result else {
            throw ServiceError.decodingFailed
        }
        let rate = decoded.info?.rate ?? (res / max(amount, 1e-9))
        return (rate, res, parseDate(decoded.date))
    }

    // Helpers
    private func check(_ resp: URLResponse) throws {
        guard let http = resp as? HTTPURLResponse else { throw ServiceError.apiFailure("Bad response") }
        guard (200..<300).contains(http.statusCode) else { throw ServiceError.httpError(http.statusCode) }
    }

    private func url_host(from: String, to: String, amount: Double) -> URL? {
        var comps = URLComponents(string: "https://api.exchangerate.host/convert")
        var q: [URLQueryItem] = [
            .init(name: "from", value: from),
            .init(name: "to", value: to),
            .init(name: "amount", value: String(amount))
        ]
        if !EXCHANGE_HOST_API_KEY.isEmpty {
            // Some deployments accept access_key; exchangerate.host itself usually doesn't require it.
            q.append(.init(name: "access_key", value: EXCHANGE_HOST_API_KEY))
        }
        comps?.queryItems = q
        return comps?.url
    }

    private func parseDate(_ s: String?) -> Date? {
        guard let s else { return nil }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .init(secondsFromGMT: 0)
        return df.date(from: s)
    }
}

#Preview {
    ConversionView()
}
