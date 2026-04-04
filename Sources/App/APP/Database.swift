// Database.swift
// Kari Ihab

import Foundation
@preconcurrency import SQLite 


/// Table SQLite cars
let carsTable = Table("cars")
 
/// Colonnes
let colId        = Expression<Int>("id")
let colBrand     = Expression<String>("brand")
let colModel     = Expression<String>("model")
let colYear      = Expression<Int>("year")
let colMileage   = Expression<Int>("mileage")
let colPrice     = Expression<Double>("price")
let colColor     = Expression<String>("color")
let colCondition = Expression<String>("condition")

/// Gestion de la base de données
final class DatabaseManager: Sendable {

    /// Instance partagée
    static let shared = DatabaseManager()

    private let db: Connection

    private init() {
        do {
            // Création / ouverture du fichier SQLite
            db = try Connection("youngtimer_garage.sqlite3")
            try createTable()
            try seedIfEmpty()
        } catch {
            fatalError("Erreur init DB : \(error)")
        }
    }

    /// Création de la table si elle n'existe pas
    private func createTable() throws {
        try db.run(carsTable.create(ifNotExists: true) { t in
            t.column(colId,        primaryKey: .autoincrement)
            t.column(colBrand,     check: colBrand != "")
            t.column(colModel,     check: colModel != "")
            t.column(colYear)
            t.column(colMileage)
            t.column(colPrice)
            t.column(colColor,     check: colColor != "")
            t.column(colCondition, check: colCondition != "")
        })
    }

    /// Ajout de données de test si la table est vide
    private func seedIfEmpty() throws {
        let count = try db.scalar(carsTable.count)
        guard count == 0 else { return }

        let samples: [(String, String, Int, Int, Double, String, String)] = [
            ("Mercedes-Benz", "W124 200E",   1990, 185_000, 9_500,  "Gris Métallisé", "Bon"),
            ("BMW",           "E30 325i",    1988, 210_000, 14_000, "Noir",            "À restaurer"),
            ("Peugeot",       "205 GTI 1.9", 1991, 98_000,  18_500, "Rouge",           "Excellent"),
            ("Renault",       "Clio 16S",    1992, 145_000, 7_200,  "Blanc",           "Bon"),
            ("Volkswagen",    "Golf II GTI", 1987, 230_000, 11_000, "Bleu",            "À restaurer"),
        ]

        for s in samples {
            try db.run(carsTable.insert(
                colBrand     <- s.0,
                colModel     <- s.1,
                colYear      <- s.2,
                colMileage   <- s.3,
                colPrice     <- s.4,
                colColor     <- s.5,
                colCondition <- s.6
            ))
        }
    }

    /// Récupérer toutes les voitures (tri optionnel)
    func getAllCars(sortBy: String? = nil) throws -> [Car] {
        var query = carsTable

        switch sortBy {
        case "year":    query = query.order(colYear.desc)
        case "price":   query = query.order(colPrice.asc)
        case "mileage": query = query.order(colMileage.asc)
        case "brand":   query = query.order(colBrand.asc)
        default:        query = query.order(colId.desc)
        }

        return try db.prepare(query).map { row in
            Car(
                id:        row[colId],
                brand:     row[colBrand],
                model:     row[colModel],
                year:      row[colYear],
                mileage:   row[colMileage],
                price:     row[colPrice],
                color:     row[colColor],
                condition: row[colCondition]
            )
        }
    }

    /// Récupérer une voiture par id
    func getCar(id: Int) throws -> Car? {
        let query = carsTable.filter(colId == id)
        return try db.prepare(query).compactMap { row in
            Car(
                id:        row[colId],
                brand:     row[colBrand],
                model:     row[colModel],
                year:      row[colYear],
                mileage:   row[colMileage],
                price:     row[colPrice],
                color:     row[colColor],
                condition: row[colCondition]
            )
        }.first
    }

    /// Recherche (marque / modèle / couleur)
    func searchCars(query: String) throws -> [Car] {
        let term = "%\(query)%"
        let filtered = carsTable.filter(
            colBrand.like(term) || colModel.like(term) || colColor.like(term)
        ).order(colBrand.asc)

        return try db.prepare(filtered).map { row in
            Car(
                id:        row[colId],
                brand:     row[colBrand],
                model:     row[colModel],
                year:      row[colYear],
                mileage:   row[colMileage],
                price:     row[colPrice],
                color:     row[colColor],
                condition: row[colCondition]
            )
        }
    }

    /// Ajouter une voiture
    func createCar(_ car: Car) throws {
        try db.run(carsTable.insert(
            colBrand     <- car.brand,
            colModel     <- car.model,
            colYear      <- car.year,
            colMileage   <- car.mileage,
            colPrice     <- car.price,
            colColor     <- car.color,
            colCondition <- car.condition
        ))
    }

    /// Modifier une voiture existante
    func updateCar(id: Int, with car: Car) throws {
        let target = carsTable.filter(colId == id)
        let updated = try db.run(target.update(
            colBrand     <- car.brand,
            colModel     <- car.model,
            colYear      <- car.year,
            colMileage   <- car.mileage,
            colPrice     <- car.price,
            colColor     <- car.color,
            colCondition <- car.condition
        ))
        guard updated > 0 else {
            throw DatabaseError.notFound(id)
        }
    }

    /// Supprimer une voiture
    func deleteCar(id: Int) throws {
        let target = carsTable.filter(colId == id)
        let deleted = try db.run(target.delete())
        guard deleted > 0 else {
            throw DatabaseError.notFound(id)
        }
    }
}

/// Erreurs liées à la base
enum DatabaseError: Error, CustomStringConvertible {
    case notFound(Int)

    var description: String {
        switch self {
        case .notFound(let id):
            return "Voiture non trouvée avec id \(id)"
        }
    }
}