// Models.swift
// Kari Ihab

import Foundation

// MARK: - Modèle Car

/// Modèle d'une voiture
struct Car: Codable, Sendable {

    /// Id de la voiture
    let id: Int?

    /// Marque
    let brand: String

    /// Modèle
    let model: String

    /// Année
    let year: Int

    /// Kilométrage
    let mileage: Int

    /// Prix
    let price: Double

    /// Couleur
    let color: String

    /// État
    let condition: String
}

// MARK: - Extensions Car

extension Car {

    /// Retourne l'état
    var conditionBadge: String {
        switch condition {
        case "Excellent": return "Excellent"
        case "Bon":       return "Bon"
        default:          return "À restaurer"
        }
    }

    /// Formater le kilométrage
    var formattedMileage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)") + " km"
    }

    /// Formater le prix
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) €"
    }
}

// MARK: - Données du formulaire

/// Données récupérées depuis le formulaire HTML
struct CarFormInput: Codable, Sendable {
    let brand: String?
    let model: String?
    let year: String?
    let mileage: String?
    let price: String?
    let color: String?
    let condition: String?
}

// MARK: - Validation

extension CarFormInput {

    /// Vérifier les données du formulaire
    func validated() throws -> Car {
        guard let brand = brand, !brand.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingField("marque")
        }
        guard let model = model, !model.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingField("modèle")
        }
        guard let yearStr = year, let yearInt = Int(yearStr),
              yearInt >= 1970 && yearInt <= 2010 else {
            throw ValidationError.invalidField("année", "Entrez une année entre 1970 et 2010")
        }
        guard let mileageStr = mileage, let mileageInt = Int(mileageStr),
              mileageInt >= 0 else {
            throw ValidationError.invalidField("kilométrage", "Le kilométrage doit être positif")
        }
        guard let priceStr = price, let priceDouble = Double(priceStr),
              priceDouble >= 0 else {
            throw ValidationError.invalidField("prix", "Le prix doit être positif")
        }
        guard let color = color, !color.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.missingField("couleur")
        }
        let validConditions = ["Excellent", "Bon", "À restaurer"]
        guard let condition = condition, validConditions.contains(condition) else {
            throw ValidationError.invalidField("état", "Choisissez : Excellent, Bon ou À restaurer")
        }

        return Car(
            id: nil,
            brand: brand.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            year: yearInt,
            mileage: mileageInt,
            price: priceDouble,
            color: color.trimmingCharacters(in: .whitespaces),
            condition: condition
        )
    }
}

// MARK: - Erreurs de validation

enum ValidationError: Error, CustomStringConvertible {
    case missingField(String)
    case invalidField(String, String)

    var description: String {
        switch self {
        case .missingField(let field):
            return "Le champ \"\(field)\" est obligatoire."
        case .invalidField(let field, let reason):
            return "Champ \"\(field)\" invalide : \(reason)."
        }
    }
}