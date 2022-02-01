import Foundation
import TextStory

public class LineLeadingWhitespaceFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public let provider: StringSubstitutionProvider

    init(string: String, provider: @escaping StringSubstitutionProvider) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
        self.provider = provider
    }

    public var string: String {
        return recognizer.matchingString
    }

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        storage.applyMutation(mutation)

        guard let whitespaceRange = storage.leadingWhitespaceRange(containing: mutation.range.location) else {
            return .none
        }

        let value = provider(whitespaceRange, storage)

        storage.replaceString(in: whitespaceRange, with: value)

        return .discard
    }
}

extension LineLeadingWhitespaceFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        recognizer.processMutation(mutation)

        switch recognizer.state {
        case .triggered:
            return filterHandler(mutation, in: storage)
        case .tracking, .idle:
            return .none
        }
    }
}