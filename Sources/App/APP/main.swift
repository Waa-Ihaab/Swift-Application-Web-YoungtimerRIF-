// main.swift
// Kari Ihab

import Hummingbird
import NIOCore
import Foundation

// MARK: - Lancement de l'application

/// Configuration et lancement du serveur
let app = Application(
    router: buildRouter(),
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

try await app.runService()

// MARK: - Router

/// Création du routeur et des routes
func buildRouter() -> Router<BasicRequestContext> {
    let router = Router(context: BasicRequestContext.self)

    // GET /
    // Afficher toutes les voitures avec tri optionnel
    router.get("/") { request, context -> Response in
        let sortBy = request.uri.queryParameters.get("sort") ?? ""
        do {
            let cars = try DatabaseManager.shared.getAllCars(sortBy: sortBy.isEmpty ? nil : sortBy)
            let html = indexPage(cars: cars, searchQuery: "", sortBy: sortBy)
            return htmlResponse(html)
        } catch {
            let html = indexPage(cars: [], searchQuery: "", sortBy: "")
            return htmlResponse(html)
        }
    }

    // GET /search
    // Recherche par marque, modèle ou couleur
    router.get("/search") { request, context -> Response in
        let query = request.uri.queryParameters.get("q") ?? ""
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return redirect(to: "/")
        }
        do {
            let cars = try DatabaseManager.shared.searchCars(query: query)
            let html = searchPage(cars: cars, query: query)
            return htmlResponse(html)
        } catch {
            let html = searchPage(cars: [], query: query)
            return htmlResponse(html)
        }
    }

    // GET /cars/:id
    // Afficher les détails d'une voiture
    router.get("/cars/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            guard let car = try DatabaseManager.shared.getCar(id: id) else {
                return redirect(to: "/")
            }
            let html = detailPage(car: car)
            return htmlResponse(html)
        } catch {
            return redirect(to: "/")
        }
    }

    // GET /add
    // Afficher le formulaire d'ajout
    router.get("/add") { request, context -> Response in
        let html = formPage()
        return htmlResponse(html)
    }

    // GET /edit/:id
    // Afficher le formulaire de modification
    router.get("/edit/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            guard let car = try DatabaseManager.shared.getCar(id: id) else {
                return redirect(to: "/")
            }
            let html = formPage(car: car)
            return htmlResponse(html)
        } catch {
            return redirect(to: "/")
        }
    }

    // POST /create
    // Ajouter une nouvelle voiture
    router.post("/create") { request, context -> Response in
        do {
            var body = try await request.body.collect(upTo: 1024 * 16)
            let raw  = body.readString(length: body.readableBytes) ?? ""
            let input = parseForm(raw)
            let car   = try input.validated()
            try DatabaseManager.shared.createCar(car)
            return redirect(to: "/")
        } catch let error as ValidationError {
            let html = formPage(error: error.description)
            return htmlResponse(html)
        } catch {
            let html = formPage(error: "Erreur lors de l'ajout : \(error)")
            return htmlResponse(html)
        }
    }

    // POST /update/:id
    // Modifier une voiture existante
    router.post("/update/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            var body  = try await request.body.collect(upTo: 1024 * 16)
            let raw   = body.readString(length: body.readableBytes) ?? ""
            let input = parseForm(raw)
            let car   = try input.validated()
            try DatabaseManager.shared.updateCar(id: id, with: car)
            return redirect(to: "/cars/\(id)")
        } catch let error as ValidationError {
            let existingCar = try? DatabaseManager.shared.getCar(id: id)
            let html = formPage(car: existingCar, error: error.description)
            return htmlResponse(html)
        } catch {
            let existingCar = try? DatabaseManager.shared.getCar(id: id)
            let html = formPage(car: existingCar, error: "Erreur lors de la modification : \(error)")
            return htmlResponse(html)
        }
    }

    // POST /delete/:id
    // Supprimer une voiture
    router.post("/delete/:id") { request, context -> Response in
        guard let id = context.parameters.get("id", as: Int.self) else {
            return redirect(to: "/")
        }
        do {
            try DatabaseManager.shared.deleteCar(id: id)
        } catch {
            // Si erreur, retour à l'accueil quand même
        }
        return redirect(to: "/")
    }

    return router
}

// MARK: - Form Parser

/// Lire les données du formulaire et les transformer en CarFormInput
func parseForm(_ raw: String) -> CarFormInput {
    var fields: [String: String] = [:]
    for pair in raw.split(separator: "&") {
        let parts = pair.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key   = String(parts[0]).replacingOccurrences(of: "+", with: " ")
                            .removingPercentEncoding ?? String(parts[0])
            let value = String(parts[1]).replacingOccurrences(of: "+", with: " ")
                            .removingPercentEncoding ?? String(parts[1])
            fields[key] = value
        }
    }
    return CarFormInput(
        brand:     fields["brand"],
        model:     fields["model"],
        year:      fields["year"],
        mileage:   fields["mileage"],
        price:     fields["price"],
        color:     fields["color"],
        condition: fields["condition"]
    )
}

// MARK: - Réponses HTTP

/// Retourner une page HTML
func htmlResponse(_ html: String) -> Response {
    var headers = HTTPFields()
    headers[.contentType] = "text/html; charset=utf-8"
    return Response(
        status: .ok,
        headers: headers,
        body: .init(byteBuffer: ByteBuffer(string: html))
    )
}

/// Faire une redirection
func redirect(to path: String) -> Response {
    var headers = HTTPFields()
    headers[.location] = path
    return Response(status: .seeOther, headers: headers)
}