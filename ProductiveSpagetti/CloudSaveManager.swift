import Foundation
import CloudKit
import Combine

@MainActor
final class CloudSaveManager {

    static let shared = CloudSaveManager()

    private let container = CKContainer.default()

    private let recordID = CKRecord.ID(
        recordName: "ProductiveSpagettiSave"
    )

    private var saveTask: Task<Void, Never>?
    private var isRestoring = false
    private var cancellable: AnyCancellable?

    private init() {}

    // MARK: - Auto Save

    func startAutoSave() {

        cancellable = NotificationCenter.default
            .publisher(
                for: UserDefaults.didChangeNotification,
                object: UserDefaults.standard
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

                guard let self else { return }
                guard !self.isRestoring else { return }

                self.scheduleSave()
            }

        print("✅ Cloud auto-save started")
    }

    private func scheduleSave() {

        saveTask?.cancel()

        saveTask = Task { [weak self] in

            try? await Task.sleep(
                for: .seconds(1)
            )

            guard !Task.isCancelled else {
                return
            }

            await self?.saveAllAppData()
        }
    }

    // MARK: - Save

    func saveAllAppData() async {

        guard await isICloudAvailable() else {
            return
        }

        let database = container.privateCloudDatabase

        do {

            let data = try encodeAppStorage()

            let record: CKRecord

            do {

                record = try await database.record(
                    for: recordID
                )

            } catch let error as CKError
                    where error.code == .unknownItem {

                record = CKRecord(
                    recordType: "AppSave",
                    recordID: recordID
                )
            }

            record["data"] = data as CKRecordValue
            record["updatedAt"] = Date() as CKRecordValue

            try await database.save(record)

            print("☁️ App data automatically saved")

        } catch {

            print(
                "❌ Cloud save failed:",
                error
            )
        }
    }

    // MARK: - Load

    func loadAllAppData() async {

        guard await isICloudAvailable() else {
            return
        }

        let database = container.privateCloudDatabase

        do {

            let record = try await database.record(
                for: recordID
            )

            guard let data =
                    record["data"] as? Data
            else {
                return
            }

            isRestoring = true

            defer {
                isRestoring = false
            }

            try restoreAppStorage(from: data)

            print("☁️ App data loaded")

        } catch let error as CKError
                where error.code == .unknownItem {

            print("ℹ️ No cloud save yet")

        } catch {

            print(
                "❌ Cloud load failed:",
                error
            )
        }
    }

    // MARK: - iCloud Check

    private func isICloudAvailable() async -> Bool {

        do {

            let status =
                try await container.accountStatus()

            return status == .available

        } catch {

            print(
                "❌ Could not check iCloud:",
                error
            )

            return false
        }
    }

    // MARK: - Encode

    private func encodeAppStorage() throws -> Data {

        var values =
            UserDefaults.standard
                .dictionaryRepresentation()

        values.removeValue(
            forKey: "lockpasscode"
        )

        return try PropertyListSerialization.data(
            fromPropertyList: values,
            format: .binary,
            options: 0
        )
    }

    // MARK: - Restore

    private func restoreAppStorage(
        from data: Data
    ) throws {

        guard let values =
                try PropertyListSerialization.propertyList(
                    from: data,
                    options: [],
                    format: nil
                ) as? [String: Any]
        else {
            throw NSError(
                domain: "CloudSave",
                code: 1
            )
        }

        for (key, value) in values {

            UserDefaults.standard.set(
                value,
                forKey: key
            )
        }
    }
}
