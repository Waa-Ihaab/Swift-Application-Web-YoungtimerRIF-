////////////////////////////////////////////////////
//////////////////// KARI IHAB ////////////////////
//////////////////////////////////////////////////
//////////////////// BD cars ////////////////////
//////////////////////////////////////////////////


import SQLite
import Foundation

//Creati
let db         = try Connection("cars.sqlite3")
let carsTable  = Table("cars")

let colId         = Expression<Int64>("id")
let colMake       = Expression<String>("make")
let colModel      = Expression<String>("model")
let colYear       = Expression<Int>("year")
let colColor      = Expression<String>("color")
let colMileage    = Expression<Int>("mileage")
let colIsFavorite = Expression<Bool>("isFavorite")

// MARK: - Création de la table
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

// MARK: - CREATE
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

// MARK: - READ ALL
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

// MARK: - READ ONE
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

// MARK: - UPDATE
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

// MARK: - DELETE
func deleteCar(_ id: Int64) throws {
    let target = carsTable.filter(colId == id)
    try db.run(target.delete())
}

// MARK: - TOGGLE FAVORITE
func toggleFavorite(_ id: Int64) throws {
    guard let car = try getCarById(id) else { return }
    let target = carsTable.filter(colId == id)
    try db.run(target.update(
        colIsFavorite <- !car.isFavorite
    ))
}