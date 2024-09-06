import CryptoSwift
import Foundation
import KeychainSwift

class SecureKeychainService {
    static let shared = SecureKeychainService()
    private let keychain = KeychainSwift()
    private let masterKeyIdentifier = "pm.there.There"
    private let saltIdentifier = "pm.there.There.salt"

    init() {
        ensureMasterKeyExists()
    }

    private func ensureMasterKeyExists() {
        if keychain.get(masterKeyIdentifier) == nil {
            let masterKey = Data((0 ..< 32).map { _ in UInt8.random(in: 0 ... 255) })
            keychain.set(masterKey, forKey: masterKeyIdentifier, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }

        if keychain.get(saltIdentifier) == nil {
            let salt = Data((0 ..< 16).map { _ in UInt8.random(in: 0 ... 255) })
            keychain.set(salt, forKey: saltIdentifier, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
        }
    }

    private func deriveKey() throws -> Array<UInt8> {
        guard let masterKeyData = keychain.getData(masterKeyIdentifier),
              let saltData = keychain.getData(saltIdentifier) else {
            throw KeychainError.keyDerivationFailed
        }

        return try PKCS5.PBKDF2(
            password: masterKeyData.bytes,
            salt: saltData.bytes,
            iterations: 4096,
            keyLength: 32,
            variant: .sha2(.sha256)
        ).calculate()
    }

    func saveEncrypted(_ value: String, forKey key: String) throws {
        let derivedKey = try deriveKey()
        let iv = AES.randomIV(AES.blockSize)
        let aes = try AES(key: derivedKey, blockMode: CBC(iv: iv), padding: .pkcs7)
        let encrypted = try aes.encrypt(value.bytes)
        let encryptedData = iv + encrypted
        keychain.set(encryptedData.toBase64(), forKey: key)
    }


    func retrieveDecrypted(forKey key: String) throws -> String? {
        guard let encryptedBase64 = keychain.get(key),
              let encryptedData = Data(base64Encoded: encryptedBase64) else {
            return nil
        }

        let iv = Array(encryptedData.prefix(AES.blockSize))
        let encrypted = Array(encryptedData.dropFirst(AES.blockSize))
        let derivedKey = try deriveKey()

        let decrypted = try AES(key: derivedKey, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(encrypted)
        return String(bytes: decrypted, encoding: .utf8)
    }

    func delete(forKey key: String) -> Bool {
        return keychain.delete(key)
    }
}

enum KeychainError: Error {
    case keyDerivationFailed
}
