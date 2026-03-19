////////////////////////////////////////////////////
//////////////////// KARI IHAB ////////////////////
//////////////////////////////////////////////////
//////////////////// BD cars ////////////////////
//////////////////////////////////////////////////

@preconcurrency import SQLite 
import Foundation

// connexion a la base de donnee SQLite (fichier local)
let db = try! Connection("cars.sqlite3")

// nom de la table
let carsTable = Table("cars")

// colonnes de la table (expressions typees - pas de SQL brut)
let colId         = Expression<Int64>("id")
let colMake       = Expression<String>("make")
let colModel      = Expression<String>("model")
let colYear       = Expression<Int>("year")
let colColor      = Expression<String>("color")
let colMileage    = Expression<Int>("mileage")
let colIsFavorite = Expression<Bool>("isFavorite")

// creation de la table si elle nexiste pas encore
// id s incremente automatiquement a chaque ajout
func createTable() throws {
    try db.run(carsTable.create(ifNotExists: true) { t in
        t.column(colId, primaryKey: .autoincrement)
        t.column(colMake)
        t.column(colModel)
        t.column(colYear)
        t.column(colColor)
        t.column(colMileage)
        t.column(colIsFavorite, defaultValue: false)
    })
}

// CREATE - ajoute une nouvelle voiture dans la base de donnee
func createCar(_ car: Car) throws {
    try db.run(carsTable.insert(
        colMake       <- car.make,
        colModel      <- car.model,
        colYear       <- car.year,
        colColor      <- car.color,
        colMileage    <- car.mileage,
        colIsFavorite <- car.isFavorite
    ))
}

// READ ALL - retourne toutes les voitures de la table
func getAllCars() throws -> [Car] {
    var cars: [Car] = []
    for row in try db.prepare(carsTable) {
        cars.append(Car(
            id:         row[colId],
            make:       row[colMake],
            model:      row[colModel],
            year:       row[colYear],
            color:      row[colColor],
            mileage:    row[colMileage],
            isFavorite: row[colIsFavorite]
        ))
    }
    return cars
}

// READ ONE - retourne une seule voiture par son id
// retourne nil si aucune voiture trouvee
func getCarById(_ id: Int64) throws -> Car? {
    let query = carsTable.filter(colId == id)
    guard let row = try db.pluck(query) else { return nil }
    return Car(
        id:         row[colId],
        make:       row[colMake],
        model:      row[colModel],
        year:       row[colYear],
        color:      row[colColor],
        mileage:    row[colMileage],
        isFavorite: row[colIsFavorite]
    )
}

// UPDATE - modifie les champs dune voiture existante
// ne fait rien si lid est nil
func updateCar(_ car: Car) throws {
    guard let id = car.id else { return }
    let target = carsTable.filter(colId == id)
    try db.run(target.update(
        colMake       <- car.make,
        colModel      <- car.model,
        colYear       <- car.year,
        colColor      <- car.color,
        colMileage    <- car.mileage,
        colIsFavorite <- car.isFavorite
    ))
}

// DELETE - supprime une voiture par son id
func deleteCar(_ id: Int64) throws {
    let target = carsTable.filter(colId == id)
    try db.run(target.delete())
}

// TOGGLE FAVORITE - inverse letat favori dune voiture
// si true devient false et vice versa
func toggleFavorite(_ id: Int64) throws {
    guard let car = try getCarById(id) else { return }
    let target = carsTable.filter(colId == id)
    try db.run(target.update(
        colIsFavorite <- !car.isFavorite
    ))
}