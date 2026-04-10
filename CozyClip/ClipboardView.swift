import SwiftUI

struct ClipboardView: View {
    @ObservedObject var manager: ClipboardManager
    @State private var searchText = ""
    @State private var copiedItemId: UUID?
    @State private var showClearConfirm = false

    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return manager.items
        }
        return manager.items.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("CozyClip")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !manager.items.isEmpty {
                    Button(action: { showClearConfirm = true }) {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .alert("Clear all clips?", isPresented: $showClearConfirm) {
                        Button("Clear", role: .destructive) { manager.clearAll() }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                TextField("Search clips...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            Divider()

            // Clips list
            if filteredItems.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(manager.items.isEmpty ? "Nothing copied yet" : "No matches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredItems) { item in
                            ClipItemRow(
                                item: item,
                                isCopied: copiedItemId == item.id,
                                onCopy: {
                                    manager.copyToClipboard(item)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        copiedItemId = item.id
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation { copiedItemId = nil }
                                    }
                                },
                                onDelete: { manager.delete(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(width: 320, height: 420)
    }
}

struct ClipItemRow: View {
    let item: ClipboardItem
    let isCopied: Bool
    let onCopy: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .font(.system(size: 12.5))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(timeAgo(item.date))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if isHovering || isCopied {
                HStack(spacing: 4) {
                    Button(action: onCopy) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                            .foregroundColor(isCopied ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onCopy()
        }
    }

    func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}
