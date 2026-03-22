// Models.swift
// YoungtimerGarage — Projet Final iOS Swift
// Université Paris 8 — 2026

import Foundation

// MARK: - Car Model

/// Représente une voiture youngtimer dans la base de données.
/// Conforme à Codable (sérialisation JSON) et Sendable (concurrence Swift).
struct Car: Codable, Sendable {

    /// Identifiant unique auto-incrémenté par SQLite.
    let id: Int?

    /// Marque de la voiture (ex: Mercedes-Benz, BMW, Peugeot).
    let brand: String

    /// Modèle exact (ex: W124 200E, E30 325i, 205 GTI).
    let model: String

    /// Année de fabrication (ex: 1989).
    let year: Int

    /// Kilométrage en km (ex: 145000).
    let mileage: Int

    /// Prix en euros (ex: 8500.0).
    let price: Double

    /// Couleur de la carrosserie (ex: Noir, Gris Métallisé, Rouge).
    let color: String

    /// État général de la voiture.
    /// Valeurs acceptées : "Excellent", "Bon", "À restaurer"
    let condition: String
}

// MARK: - Car Extension

extension Car {

    /// Retourne une description lisible de l'état de la voiture
    /// avec un indicateur visuel (emoji) côté serveur HTML.
    var conditionBadge: String {
        switch condition {
        case "Excellent": return "🟢 Excellent"
        case "Bon":       return "🟡 Bon"
        default:          return "🔴 À restaurer"
        }
    }

    /// Formate le kilométrage avec séparateur de milliers.
    var formattedMileage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)") + " km"
    }

    /// Formate le prix en euros.
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) €"
    }
}

// MARK: - Form Input Model

/// Données reçues depuis le formulaire HTML (POST).
/// Tous les champs sont optionnels car ils viennent d'un formulaire web.
struct CarFormInput: Codable, Sendable {
    let brand: String?
    let model: String?
    let year: String?      // String → converti en Int côté Database
    let mileage: String?   // String → converti en Int côté Database
    let price: String?     // String → converti en Double côté Database
    let color: String?
    let condition: String?
}

// MARK: - Validation

extension CarFormInput {

    /// Valide les données du formulaire et retourne une `Car` prête à insérer,
    /// ou lance une erreur descriptive si un champ est invalide.
    ///
    /// - Throws: `ValidationError` si un champ est manquant ou invalide.
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

// MARK: - Validation Error

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