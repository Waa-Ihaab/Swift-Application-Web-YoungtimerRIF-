////////////////////////////////////////////////////
//////////////////// KARI IHAB ////////////////////
//////////////////////////////////////////////////
/////////////////// main cars //////////////////
//////////////////////////////////////////////////

import Foundation
import Hummingbird
@preconcurrency import SQLite

// initialisation de la base de donnee + creation de la table
try createTable()

// setup du serveur web
let router = Router()

// -------------------------------------------------------
// GET / - redirige vers /cars
// -------------------------------------------------------
router.get("/") { _, _ -> Response in
    return Response(status: .seeOther, headers: [.location: "/cars"])
}

// -------------------------------------------------------
// GET /cars - affiche la liste de toutes les voitures
// -------------------------------------------------------
router.get("/cars") { _, _ -> HTML in
    let cars = try getAllCars()
    return Views.renderIndex(cars: cars)
}

// -------------------------------------------------------
// GET /cars/new - affiche le formulaire d'ajout
// -------------------------------------------------------
router.get("/cars/new") { _, _ -> HTML in
    return Views.renderNewForm()
}

// -------------------------------------------------------
// POST /cars - cree une nouvelle voiture
// -------------------------------------------------------
router.post("/cars") { request, _ -> Response in
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    var components = URLComponents()
    components.percentEncodedQuery = bodyString
    let items = components.queryItems

    // recupere les champs du formulaire
    let make    = items?.first(where: { $0.name == "make"    })?.value ?? ""
    let model   = items?.first(where: { $0.name == "model"   })?.value ?? ""
    let yearStr = items?.first(where: { $0.name == "year"    })?.value ?? ""
    let color   = items?.first(where: { $0.name == "color"   })?.value ?? ""
    let mileageStr = items?.first(where: { $0.name == "mileage" })?.value ?? ""

    // valide les champs obligatoires
    guard !make.isEmpty, !model.isEmpty, let year = Int(yearStr) else {
        return Response(status: .badRequest)
    }

    let car = Car(
        id: nil,
        make: make,
        model: model,
        year: year,
        color: color,
        mileage: Int(mileageStr) ?? 0,
        isFavorite: false
    )
    try createCar(car)

    return Response(status: .seeOther, headers: [.location: "/cars"])
}

// -------------------------------------------------------
// GET /cars/:id/edit - affiche le formulaire de modification
// -------------------------------------------------------
router.get("/cars/:id/edit") { _, context -> HTML in
    guard let idStr = context.parameters.get("id"),
          let id = Int64(idStr),
          let car = try getCarById(id) else {
        return Views.renderNewForm(error: "Voiture introuvable.")
    }
    return Views.renderEditForm(car: car)
}

// -------------------------------------------------------
// POST /cars/:id/update - modifie une voiture existante
// -------------------------------------------------------
router.post("/cars/:id/update") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int64(idStr) else {
        return Response(status: .badRequest)
    }

    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    var components = URLComponents()
    components.percentEncodedQuery = bodyString
    let items = components.queryItems

    // recupere les champs du formulaire
    let make       = items?.first(where: { $0.name == "make"    })?.value ?? ""
    let model      = items?.first(where: { $0.name == "model"   })?.value ?? ""
    let yearStr    = items?.first(where: { $0.name == "year"    })?.value ?? ""
    let color      = items?.first(where: { $0.name == "color"   })?.value ?? ""
    let mileageStr = items?.first(where: { $0.name == "mileage" })?.value ?? ""

    // valide les champs obligatoires
    guard !make.isEmpty, !model.isEmpty, let year = Int(yearStr) else {
        return Response(status: .badRequest)
    }

    let updated = Car(
        id: id,
        make: make,
        model: model,
        year: year,
        color: color,
        mileage: Int(mileageStr) ?? 0,
        isFavorite: false
    )
    try updateCar(updated)

    return Response(status: .seeOther, headers: [.location: "/cars"])
}

// -------------------------------------------------------
// POST /cars/:id/delete - supprime une voiture
// -------------------------------------------------------
router.post("/cars/:id/delete") { _, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int64(idStr) else {
        return Response(status: .badRequest)
    }
    try deleteCar(id)
    return Response(status: .seeOther, headers: [.location: "/cars"])
}

// -------------------------------------------------------
// POST /cars/:id/favorite - toggle favori
// -------------------------------------------------------
router.post("/cars/:id/favorite") { _, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let id = Int64(idStr) else {
        return Response(status: .badRequest)
    }
    try toggleFavorite(id)
    return Response(status: .seeOther, headers: [.location: "/cars"])
}

// -------------------------------------------------------
// demarrage du serveur sur le port 8080
// -------------------------------------------------------
let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

// GET /cars/favorites - affiche les voitures likees
router.get("/cars/favorites") { _, _ -> HTML in
    let cars = try getAllCars()
    return Views.renderFavorites(cars: cars)
}

print("🚀 Server started at http://localhost:8080")
try await app.runService()